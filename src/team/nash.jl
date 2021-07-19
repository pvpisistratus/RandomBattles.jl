using JuMP, GLPK

const no_strat = vec([1.0])

function strat_vec(l::Int64, i::Int64)
    to_return = zeros(l)
    @inbounds to_return[i] = 1.0
    return to_return
end

minmax(R::Matrix{Float64}, m::Int64) =
    @inbounds mapreduce(x -> maximum(R[:, x]), min, 1:m)
maxmin(R::Matrix{Float64}, n::Int64) =
    @inbounds mapreduce(x -> minimum(R[x, :]), max, 1:n)
findminmax(R::Matrix{Float64}, n::Int64) =
    @inbounds strat_vec(n, argmax(map(x -> minimum(R[x, :]), 1:n)))
findmaxmin(R::Matrix{Float64}, m::Int64) =
    @inbounds strat_vec(m, argmin(map(x -> maximum(R[:, x]), 1:m)))

struct NashResult
    payoff::Float64
    row_strategy::Vector{Float64}
    column_strategy::Vector{Float64}
end

function nash(R::Matrix{Float64})
    n, m = size(R)

    # Check if we have to do linear programming
    n == 1 && return NashResult(
        minimum(R), no_strat, strat_vec(m, argmin(R)[2]))
    m == 1 && return NashResult(
        maximum(R), strat_vec(n, argmax(R)[1]), no_strat)
    minmax(R, m) == maxmin(R, n) && return NashResult(
        minmax(R, m), findminmax(R, n), findmaxmin(R, m))

    # Set up model and payoff
    model = direct_model(GLPK.Optimizer())
    @variable(model, z)
    @objective(model, Max, 1.0 * z)

    # Solve for row player
    @variable(model, x[1:n], lower_bound = 0.0)
    @constraint(model, c1, x' * R .>= z)
    @constraint(model, sum(x) == 1.0)

    optimize!(model)

    return NashResult(JuMP.value(z), JuMP.value.(x), vec(shadow_price.(c1)))
end

function SM(state::DynamicState, static_state::StaticState, depth::Int64;
    allow_nothing::Bool = false, allow_overfarming::Bool = false,
    sim_to_end::Bool = false)
    active1, active2 = get_active(state)
    fm_damages = get_fast_move_damages(state, static_state, active1, active2)
    return SM(state, static_state, depth,
        get_fast_move_damages(state, static_state, active1, active2);
        allow_nothing, allow_overfarming, sim_to_end)
end

function SM(state::DynamicState, static_state::StaticState, depth::Int64,
    fm_damages::Tuple{UInt16, UInt16}; allow_nothing::Bool = false,
    allow_overfarming::Bool = false, sim_to_end::Bool = false)
    A, B = get_possible_decisions(state, static_state,
        allow_nothing = allow_nothing, allow_overfarming = allow_overfarming)

    (Base.ctpop_int(A) == 0x00 || Base.ctpop_int(B) == 0x00 || depth == 0) &&
        return sim_to_end ?
            NashResult(sum(battle_scores(state, static_state, 100)
                / 100) - 0.5, no_strat, no_strat) :
            NashResult(battle_score(state, static_state) - 0.5,
                no_strat, no_strat)

    payoffs = zeros(Float64, Base.ctpop_int(A), Base.ctpop_int(B))

    state_1, state_2 = state, state
    odds = 1.0
    chance = get_chance(state)
    if chance == 0x0005
        state_1 = DynamicState(state[0x01], state[0x02], state.data - 0x4360)
        state_2 = DynamicState(state[0x01], state[0x02], state.data - 0x4050)
        odds = Int8(50)
    else
        state_2 = DynamicState(state[0x01], state[0x02],
            state.data - chance * 0x0f50)
        active = get_active(state)
        agent = chance < 0x0003 ? 0x01 : 0x02
        move = isodd(chance) ? static_state[agent][
            active[agent]].charged_move_1 : static_state[agent][
                active[agent]].charged_move_2
        a_data = state[agent].data
        d_data = state[get_other_agent(agent)].data
        a_data, d_data = apply_buff(a_data, d_data, move)
        state_1 = DynamicState(
            DynamicTeam(state[0x01][0x0001], state[0x01][0x0002],
                state[0x01][0x0003], state[0x01].switchCooldown,
                agent == 0x0001 ? a_data : d_data),
            DynamicTeam(state[0x02][0x0001], state[0x02][0x0002],
                state[0x02][0x0003], state[0x02].switchCooldown,
                agent == 0x0002 ? a_data : d_data),
            state.data - chance * 0x0f50)
        odds = move.buffChance
    end
    for i = 0x01:Base.ctpop_int(A), j = 0x01:Base.ctpop_int(B)
        if odds == Int8(100)
            state, fm_damages = play_turn(state_1, static_state, fm_damages,
                get_decision(A, B, i, j))
            @inbounds payoffs[i, j] = SM(state, static_state, fm_damages,
                depth - 1,
                allow_nothing = allow_nothing,
                allow_overfarming = allow_overfarming,
                sim_to_end = sim_to_end).payoff
        else
            state_1, fm_damages_1 = play_turn(state_1, static_state,
                fm_damages, get_decision(A, B, i, j))
            state_2, fm_damages_2 = play_turn(state_2, static_state,
                fm_damages, get_decision(A, B, i, j))
            @inbounds payoffs[i, j] = odds / 100 * SM(state_1, static_state,
                depth - 1, fm_damages_1, allow_nothing = allow_nothing,
                allow_overfarming = allow_overfarming,
                sim_to_end = sim_to_end).payoff +
                (100 - odds) / 100 * SM(state_2, static_state, depth - 1,
                fm_damages_2, allow_nothing = allow_nothing,
                allow_overfarming = allow_overfarming,
                sim_to_end = sim_to_end).payoff
        end
    end
    return nash(payoffs)
end

function solve_battle(s::DynamicState, static_s::StaticState, depth::Int64;
    allow_nothing::Bool = false, allow_overfarming::Bool = false,
    sim_to_end::Bool = false)
    value = 0.0
    decision = 0, 0
    strat = Strategy([], [], [], [])
    active1, active2 = get_active(state)
    fm_damages = get_fast_move_damages(s, static_s, active1, active2)
    while true
        s, fm_damages = resolve_chance(s, static_s)
        A, B = get_possible_decisions(s, static_s,
            allow_nothing = allow_nothing, allow_overfarming = allow_overfarming)

        (Base.ctpop_int(A) == 0x00 || Base.ctpop_int(B) == 0x00) &&
            return value, strat
        if Base.ctpop_int(A) == 0x01 && Base.ctpop_int(B) == 0x01
            decision = get_decision(A, B, 0x01, 0x01)
        else
            nash_result = SM(s, static_s, depth, fm_damages,
                sim_to_end = sim_to_end)
            value = nash_result.payoff
            d1, d2 = rand(), rand()
            decision1, decision2 = UInt8(length(nash_result.row_strategy)),
                UInt8(length(nash_result.column_strategy))
            j = 0.0
            for i = 0x01:(UInt8(length(nash_result.row_strategy)) - 0x01)
                @inbounds j += nash_result.row_strategy[i]
                if d1 < j
                    decision1 = i
                    break
                end
            end
            j = 0.0
            for i = 0x01:(UInt8(length(nash_result.column_strategy)) - 0x01)
                @inbounds j += nash_result.column_strategy[i]
                if d2 < j
                    decision2 = i
                    break
                end
            end
            decision = get_decision(A, B, decision1, decision2)
        end
        s, fm_damages = play_turn(s, static_s, fm_damages, decision)
        push!(strat.decisions, decision)
        push!(strat.scores, value + 0.5)
        push!(strat.activeMons, get_active(s))
        push!(strat.hps, ((get_hp(s[0x01][0x0001]),
                           get_hp(s[0x01][0x0002]),
                           get_hp(s[0x01][0x0003])),
                          (get_hp(s[0x02][0x0001]),
                           get_hp(s[0x02][0x0002]),
                           get_hp(s[0x02][0x0003]))))
    end
end

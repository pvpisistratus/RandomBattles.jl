using JuMP, GLPK

const no_strat = vec([1.0])

function strat_vec(l::Int64, i::Int64)
    to_return = zeros(l)
    @inbounds to_return[i] = 1.0
    return to_return
end

minmax(R::Matrix{Float64}, m::Int64) = @inbounds mapreduce(x -> maximum(R[:, x]), min, 1:m)
maxmin(R::Matrix{Float64}, n::Int64) = @inbounds mapreduce(x -> minimum(R[x, :]), max, 1:n)
findminmax(R::Matrix{Float64}, n::Int64) = @inbounds strat_vec(n, argmax(map(x -> minimum(R[x, :]), 1:n)))
findmaxmin(R::Matrix{Float64}, m::Int64) = @inbounds strat_vec(m, argmin(map(x -> maximum(R[:, x]), 1:m)))

struct NashResult
    payoff::Float64
    row_strategy::Vector{Float64}
    column_strategy::Vector{Float64}
end

function nash(R::Matrix{Float64})
    n, m = size(R)

    # Check if we have to do linear programming
    n == 1 && return NashResult(minimum(R), no_strat, strat_vec(m, argmin(R)[2]))
    m == 1 && return NashResult(maximum(R), strat_vec(n, argmax(R)[1]), no_strat)
    minmax(R, m) == maxmin(R, n) && return NashResult(minmax(R, m), findminmax(R, n), findmaxmin(R, m))

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
    A, B = get_possible_decisions(state, static_state,
        allow_nothing = allow_nothing, allow_overfarming = allow_overfarming)

    (Base.ctpop_int(A) == 0x00 || Base.ctpop_int(B) == 0x00 || depth == 0) &&
        return sim_to_end ?
            NashResult(sum(get_battle_scores(state, static_state, 100)
                / 100) - 0.5, no_strat, no_strat) :
            NashResult(get_battle_score(state, static_state) - 0.5,
                no_strat, no_strat)

    payoffs = zeros(Float64, Base.ctpop_int(A), Base.ctpop_int(B))

    state_1, state_2 = state, state
    odds = 0.5
    chance = get_chance(state)
    if chance == 0x0005
        state_1 = DynamicState(state.teams, state.data - 0x4360)
        state_2 = DynamicState(state.teams, state.data - 0x4050)
    else
        state_1 = DynamicState(state.teams, state.data - chance * 0x0f50)
        active = get_active(state)
        agent = chance < 0x0003 ? 1 : 2
        move = static_state.teams[agent].mons[active[agent]].chargedMoves[
            isodd(chance) ? 1 : 2]
        a_data = state.teams[agent].data
        d_data = state.teams[get_other_agent(agent)].data
        a_data, d_data = apply_buff(a_data, d_data, move)
        state_2 = DynamicState(@SVector[
            DynamicTeam(state.teams[1].mons, state.teams[1].switchCooldown,
                agent == 0x0001 ? a_data : d_data),
            DynamicTeam(state.teams[2].mons, state.teams[2].switchCooldown,
                agent == 0x0002 ? a_data : d_data)
        ], state.data - chance * 0x0f50)
        odds = move.buffChance / 100
        if rand(Int8(0):Int8(99)) < move.buffChance

            return
        else
            return DynamicState(state.teams, state.data - chance * 0x0f50)
        end
    end
    for i = 0x01:Base.ctpop_int(A), j = 0x01:Base.ctpop_int(B)
        @inbounds payoffs[i, j] = odds * SM(play_turn(state_1, static_state,
            get_decision(A, B, i, j)), static_state, depth - 1,
            allow_nothing = allow_nothing,
            allow_overfarming = allow_overfarming,
            sim_to_end = sim_to_end).payoff +
            (1 - odds) * SM(play_turn(state_2, static_state,
            get_decision(A, B, i, j)), static_state, depth - 1,
            allow_nothing = allow_nothing,
            allow_overfarming = allow_overfarming,
            sim_to_end = sim_to_end).payoff
    end
    return nash(payoffs)
end

function solve_battle(s::DynamicState, static_s::StaticState, depth::Int64;
    allow_nothing::Bool = false, allow_overfarming::Bool = false,
    sim_to_end::Bool = false)
    value = 0.0
    decision = 0, 0
    strat = Strategy([], [], [], [])
    while true
        A, B = get_possible_decisions(s, static_s,
            allow_nothing = allow_nothing, allow_overfarming = allow_overfarming)

        (Base.ctpop_int(A) == 0x00 || Base.ctpop_int(B) == 0x00) &&
            return value, strat
        if Base.ctpop_int(A) == 0x01 && Base.ctpop_int(B) == 0x01
            decision = get_decision(A, B, 0x01, 0x01)
        else
            nash_result = SM(s, static_s, depth, sim_to_end = sim_to_end)
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
        s = play_turn(s, static_s, decision)
        s = resolve_chance(s, static_s)
        push!(strat.decisions, decision)
        push!(strat.scores, value + 0.5)
        push!(strat.activeMons, get_active(s))
        push!(strat.hps, ((get_hp(s.teams[1].mons[1]),
                           get_hp(s.teams[1].mons[2]),
                           get_hp(s.teams[1].mons[3])),
                          (get_hp(s.teams[2].mons[1]),
                           get_hp(s.teams[2].mons[2]),
                           get_hp(s.teams[2].mons[3]))))
    end
end

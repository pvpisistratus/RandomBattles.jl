using JuMP, GLPK

function SM(state::DynamicIndividualState, static_state::StaticIndividualState,
    depth::Int64; allow_nothing::Bool = false,
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
    if chance == UInt32(5)
        state_1 = DynamicIndividualState(state[0x01], state[0x02], state.data - UInt32(9702))
        state_2 = DynamicIndividualState(state[0x01], state[0x02], state.data - UInt32(9261))
        odds = 0.5
    else
        agent = chance < UInt32(3) ? 0x01 : 0x02
        move = isodd(chance) ? static_state[agent].charged_move_1 :
            static_state[agent].charged_move_2
        data = apply_buff(state.data, move, agent)
        state_1 = DynamicIndividualState(state[0x01], state[0x02],
            data - chance * UInt32(2205))
        state_2 = DynamicIndividualState(state[0x01], state[0x02],
            state.data - chance * UInt32(2205))
        odds = move.buffChance / 100
    end
    for i = 0x01:Base.ctpop_int(A), j = 0x01:Base.ctpop_int(B)
        if odds > 0.99
            @inbounds payoffs[i, j] = SM(play_turn(state_1, static_state,
                get_decision(A, B, i, j)), static_state, depth - 1,
                allow_nothing = allow_nothing,
                allow_overfarming = allow_overfarming,
                sim_to_end = sim_to_end).payoff
        else
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
    end
    return nash(payoffs)
end

function solve_battle(s::DynamicIndividualState, static_s::StaticIndividualState, depth::Int64;
    allow_nothing::Bool = false, allow_overfarming::Bool = false, sim_to_end = false)
    value = 0.0
    decision = 0, 0
    strat = IndividualStrategy([], [], [])
    while true
        s = resolve_chance(s, static_s)
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
        push!(strat.decisions, decision)
        push!(strat.scores, value + 0.5)
        push!(strat.hps, (get_hp(s[0x01]), get_hp(s[0x02])))
    end
end

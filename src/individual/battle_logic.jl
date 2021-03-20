using Distributions, StaticArrays

function get_possible_decisions(state::DynamicIndividualState, static_state::StaticIndividualState, agent::Int64; allow_nothing::Bool = false)
    @inbounds activeTeam = state.teams[agent]
    @inbounds activeMon = state.teams[agent].mon
    @inbounds activeStaticMon = static_state.teams[agent].mon
    @inbounds return @SVector [((allow_nothing || state.fastMovesPending[agent] > Int8(0)) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((allow_nothing || state.fastMovesPending[agent] > Int8(0)) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1)) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1)) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[1].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[1].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[2].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[2].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0]
end

function play_turn(state::DynamicIndividualState, static_state::StaticIndividualState, decision::Tuple{Int64,Int64})
    next_state = state

    @inbounds if next_state.fastMovesPending[1] == Int8(0) || next_state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, next_state.fastMovesPending[1] == Int8(0), next_state.fastMovesPending[2] == Int8(0))
    end

    @inbounds next_state = step_timers(next_state,
        3 <= decision[1] <= 4 ? static_state.teams[1].mon.fastMove.cooldown : Int8(0),
        3 <= decision[2] <= 4 ? static_state.teams[2].mon.fastMove.cooldown : Int8(0))

    cmp = get_cmp(static_state, 5 <= decision[1], 5 <= decision[2])
    @inbounds if cmp[1] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[1],
            5 <= decision[cmp[1]] <= 6 ? Int8(1) : Int8(2), Int8(100), iseven(decision[get_other_agent(cmp[1])]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[1]].mon.chargedMoves[5 <= decision[cmp[1]] <= 6 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[get_other_agent(cmp[1])] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[1] == Int8(1), cmp[1] == Int8(2))
        end
    end
    @inbounds if cmp[2] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[2],
            5 <= decision[cmp[2]] <= 6 ? Int8(1) : Int8(2), Int8(100), iseven(decision[cmp[1]]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[2]].mon.chargedMoves[5 <= decision[cmp[2]] <= 6 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[cmp[1]] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[1] == Int8(1), cmp[1] == Int8(2))
        end
    end

    return next_state
end

function play_battle(starting_state::DynamicIndividualState, static_state::StaticIndividualState)
    state = starting_state
    while true
        weights1, weights2 = get_possible_decisions(state, static_state, 1), get_possible_decisions(state, static_state, 2)
        (sum(weights1) * sum(weights2) == 0) && return get_battle_score(state, static_state)
        decision1, decision2 = rand(Categorical(weights1 / sum(weights1), check_args = false)), rand(Categorical(weights2 / sum(weights2), check_args = false))
        state = play_turn(state, static_state, (decision1, decision2))
    end
end

function get_battle_scores(starting_state::DynamicIndividualState, static_state::StaticIndividualState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

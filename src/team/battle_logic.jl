using Distributions, StaticArrays

function get_possible_decisions(state::DynamicState, static_state::StaticState, agent::Int64; allow_nothing::Bool = false)
    @inbounds activeTeam = state.teams[agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    @inbounds activeStaticTeam = static_state.teams[agent]
    @inbounds activeStaticMon = activeStaticTeam.mons[activeTeam.active]
    state.fastMovesPending[agent] != Int8(0) && state.fastMovesPending[agent] != Int8(-1) && activeMon.hp != Int16(0) && return @SVector [1.0,
        1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    @inbounds return @SVector [((allow_nothing || state.fastMovesPending[agent] > Int8(0)) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((allow_nothing || state.fastMovesPending[agent] > Int8(0)) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeMon.hp > 0) ? 1.0 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.shields > Int8(0) && activeMon.hp > 0) ? 1.0 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeMon.energy >= activeStaticMon.chargedMoves[1].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeMon.energy >= activeStaticMon.chargedMoves[1].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeMon.energy >= activeStaticMon.chargedMoves[2].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeMon.energy >= activeStaticMon.chargedMoves[2].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == Int8(0) && activeTeam.active != Int8(1) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == Int8(0) && activeTeam.active != Int8(1) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == Int8(0) && activeTeam.active != Int8(2) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == Int8(0) && activeTeam.active != Int8(2) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == Int8(0) && activeTeam.active != Int8(3) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == Int8(0) && activeTeam.active != Int8(3) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0]
end

function play_turn(state::DynamicState, static_state::StaticState, decision::Tuple{Int64,Int64})
    next_state = state

    @inbounds if next_state.fastMovesPending[1] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, Int8(1))
    end
    @inbounds if next_state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, Int8(2))
    end

    @inbounds next_state = step_timers(next_state,
        3 <= decision[1] <= 4 ? static_state.teams[1].mons[next_state.teams[1].active].fastMove.cooldown : Int8(0),
        3 <= decision[2] <= 4 ? static_state.teams[2].mons[next_state.teams[2].active].fastMove.cooldown : Int8(0))

    @inbounds if 9 <= decision[1] <= 20
        next_state = evaluate_switch(next_state, Int8(1),
            9 <= decision[1] <= 10 || 15 <= decision[1] <= 16 ? Int8(1) :
            11 <= decision[1] <= 12 || 17 <= decision[1] <= 18 ? Int8(2) : Int8(3),
            9 <= decision[1] <= 14 ? Int8(0) : Int8(24))
    end
    @inbounds if 9 <= decision[2] <= 20
        next_state = evaluate_switch(next_state, Int8(2),
            9 <= decision[2] <= 10 || 15 <= decision[2] <= 16 ? Int8(1) :
            11 <= decision[2] <= 12 || 17 <= decision[2] <= 18 ? Int8(2) : Int8(3),
            9 <= decision[2] <= 14 ? Int8(0) : Int8(24))
    end

    cmp = get_cmp(next_state, static_state, 5 <= decision[1] <= 8, 5 <= decision[2] <= 8)
    @inbounds if cmp[1] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[1],
            5 <= decision[cmp[1]] <= 6 ? Int8(1) : Int8(2), Int8(100), iseven(decision[get_other_agent(cmp[1])]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[1]].mons[next_state.teams[cmp[1]].active].chargedMoves[5 <= decision[cmp[1]] <= 6 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[get_other_agent(cmp[1])] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[1])
        end
    end
    @inbounds if cmp[2] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[2],
            5 <= decision[cmp[2]] <= 6 ? Int8(1) : Int8(2), Int8(100), iseven(decision[cmp[1]]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[2]].mons[next_state.teams[cmp[2]].active].chargedMoves[5 <= decision[cmp[2]] <= 6 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[cmp[1]] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[2])
        end
    end

    return next_state
end

function play_battle(starting_state::DynamicState, static_state::StaticState)
    state = starting_state
    while true
        weights1, weights2 = get_possible_decisions(state, static_state, 1), get_possible_decisions(state, static_state, 2)
        (sum(weights1) * sum(weights2) == 0) && return get_battle_score(state, static_state)
        decision1, decision2 = rand(Categorical(weights1 / sum(weights1), check_args = false)), rand(Categorical(weights2 / sum(weights2), check_args = false))
        state = play_turn(state, static_state, (decision1, decision2))
    end
end

function get_battle_scores(starting_state::DynamicState, static_state::StaticState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

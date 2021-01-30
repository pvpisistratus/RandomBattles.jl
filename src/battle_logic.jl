using Distributions, Setfield, Match, StaticArrays

function get_possible_decisions(state::IndividualBattleState; allow_nothing = false)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = state.teams[state.agent].mon
    @inbounds return @SVector [((allow_nothing || state.fastMovesPending[state.agent] > Int8(0)) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((allow_nothing || state.fastMovesPending[state.agent] > Int8(0)) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[1].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[1].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[2].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[2].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0]
end

function get_possible_decisions(state::State; allow_nothing = false)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    @inbounds return @SVector [((allow_nothing || state.fastMovesPending[state.agent] > Int8(0)) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((allow_nothing || state.fastMovesPending[state.agent] > Int8(0)) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.hp > 0) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.shields > Int8(0) && activeMon.hp > 0) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[1].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[1].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[2].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeMon.chargedMoves[2].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        (activeTeam.switchCooldown == 0 && activeTeam.active != Int8(1) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeTeam.switchCooldown == 0 && activeTeam.active != Int8(1) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeTeam.switchCooldown == 0 && activeTeam.active != Int8(2) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeTeam.switchCooldown == 0 && activeTeam.active != Int8(2) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeTeam.switchCooldown == 0 && activeTeam.active != Int8(3) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeTeam.switchCooldown == 0 && activeTeam.active != Int8(3) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0]
end

function play_decision(state::IndividualBattleState, decision::Int64)
    next_state = state
    if iseven(decision)
        @inbounds next_state = @set state.teams[state.agent].shielding = true
    end
    next_state = @match decision begin
        5  || 6  => @inbounds @set next_state.chargedMovesPending[next_state.agent] = ChargedAction(Int8(1), Int8(100))
        7  || 8  => @inbounds @set next_state.chargedMovesPending[next_state.agent] = ChargedAction(Int8(2), Int8(100))
        _        => next_state
    end
    return next_state
end

function play_decision(state::State, decision::Int64)
    next_state = state
    if iseven(decision)
        @inbounds next_state = @set state.teams[state.agent].shielding = true
    end
    next_state = @match decision begin
        5  || 6  => @inbounds @set next_state.chargedMovesPending[next_state.agent] = ChargedAction(Int8(1), Int8(100))
        7  || 8  => @inbounds @set next_state.chargedMovesPending[next_state.agent] = ChargedAction(Int8(2), Int8(100))
        9  || 10 => queue_switch(next_state, Int8(1))
        11 || 12 => queue_switch(next_state, Int8(2))
        13 || 14 => queue_switch(next_state, Int8(3))
        15 || 16 => queue_switch(next_state, Int8(1), time = Int8(24))
        17 || 18 => queue_switch(next_state, Int8(2), time = Int8(24))
        19 || 20 => queue_switch(next_state, Int8(3), time = Int8(24))
        _        => next_state
    end

    return next_state
end

function play_turn(state::IndividualBattleState, decision::Tuple{Int64,Int64})
    @inbounds next_state = play_decision(state, decision[1])
    @inbounds next_state = play_decision((@set next_state.agent = Int8(2)), decision[2])
    next_state = @set next_state.agent = Int8(1)

    if next_state.fastMovesPending[1] == Int8(0)
        next_state = evaluate_fast_moves(next_state, 1)
    end
    if next_state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(next_state, 2)
    end
    if decision[1] == 3 || decision[1] == 4
        next_state = queue_fast_move(next_state, 1)
    end
    if decision[2] == 3 || decision[2] == 4
        next_state = queue_fast_move(next_state, 2)
    end
    if next_state.chargedMovesPending[1].charge != Int8(0) ||
        next_state.chargedMovesPending[2].charge != Int8(0)
        next_state = evaluate_charged_moves(next_state)
    end
    if next_state.chargedMovesPending[1].charge != Int8(0) ||
        next_state.chargedMovesPending[2].charge != Int8(0)
        next_state = evaluate_charged_moves(next_state)
    end
    next_state = step_timers(next_state)
    if next_state.teams[1].shielding
        @inbounds next_state = @set next_state.teams[1].shielding = false
    end
    if next_state.teams[2].shielding
        @inbounds next_state = @set next_state.teams[2].shielding = false
    end
    return next_state
end

function play_turn(state::State, decision::Tuple{Int64,Int64})
    @inbounds next_state = play_decision(state, decision[1])
    @inbounds next_state = play_decision((@set next_state.agent = Int8(2)), decision[2])
    next_state = @set next_state.agent = Int8(1)

    if next_state.fastMovesPending[1] == Int8(0)
        next_state = evaluate_fast_moves(next_state, 1)
    end
    if next_state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(next_state, 2)
    end
    if decision[1] == 3 || decision[1] == 4
        next_state = queue_fast_move(next_state, 1)
    end
    if decision[2] == 3 || decision[2] == 4
        next_state = queue_fast_move(next_state, 2)
    end
    if next_state.switchesPending[1].pokemon != Int8(0) ||
        next_state.switchesPending[2].pokemon != Int8(0)
        next_state = evaluate_switches(next_state)
    end
    if next_state.chargedMovesPending[1].charge != Int8(0) ||
        next_state.chargedMovesPending[2].charge != Int8(0)
        println(next_state.chargedMovesPending[1], next_state.chargedMovesPending[2])
        next_state = evaluate_charged_moves(next_state)
    end
    if next_state.chargedMovesPending[1].charge != Int8(0) ||
        next_state.chargedMovesPending[2].charge != Int8(0)
        println(next_state.chargedMovesPending[1], next_state.chargedMovesPending[2])
        next_state = evaluate_charged_moves(next_state)
    end
    next_state = step_timers(next_state)
    if next_state.teams[1].shielding
        @inbounds next_state = @set next_state.teams[1].shielding = false
    end
    if next_state.teams[2].shielding
        @inbounds next_state = @set next_state.teams[2].shielding = false
    end
    return next_state
end

function play_battle(initial_state::IndividualBattleState)
    state = initial_state
    while true
        weights1 = get_possible_decisions(state)
        weights2 = get_possible_decisions(@set state.agent = Int8(2))
        (iszero(sum(weights1)) || iszero(sum(weights2))) &&
            return get_battle_score(state)

        decision1 = rand(Categorical(weights1 / sum(weights1)))
        decision2 = rand(Categorical(weights2 / sum(weights2)))

        state = play_turn(state, (decision1, decision2))
    end
end

function play_battle(initial_state::State)
    state = initial_state
    while true
        weights1 = get_possible_decisions(state)
        weights2 = get_possible_decisions(@set state.agent = Int8(2))
        (iszero(sum(weights1)) || iszero(sum(weights2))) &&
            return get_battle_score(state)

        decision1 = rand(Categorical(weights1 / sum(weights1)))
        decision2 = rand(Categorical(weights2 / sum(weights2)))

        state = play_turn(state, (decision1, decision2))
    end
end

function get_battle_scores(initial_state::IndividualBattleState, N::Int64)
    return map(x -> play_battle(initial_state), 1:N)
end

function get_battle_scores(initial_state::State, N::Int64)
    return map(x -> play_battle(initial_state), 1:N)
end

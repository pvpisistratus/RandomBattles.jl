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

function get_possible_decisions(state::DynamicState, static_state::StaticState; allow_nothing = false)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    @inbounds activeStaticTeam = static_state.teams[state.agent]
    @inbounds activeStaticMon = activeStaticTeam.mons[activeTeam.active]
    state.fastMovesPending[state.agent] != Int8(0) && state.fastMovesPending[state.agent] != Int8(-1) && activeMon.hp != Int16(0) && return @SVector [1.0,
        1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    @inbounds return @SVector [((allow_nothing || state.fastMovesPending[state.agent] > Int8(0)) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((allow_nothing || state.fastMovesPending[state.agent] > Int8(0)) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.hp > 0) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.shields > Int8(0) && activeMon.hp > 0) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[1].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[1].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[2].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeMon.energy >= activeStaticMon.chargedMoves[2].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(1) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(1) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(2) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(2) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(3) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        ((state.fastMovesPending[state.agent] == Int8(0) || state.fastMovesPending[state.agent] == Int8(-1)) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(3) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0]
end

function queue_decision(state::IndividualBattleState, decision::Int64)
    next_state = state
    if iseven(decision)
        @inbounds next_state = @set state.teams[state.agent].shielding = true
    end
    next_state = @match decision begin
        3  || 4  => queue_fast_move(next_state, next_state.agent)
        5  || 6  => @inbounds @set next_state.chargedMovesPending[next_state.agent] = ChargedAction(Int8(1), Int8(100))
        7  || 8  => @inbounds @set next_state.chargedMovesPending[next_state.agent] = ChargedAction(Int8(2), Int8(100))
        _        => next_state
    end
    return next_state
end

function queue_decision(state::DynamicState, static_state::StaticState, dec::Decision, decision::Int64)
    next_state = state
    new_dec = dec
    if iseven(decision)
        @inbounds new_dec = @set dec.shielding[state.agent] = true
    end
    if 5 <= decision <= 6
        println("should be a charged move")
    end
    if decision == 1 || decision == 2
        return next_state, new_dec
    elseif decision == 3 || decision == 4
        next_state = queue_fast_move(next_state, static_state, next_state.agent)
    else
        new_dec = @match decision begin
            5  || 6  => @inbounds @set new_dec.chargedMovesPending[state.agent] = ChargedAction(Int8(1), Int8(100))
            7  || 8  => @inbounds @set new_dec.chargedMovesPending[state.agent] = ChargedAction(Int8(2), Int8(100))
            9  || 10 => @inbounds @set new_dec.switchesPending[state.agent] = SwitchAction(Int8(1), Int8(0))
            11 || 12 => @inbounds @set new_dec.switchesPending[state.agent] = SwitchAction(Int8(2), Int8(0))
            13 || 14 => @inbounds @set new_dec.switchesPending[state.agent] = SwitchAction(Int8(3), Int8(0))
            15 || 16 => @inbounds @set new_dec.switchesPending[state.agent] = SwitchAction(Int8(1), Int8(24))
            17 || 18 => @inbounds @set new_dec.switchesPending[state.agent] = SwitchAction(Int8(2), Int8(24))
            19 || 20 => @inbounds @set new_dec.switchesPending[state.agent] = SwitchAction(Int8(3), Int8(24))
            _        => new_dec
        end
    end
    return next_state, new_dec
end

function play_turn(state::IndividualBattleState, decision::Tuple{Int64,Int64})
    @inbounds next_state = next_state.fastMovesPending[1] == Int8(0) ?
        evaluate_fast_moves(next_state, 1) : next_state
    @inbounds next_state = next_state.fastMovesPending[2] == Int8(0) ?
        evaluate_fast_moves(next_state, 2) : next_state
    @inbounds next_state = queue_decision(state, decision[1])
    @inbounds next_state = queue_decision((@set next_state.agent = Int8(2)), decision[2])
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

function play_turn(state::DynamicState, static_state::StaticState, decision::Tuple{Int64,Int64})
    dec = defaultDecision
    next_state = state
    if state.fastMovesPending[1] == Int8(0)
        next_state = evaluate_fast_moves(state, static_state, 1)
    end
    if state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(state, static_state, 2)
    end
    next_state, dec = queue_decision(next_state, static_state, dec, decision[1])
    next_state, dec = queue_decision((@set next_state.agent = Int8(2)), static_state, dec, decision[2])
    next_state = @set next_state.agent = Int8(1)
    if dec.switchesPending[1].pokemon != Int8(0) || dec.switchesPending[2].pokemon != Int8(0)
        next_state = evaluate_switches(next_state, dec)
    end
    if dec.chargedMovesPending[1].charge != Int8(0) || dec.chargedMovesPending[2].charge != Int8(0)
        println("charged move attempted")
        next_state, dec = evaluate_charged_moves(next_state, static_state, dec)
    end
    if dec.chargedMovesPending[1].charge != Int8(0) || dec.chargedMovesPending[2].charge != Int8(0)
        println("charged move attempted")
        next_state, dec = evaluate_charged_moves(next_state, static_state, dec)
    end
    next_state = step_timers(next_state)
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

function play_battle(starting_state::DynamicState, static_state::StaticState)
    state = starting_state
    while true
        weights1 = get_possible_decisions(state, static_state)
        weights2 = get_possible_decisions((@set state.agent = Int8(2)), static_state)
        (iszero(sum(weights1)) || iszero(sum(weights2))) && return get_battle_score(state, static_state)

        decision1 = rand(Categorical(weights1 / sum(weights1)))
        decision2 = rand(Categorical(weights2 / sum(weights2)))

        state = play_turn(state, static_state, (decision1, decision2))
    end
end

function get_battle_scores(initial_state::IndividualBattleState, N::Int64)
    return map(x -> play_battle(initial_state), 1:N)
end

function get_battle_scores(starting_state::DynamicState, static_state::StaticState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

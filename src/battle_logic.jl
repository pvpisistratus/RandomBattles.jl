using Distributions, Setfield, Match, StaticArrays

function get_possible_decisions(state::DynamicState, static_state::StaticState, agent::Int64; allow_nothing = false)
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
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(1) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(1) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(2) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(2) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(3) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (state.fastMovesPending[agent] <= Int8(0) && activeTeam.switchCooldown == 0 && activeTeam.active != Int8(3) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0) && activeMon.hp > Int16(0)) ? 0.5 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[1].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[2].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0,
        (activeMon.hp == Int16(0) && activeTeam.shields > Int8(0) && activeTeam.mons[3].hp > Int16(0)) ? 1.0 : 0.0]
end

function queue_decision(state::DynamicState, static_state::StaticState, dec::Decision, decision::Tuple{Int64,Int64})
    next_state = state
    new_dec = dec
    @inbounds new_dec = @set new_dec.shielding = [iseven(decision[1]) && 5 <= decision[2] <= 8,
        iseven(decision[2]) && 5 <= decision[1] <= 8]
    if 3 <= decision[1] <= 4
        next_state = queue_fast_move(next_state, static_state, Int8(1))
    end
    if 3 <= decision[2] <= 4
        next_state = queue_fast_move(next_state, static_state, Int8(2))
    end
    new_dec = @match decision[1] begin
        5  || 6  => @inbounds @set new_dec.chargedMovesPending[1] = ChargedAction(Int8(1), Int8(100))
        7  || 8  => @inbounds @set new_dec.chargedMovesPending[1] = ChargedAction(Int8(2), Int8(100))
        9  || 10 => @inbounds @set new_dec.switchesPending[1] = SwitchAction(Int8(1), Int8(0))
        11 || 12 => @inbounds @set new_dec.switchesPending[1] = SwitchAction(Int8(2), Int8(0))
        13 || 14 => @inbounds @set new_dec.switchesPending[1] = SwitchAction(Int8(3), Int8(0))
        15 || 16 => @inbounds @set new_dec.switchesPending[1] = SwitchAction(Int8(1), Int8(24))
        17 || 18 => @inbounds @set new_dec.switchesPending[1] = SwitchAction(Int8(2), Int8(24))
        19 || 20 => @inbounds @set new_dec.switchesPending[1] = SwitchAction(Int8(3), Int8(24))
        _        => new_dec
    end
    new_dec = @match decision[2] begin
        5  || 6  => @inbounds @set new_dec.chargedMovesPending[2] = ChargedAction(Int8(1), Int8(100))
        7  || 8  => @inbounds @set new_dec.chargedMovesPending[2] = ChargedAction(Int8(2), Int8(100))
        9  || 10 => @inbounds @set new_dec.switchesPending[2] = SwitchAction(Int8(1), Int8(0))
        11 || 12 => @inbounds @set new_dec.switchesPending[2] = SwitchAction(Int8(2), Int8(0))
        13 || 14 => @inbounds @set new_dec.switchesPending[2] = SwitchAction(Int8(3), Int8(0))
        15 || 16 => @inbounds @set new_dec.switchesPending[2] = SwitchAction(Int8(1), Int8(24))
        17 || 18 => @inbounds @set new_dec.switchesPending[2] = SwitchAction(Int8(2), Int8(24))
        19 || 20 => @inbounds @set new_dec.switchesPending[2] = SwitchAction(Int8(3), Int8(24))
        _        => new_dec
    end
    return next_state, new_dec
end

function play_turn(state::DynamicState, static_state::StaticState, decision::Tuple{Int64,Int64})
    next_state = state
    if next_state.fastMovesPending[1] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, Int8(1))
    end
    if next_state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, Int8(2))
    end
    next_state, dec = queue_decision(next_state, static_state, defaultDecision, decision)
    if dec.switchesPending[1].pokemon != Int8(0) || dec.switchesPending[2].pokemon != Int8(0)
        next_state = evaluate_switches(next_state, dec)
    end
    cmp = get_cmp(next_state, static_state, dec::Decision)
    if cmp != 0
        next_state = evaluate_charged_moves(next_state, static_state, cmp,
            dec.chargedMovesPending[cmp].move, dec.chargedMovesPending[cmp].charge, dec.shielding[get_other_agent(cmp)])
        dec.chargedMovesPending[cmp] = defaultCharge
    end
    cmp = get_cmp(next_state, static_state, dec::Decision)
    if cmp != 0
        next_state = evaluate_charged_moves(next_state, static_state, cmp,
            dec.chargedMovesPending[cmp].move, dec.chargedMovesPending[cmp].charge, dec.shielding[get_other_agent(cmp)])
    end
    next_state = step_timers(next_state)
    return next_state
end

function play_battle(starting_state::DynamicState, static_state::StaticState)
    state = starting_state
    while true
        weights1, weights2 = get_possible_decisions(state, static_state, 1), get_possible_decisions(state, static_state, 2)
        (sum(weights1) * sum(weights2) == 0) && return get_battle_score(state, static_state)
        decision1, decision2 = rand(Categorical(weights1 / sum(weights1))), rand(Categorical(weights2 / sum(weights2)))
        state = play_turn(state, static_state, (decision1, decision2))
    end
end

function get_battle_scores(starting_state::DynamicState, static_state::StaticState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

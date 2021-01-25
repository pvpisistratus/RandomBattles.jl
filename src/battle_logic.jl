using Distributions, Setfield, Match, StaticArrays

function get_possible_decisions(state::IndividualBattleState; allow_nothing = false)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    @inbounds return @SVector [((allow_nothing || activeMon.fastMoveCooldown > 0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                ((allow_nothing || activeMon.fastMoveCooldown > 0) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.fastMoveCooldown <= 0 && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.fastMoveCooldown <= 0 && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[1].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[1].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[2].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[2].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
end

function get_possible_decisions(state::State; allow_nothing = false)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    @inbounds return @SVector [((allow_nothing || activeMon.fastMoveCooldown > 0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                ((allow_nothing || activeMon.fastMoveCooldown > 0) && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.fastMoveCooldown <= 0 && activeMon.hp > 0) ? 1.0 : 0.0,
                                (activeMon.fastMoveCooldown <= 0 && activeTeam.shields > Int8(0) && activeMon.hp > 0) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[1].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[1].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[2].energy && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
                                (activeMon.energy >= activeMon.chargedMoves[2].energy && activeTeam.shields > Int8(0) && activeMon.hp > Int16(0)) ? 1.0 : 0.0,
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

function play_decision(state::BattleState, decision::Int64)
    @inbounds next_state = @set state.teams[state.agent].shielding = iseven(decision)
    next_state = @match decision begin
        3  || 4  => queue_fast_move(next_state)
        5  || 6  => queue_charged_move(next_state, Int8(1))
        7  || 8  => queue_charged_move(next_state, Int8(2))
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

function play_turn(state::BattleState, decision::Tuple{Int64,Int64})
    @inbounds next_state = play_decision(state, decision[1])
    @inbounds next_state = play_decision((@set next_state.agent = Int8(2)), decision[2])
    next_state = @set next_state.agent = Int8(1)

    if 9 in decision || 10 in decision || 11 in decision || 12 in decision ||
        13 in decision || 14 in decision || 15 in decision || 16 in decision ||
        17 in decision || 18 in decision || 19 in decision || 20 in decision
        next_state = evaluate_switches(next_state)
    end
    if 5 in decision || 6 in decision || 7 in decision || 8 in decision
        next_state = evaluate_charged_moves(next_state)
        next_state = evaluate_charged_moves(next_state)
    end
    if 3 in decision || 4 in decision
        next_state = evaluate_fast_moves(next_state)
    end
    next_state = step_timers(next_state)
    return next_state
end

function play_battle(initial_state::BattleState)
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

function get_battle_scores(initial_state::BattleState, N::Int64)
    return map(x -> play_battle(initial_state), 1:N)
end;

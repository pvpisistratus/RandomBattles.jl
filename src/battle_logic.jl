using Distributions, Setfield, Match

const possible_decisions = 20

function get_possible_decisions(state::BattleState; allow_nothing = false)
    decisions = zeros(possible_decisions)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    if activeMon.hp > 0
        @inbounds decisions[1] = 1
        @inbounds decisions[2] = 1
        if activeMon.fastMoveCooldown <= 0
            @inbounds decisions[3] = 1
            @inbounds decisions[4] = 1
            if !allow_nothing
                @inbounds decisions[1] = 0
                @inbounds decisions[2] = 0
            end
        end
        @inbounds if activeMon.energy >= activeMon.chargedMoves[1].energy &&
          activeMon.chargedMoves[1].moveType != 0
            @inbounds decisions[5] = 1
            @inbounds decisions[6] = 1
        end
        @inbounds if activeMon.energy >= activeMon.chargedMoves[2].energy &&
          activeMon.chargedMoves[2].moveType != 0
            @inbounds decisions[7] = 1
            @inbounds decisions[8] = 1
        end
        if typeof(state) != IndividualBattleState
            for i = 1:3
                if i != activeTeam.active &&
                   activeTeam.mons[i].hp != 0 && activeTeam.switchCooldown == 0
                    @inbounds decisions[2*i+7] = 1
                    @inbounds decisions[2*i+8] = 1
                end
            end
        end
    else
        if typeof(state) != IndividualBattleState
            for i = 1:3
                if i != activeTeam.active && activeTeam.mons[i].hp != 0
                    @inbounds decisions[2*i+13] = 1
                    @inbounds decisions[2*i+14] = 1
                end
            end
        end
    end
    return decisions
end

function get_possible_decisions(state::IndividualBattleState; allow_nothing = false)
    decisions = zeros(possible_decisions)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    activeMon.hp <= 0 && return decisions
    @inbounds decisions[1] = 1
    @inbounds decisions[2] = 1
    if activeMon.fastMoveCooldown <= 0
        @inbounds decisions[3] = 1
        @inbounds decisions[4] = 1
        if !allow_nothing
            @inbounds decisions[1] = 0
            @inbounds decisions[2] = 0
        end
    end
    @inbounds if activeMon.energy >= activeMon.chargedMoves[1].energy &&
      activeMon.chargedMoves[1].moveType != 0
        @inbounds decisions[5] = 1
        @inbounds decisions[6] = 1
    end
    @inbounds if activeMon.energy >= activeMon.chargedMoves[2].energy &&
      activeMon.chargedMoves[2].moveType != 0
        @inbounds decisions[7] = 1
        @inbounds decisions[8] = 1
    end
    return decisions
end

function get_possible_decisions(state::State; allow_nothing = false)
    decisions = zeros(possible_decisions)
    @inbounds activeTeam = state.teams[state.agent]
    @inbounds activeMon = activeTeam.mons[activeTeam.active]
    if activeMon.hp > 0
        @inbounds decisions[1] = 1
        @inbounds decisions[2] = 1
        if activeMon.fastMoveCooldown <= 0
            @inbounds decisions[3] = 1
            @inbounds decisions[4] = 1
            if !allow_nothing
                @inbounds decisions[1] = 0
                @inbounds decisions[2] = 0
            end
        end
        @inbounds if activeMon.energy >= activeMon.chargedMoves[1].energy &&
          activeMon.chargedMoves[1].moveType != 0
            @inbounds decisions[5] = 1
            @inbounds decisions[6] = 1
        end
        @inbounds if activeMon.energy >= activeMon.chargedMoves[2].energy &&
          activeMon.chargedMoves[2].moveType != 0
            @inbounds decisions[7] = 1
            @inbounds decisions[8] = 1
        end
        for i = 1:3
            if i != activeTeam.active &&
               activeTeam.mons[i].hp != 0 && activeTeam.switchCooldown == 0
                @inbounds decisions[2*i+7] = 1
                @inbounds decisions[2*i+8] = 1
            end
        end
    else
        for i = 1:3
            if i != activeTeam.active && activeTeam.mons[i].hp != 0
                @inbounds decisions[2*i+13] = 1
                @inbounds decisions[2*i+14] = 1
            end
        end
    end
    return decisions
end

function play_decision(state::BattleState, decision::Int64)
    next_state = state
    if iseven(decision)
        @inbounds next_state = @set next_state.teams[next_state.agent].shielding = true
    else
        @inbounds next_state = @set next_state.teams[next_state.agent].shielding = false
    end
    next_state = @match decision begin
        3  || 4  => queue_fast_move(next_state)
        5  || 6  => queue_charged_move(next_state, 1)
        7  || 8  => queue_charged_move(next_state, 2)
        9  || 10 => queue_switch(next_state, 1)
        11 || 12 => queue_switch(next_state, 2)
        13 || 14 => queue_switch(next_state, 3)
        15 || 16 => queue_switch(next_state, 1, time = 12_000)
        17 || 18 => queue_switch(next_state, 2, time = 12_000)
        19 || 20 => queue_switch(next_state, 3, time = 12_000)
        _        => next_state
    end

    return next_state
end

function play_turn(state::BattleState, decision::Tuple{Int64,Int64})
    @inbounds next_state = play_decision(state, decision[1])
    @inbounds next_state = play_decision(@set next_state.agent = 2, decision[2])
    next_state = @set next_state.agent = 1

    if !isnothing(findfirst(in(9:20), decision))
        next_state = evaluate_switches(next_state)
    end
    if !isnothing(findfirst(in([5, 6, 7, 8]), decision))
        next_state = evaluate_charged_moves(next_state)
        next_state = evaluate_charged_moves(next_state)
    end
    if !isnothing(findfirst(in([3, 4]), decision))
        next_state = evaluate_fast_moves(next_state)
    end
    return step_timers(next_state)
end

function play_battle(initial_state::BattleState)
    state = initial_state
    while true
        weights1 = get_possible_decisions(state)
        weights2 = get_possible_decisions(@set state.agent = 2)
        @inbounds weights1[9:14] /= 2
        @inbounds weights2[9:14] /= 2
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

using Distributions, JSON, StaticArrays, Setfield

function get_battle_score(state::State)
    return (0.5 * (state.teams[1].mons[1].hp + state.teams[1].mons[2].hp +
             state.teams[1].mons[3].hp) /
            (state.teams[1].mons[1].stats.hitpoints +
             state.teams[1].mons[2].stats.hitpoints +
             state.teams[1].mons[3].stats.hitpoints)) +
           (0.5 * (state.teams[2].mons[1].stats.hitpoints -
             state.teams[2].mons[1].hp +
             state.teams[2].mons[2].stats.hitpoints -
             state.teams[2].mons[2].hp +
             state.teams[2].mons[3].stats.hitpoints -
             state.teams[2].mons[3].hp) /
            (state.teams[2].mons[1].stats.hitpoints +
             state.teams[2].mons[2].stats.hitpoints +
             state.teams[2].mons[3].stats.hitpoints))
end

function get_weights(state)
    weights = zeros(8)
    activeTeam = state.teams[state.agent]
    activeMon = activeTeam.mons[activeTeam.active]
    switchTo = 0
    if activeMon.hp > 0
        weights[1] = 1.0
        if activeMon.fastMoveCooldown == 0
            weights[2] = 1.0
        end
        if activeMon.energy >= activeMon.chargedMoves[1].energy
            weights[3] = 1.0
        end
        if activeMon.energy >= activeMon.chargedMoves[2].energy
            weights[4] = 1.0
        end
        switchTo = rand(DiscreteUniform(1, 3))
        if switchTo != activeTeam.active &&
           activeTeam.mons[switchTo].hp != 0 &&
           activeTeam.switchCooldown == 0
            weights[5] = 1.0
        end
    else
        for i = 1:3
            if i != activeTeam.active &&
               activeTeam.mons[i].hp != 0
                weights[i+5] = 1.0
            end
        end
    end
    if sum(weights) > 0
        weights ./= sum(weights)
    end
    return weights, switchTo
end

function get_possible_decisions(state)
    decisions = []
    activeTeam = state.teams[state.agent]
    activeMon = activeTeam.mons[activeTeam.active]
    if activeMon.hp > 0
        push!(decisions, 1)
        push!(decisions, 2)
        if activeMon.fastMoveCooldown == 0
            push!(decisions, 3)
            push!(decisions, 4)
        end
        if activeMon.energy >= activeMon.chargedMoves[1].energy
            push!(decisions, 5)
            push!(decisions, 6)
        end
        if activeMon.energy >= activeMon.chargedMoves[2].energy
            push!(decisions, 7)
            push!(decisions, 8)
        end
        for i = 1:3
            if i != activeTeam.active &&
               activeTeam.mons[i].hp != 0 && activeTeam.switchCooldown == 0
                push!(decisions, 2 * i + 7)
                push!(decisions, 2 * i + 8)
            end
        end
    else
        for i = 1:3
            if i != activeTeam.active && activeTeam.mons[i].hp != 0
                push!(decisions, 2 * i + 13)
                push!(decisions, 2 * i + 14)
            end
        end
    end
    return decisions
end

function play_decision(state, decision, switchTo)
    if decision == 1
        next_state = do_nothing(state)
    elseif decision == 2
        next_state = do_fast_move(state)
    elseif decision == 3
        next_state = do_charged_move(state, 1)
    elseif decision == 4
        next_state = do_charged_move(state, 2)
    elseif decision == 5
        next_state = do_unforced_switch(state, switchTo)
    elseif decision == 6
        next_state = do_forced_switch(state, 1)
    elseif decision == 7
        next_state = do_forced_switch(state, 2)
    else
        next_state = do_forced_switch(state, 3)
    end
    return next_state
end

function play_decision(state, decision)
    next_state = state
    if iseven(decision)
        next_state = @set next_state.teams[next_state.agent].shielding = true
    else
        next_state = @set next_state.teams[next_state.agent].shielding = false
    end
    if 1 <= decision <= 2
        next_state = do_nothing(state)
    elseif decision <= 4
        next_state = do_fast_move(state)
    elseif decision <= 6
        next_state = do_charged_move(state, 1)
    elseif decision <= 8
        next_state = do_charged_move(state, 2)
    elseif decision <= 10
        next_state = do_unforced_switch(state, 1)
    elseif decision <= 12
        next_state = do_unforced_switch(state, 2)
    elseif decision <= 14
        next_state = do_unforced_switch(state, 3)
    elseif decision <= 16
        next_state = do_forced_switch(state, 1)
    elseif decision <= 18
        next_state = do_forced_switch(state, 2)
    elseif decision <= 20
        next_state = do_forced_switch(state, 3)
    end

    return next_state
end

function get_battle_scores(initial_state::State, N)
    scores = zeros(N)
    for i = 1:N
        state = initial_state
        while true
            weights, switchTo = get_weights(state)
            if sum(weights) == 0
                break
            end
            decision = rand(Categorical(weights))
            state = play_decision(state, decision, switchTo)
            if state.agent == 1
                state = @set state.switchPending = SwitchAction(0, 0)
                state = @set state.chargedMovePending = ChargedAction(
                    Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 1),
                    0,
                )
                state = @set state.teams[1].shielding = rand(Bool)
                state = @set state.teams[2].shielding = rand(Bool)
            end
        end
        scores[i] = get_battle_score(state)
    end
    return scores
end;

using Distributions, JSON, CSV, StaticArrays, Setfield

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

function get_battle_scores(initial_state::State, N)
    scores = zeros(N)
    weights = zeros(8)
    for i = 1:N
        state = initial_state
        while true
            if state.teams[state.agent].mons[state.teams[state.agent].active].hp > 0
                weights[1] = 1.0
                if state.teams[state.agent].mons[state.teams[state.agent].active].fastMoveCooldown == 0
                    weights[2] = 1.0
                    #weights[1] = 0.0
                end
                if state.teams[state.agent].mons[state.teams[state.agent].active].energy >= state.teams[state.agent].mons[state.teams[state.agent].active].chargedMoves[1].energy
                    weights[3] = 1.0
                else
                    weights[3] = 0.0
                end
                if state.teams[state.agent].mons[state.teams[state.agent].active].energy >= state.teams[state.agent].mons[state.teams[state.agent].active].chargedMoves[2].energy
                    weights[4] = 1.0
                else
                    weights[4] = 0.0
                end
                switchTo = rand(DiscreteUniform(1, 3))
                if switchTo != state.teams[state.agent].active &&
                   state.teams[state.agent].mons[switchTo].hp != 0 &&
                   state.teams[state.agent].switchCooldown == 0
                    weights[5] = 1.0
                else
                    weights[5] = 0.0
                end
            else
                weights[1:5] = zeros(5)
                for i = 1:3
                    if i != state.teams[state.agent].active &&
                       state.teams[state.agent].mons[i].hp != 0
                        weights[i+5] = 1.0
                    else
                        weights[i+5] = 0.0
                    end
                end
                if sum(weights) == 0.0
                    #println("Game over")
                    break
                end
            end
            weights ./= sum(weights)
            decision = rand(Categorical(weights))
            if decision == 1
                state = do_nothing(state)
            elseif decision == 2
                state = do_fast_move(state)
            elseif decision == 3
                state = do_charged_move(state, 1)
            elseif decision == 4
                state = do_charged_move(state, 2)
            elseif decision == 5
                state = do_unforced_switch(state, switchTo)
            elseif decision == 6
                state = do_forced_switch(state, 1)
            elseif decision == 7
                state = do_forced_switch(state, 2)
            else
                state = do_forced_switch(state, 3)
            end
            if state.agent == 1
                state = @set state.switchPending = SwitchAction(0, 0)
                state = @set state.chargedMovePending = ChargedAction(
                    Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 1),
                    0,
                )
            end
        end
        scores[i] = get_battle_score(state)
    end
    return scores
end;

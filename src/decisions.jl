using Setfield

function do_nothing(state::State)
    if state.agent == 1
        state = @set state.agent = 2
    else
        state = @set state.agent = 1
        state = @set state.teams[1].mons[state.teams[1].active].fastMoveCooldown = max(
            0,
            state.teams[1].mons[state.teams[1].active].fastMoveCooldown - 500,
        )
        state = @set state.teams[2].mons[state.teams[2].active].fastMoveCooldown = max(
            0,
            state.teams[2].mons[state.teams[2].active].fastMoveCooldown - 500,
        )
        if state.switchPending.pokemon != 0
            state = @set state.teams[1].active = state.switchPending.pokemon
            state = @set state.teams[1].buffs = StatBuffs(0, 0)
            if state.switchPending.time != 0
                state = @set state.teams[2].switchCooldown = max(
                    0,
                    state.teams[2].switchCooldown - state.switchPending.time -
                    500,
                )
            else
                state = @set state.teams[1].switchCooldown = 60000
            end
        end
        state = @set state.teams[1].switchCooldown = max(
            0,
            state.teams[1].switchCooldown - 500,
        )
        state = @set state.teams[2].switchCooldown = max(
            0,
            state.teams[2].switchCooldown - 500,
        )
        if state.chargedMovePending.move.moveType != 0
            state = apply_buffs(state)
            state = @set state.teams[1].mons[state.teams[1].active].energy -= state.chargedMovePending.move.energy
            state = @set state.teams[1].switchCooldown = max(
                0,
                state.teams[1].switchCooldown - 10000,
            )
            state = @set state.teams[2].switchCooldown = max(
                0,
                state.teams[2].switchCooldown - 10000,
            )
            if state.teams[2].shields > 0 && state.teams[2].shielding
                state = @set state.teams[2].shields -= 1
            else
                state = @set state.teams[2].mons[state.teams[2].active].hp = max(
                    0,
                    state.teams[2].mons[state.teams[2].active].hp -
                    calculate_damage(
                        state.teams[1].mons[state.teams[1].active],
                        state.teams[1].buffs.atk,
                        state.teams[2].mons[state.teams[2].active],
                        state.teams[2].buffs.def,
                        state.chargedMovePending.move,
                        state.chargedMovePending.charge,
                    ),
                )
            end
        end
    end
    return state
end

function do_fast_move(state::State)
    if state.agent == 1
        state = @set state.teams[1].mons[state.teams[1].active].fastMoveCooldown = state.teams[1].mons[state.teams[1].active].fastMove.cooldown
        state = @set state.teams[1].mons[state.teams[1].active].energy += state.teams[1].mons[state.teams[1].active].fastMove.energy
        state = @set state.teams[2].mons[state.teams[2].active].hp = max(
            0,
            state.teams[2].mons[state.teams[2].active].hp - calculate_damage(
                state.teams[1].mons[state.teams[1].active],
                state.teams[1].buffs.atk,
                state.teams[2].mons[state.teams[2].active],
                state.teams[2].buffs.def,
                state.teams[1].mons[state.teams[1].active].fastMove,
                1.0,
            ),
        )
        state = @set state.agent = 2
    else
        state = @set state.agent = 1
        state = @set state.teams[2].mons[state.teams[2].active].fastMoveCooldown = state.teams[2].mons[state.teams[2].active].fastMove.cooldown
        state = @set state.teams[2].mons[state.teams[2].active].energy += state.teams[2].mons[state.teams[2].active].fastMove.energy
        state = @set state.teams[1].mons[state.teams[1].active].hp = max(
            0,
            state.teams[1].mons[state.teams[1].active].hp - calculate_damage(
                state.teams[2].mons[state.teams[2].active],
                state.teams[2].buffs.atk,
                state.teams[1].mons[state.teams[1].active],
                state.teams[1].buffs.def,
                state.teams[2].mons[state.teams[2].active].fastMove,
                1.0,
            ),
        )
        state = @set state.teams[1].mons[state.teams[1].active].fastMoveCooldown = max(
            0,
            state.teams[1].mons[state.teams[1].active].fastMoveCooldown - 500,
        )
        state = @set state.teams[2].mons[state.teams[2].active].fastMoveCooldown = max(
            0,
            state.teams[2].mons[state.teams[2].active].fastMoveCooldown - 500,
        )
        if state.switchPending.pokemon != 0
            state = @set state.teams[1].active = state.switchPending.pokemon
            state = @set state.teams[1].buffs = StatBuffs(0, 0)
            if state.switchPending.time != 0
                state = @set state.teams[2].switchCooldown = max(
                    0,
                    state.teams[2].switchCooldown - state.switchPending.time -
                    500,
                )
            else
                state = @set state.teams[1].switchCooldown = 60000
            end
        end
        state = @set state.teams[1].switchCooldown = max(
            0,
            state.teams[1].switchCooldown - 500,
        )
        state = @set state.teams[2].switchCooldown = max(
            0,
            state.teams[2].switchCooldown - 500,
        )
        if state.chargedMovePending.move.moveType != 0
            state = apply_buffs(state)
            state = @set state.teams[1].mons[state.teams[1].active].energy -= state.chargedMovePending.move.energy
            state = @set state.teams[1].switchCooldown = max(
                0,
                state.teams[1].switchCooldown - 10000,
            )
            state = @set state.teams[2].switchCooldown = max(
                0,
                state.teams[2].switchCooldown - 10000,
            )
            if state.teams[2].shields > 0 && state.teams[2].shielding
                state = @set state.teams[2].shields -= 1
            else
                state = @set state.teams[2].mons[state.teams[2].active].hp = max(
                    0,
                    state.teams[2].mons[state.teams[2].active].hp -
                    calculate_damage(
                        state.teams[1].mons[state.teams[1].active],
                        state.teams[1].buffs.atk,
                        state.teams[2].mons[state.teams[2].active],
                        state.teams[2].buffs.def,
                        state.chargedMovePending.move,
                        state.chargedMovePending.charge,
                    ),
                )
            end
        end
    end
    return state
end

function do_charged_move(state::State, move::Integer)
    if state.agent == 1
        state = @set state.chargedMovePending = ChargedAction(
            state.teams[1].mons[state.teams[1].active].chargedMoves[move],
            1,
        )
        state = @set state.agent = 2
    else
        if state.chargedMovePending.move.moveType == 0 ||
           state.teams[2].mons[state.teams[2].active].stats.attack > state.teams[1].mons[state.teams[1].active].stats.attack ||
           (state.teams[2].mons[state.teams[2].active].stats.attack == state.teams[1].mons[state.teams[1].active].stats.attack &&
            rand((true, false)))
            state = @set state.teams[1].mons[state.teams[1].active].fastMoveCooldown = max(
                0,
                state.teams[1].mons[state.teams[1].active].fastMoveCooldown -
                500,
            )
            state = @set state.teams[2].mons[state.teams[2].active].fastMoveCooldown = max(
                0,
                state.teams[2].mons[state.teams[2].active].fastMoveCooldown -
                500,
            )
            if state.switchPending.pokemon != 0
                state = @set state.teams[1].active = state.switchPending.pokemon
                state = @set state.teams[1].buffs = StatBuffs(0, 0)
                if state.switchPending.time != 0
                    state = @set state.teams[2].switchCooldown = max(
                        0,
                        state.teams[2].switchCooldown -
                        state.switchPending.time - 500,
                    )
                else
                    state = @set state.teams[1].switchCooldown = 60000
                end
            end
            state = @set state.teams[1].switchCooldown = max(
                0,
                state.teams[1].switchCooldown - 500,
            )
            state = @set state.teams[2].switchCooldown = max(
                0,
                state.teams[2].switchCooldown - 500,
            )
            state = @set state.chargedMovePending = ChargedAction(
                state.teams[2].mons[state.teams[2].active].chargedMoves[move],
                1,
            )
            state = apply_buffs(state)
            state = @set state.teams[2].mons[state.teams[2].active].energy -= state.chargedMovePending.move.energy
            state = @set state.teams[1].switchCooldown = max(
                0,
                state.teams[1].switchCooldown - 10000,
            )
            state = @set state.teams[2].switchCooldown = max(
                0,
                state.teams[2].switchCooldown - 10000,
            )
            if state.teams[1].shields > 0 && state.teams[1].shielding
                state = @set state.teams[1].shields -= 1
            else
                state = @set state.teams[1].mons[state.teams[1].active].hp = max(
                    0,
                    state.teams[1].mons[state.teams[1].active].hp -
                    calculate_damage(
                        state.teams[2].mons[state.teams[2].active],
                        state.teams[2].buffs.atk,
                        state.teams[1].mons[state.teams[1].active],
                        state.teams[1].buffs.def,
                        state.teams[2].mons[state.teams[2].active].chargedMoves[move],
                        1.0,
                    ),
                )
            end
            state = @set state.agent = 1
        else
            state = @set state.agent = 1
            state = apply_buffs(state)
            state = @set state.teams[1].mons[state.teams[1].active].energy -= state.chargedMovePending.move.energy
            state = @set state.teams[1].switchCooldown = max(
                0,
                state.teams[1].switchCooldown - 10000,
            )
            state = @set state.teams[2].switchCooldown = max(
                0,
                state.teams[2].switchCooldown - 10000,
            )
            if state.teams[2].shields > 0 && state.teams[2].shielding
                state = @set state.teams[2].shields -= 1
            else
                state = @set state.teams[2].mons[state.teams[2].active].hp = max(
                    0,
                    state.teams[2].mons[state.teams[2].active].hp -
                    calculate_damage(
                        state.teams[1].mons[state.teams[1].active],
                        state.teams[1].buffs.atk,
                        state.teams[2].mons[state.teams[2].active],
                        state.teams[2].buffs.def,
                        state.chargedMovePending.move,
                        state.chargedMovePending.charge,
                    ),
                )
            end
        end
    end
    return state
end

function do_forced_switch(state::State, switchTo::Int64)
    #  Active pokemon fainted (choice of time between 0 and 12 seconds)
    if state.agent == 1
        state = @set state.agent = 2
        state = @set state.switchPending = SwitchAction(switchTo, 500 * 25)
    else
        state = @set state.teams[2].active = switchTo
        state = @set state.teams[2].buffs = StatBuffs(0, 0)
        switchTime = 500 * 25
        state = @set state.teams[2].switchCooldown = 60000 - switchTime
        state = @set state.teams[1].switchCooldown = max(
            0,
            state.teams[1].switchCooldown - switchTime,
        )
        state = @set state.agent = 1
    end
    return state
end

function do_unforced_switch(state::State, switchTo::Int64)
    #  Switch timer at zero (no choice in time, always zero)
    if state.agent == 1
        state = @set state.switchPending = SwitchAction(switchTo, 0)
        state = @set state.agent = 2
    else
        state = @set state.teams[2].active = switchTo
        state = @set state.teams[2].buffs = StatBuffs(0, 0)
        state = @set state.teams[2].switchCooldown = 55500
        if state.switchPending.pokemon != 0
            state = @set state.teams[1].active = state.switchPending.pokemon
            state = @set state.teams[1].buffs = StatBuffs(0, 0)
            if state.switchPending.time != 0
                state = @set state.teams[2].switchCooldown = max(
                    0,
                    state.teams[2].switchCooldown - state.switchPending.time -
                    500,
                )
            else
                state = @set state.teams[1].switchCooldown = 60000
            end
        end
        state = @set state.teams[1].switchCooldown = max(
            0,
            state.teams[1].switchCooldown - 500,
        )
        state = @set state.teams[1].mons[state.teams[1].active].fastMoveCooldown = max(
            0,
            state.teams[1].mons[state.teams[1].active].fastMoveCooldown - 500,
        )
        state = @set state.teams[2].mons[state.teams[2].active].fastMoveCooldown = max(
            0,
            state.teams[2].mons[state.teams[2].active].fastMoveCooldown - 500,
        )
        state = @set state.agent = 1
    end
    return state
end

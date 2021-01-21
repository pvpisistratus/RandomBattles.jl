using Setfield

function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    @inbounds  return type_effectiveness[defenderTypes[1], moveType] *
           type_effectiveness[defenderTypes[2], moveType]
end

function get_buff_modifier(buff::Int8)
    @inbounds  return buff > 0 ?
           (gamemaster["settings"]["buffDivisor"] + buff) /
           gamemaster["settings"]["buffDivisor"] :
           gamemaster["settings"]["buffDivisor"] /
           (gamemaster["settings"]["buffDivisor"] - buff)
end

function calculate_damage(
    attacker::Pokemon,
    atkBuff::Int8,
    defender::Pokemon,
    defBuff::Int8,
    move::Move,
    charge::Float64,
)
     return floor(move.power * move.stab *
         ((attacker.stats.attack * get_buff_modifier(atkBuff)) /
          (defender.stats.defense * get_buff_modifier(defBuff))) *
         get_effectiveness(defender.types, move.moveType) * charge *
         0.5 * 1.3) + 1
end

function queue_fast_move(state::BattleState; agent::Int64 = state.agent)
    @inbounds next_state = @set state.fastMovesPending[agent] = true
    return next_state
end

function queue_charged_move(state::BattleState, move::Int64)
    @inbounds next_state = @set state.chargedMovesPending[state.agent] = ChargedAction(
        state.teams[state.agent].mons[state.teams[state.agent].active].chargedMoves[move],
        1,
    )
    return next_state
end

function queue_switch(state::BattleState, switchTo::Int64; time::Int64 = 0)
    @inbounds next_state = @set state.switchesPending[state.agent] = SwitchAction(
        switchTo,
        time,
    )
    return next_state
end

function get_cmp(state::BattleState)
    @inbounds charges = state.chargedMovesPending[1].charge,
        state.chargedMovesPending[2].charge
    @inbounds charges[1] == 0 && charges[2] == 0 && return 0
    @inbounds hps = state.teams[1].mons[state.teams[1].active].hp,
        state.teams[2].mons[state.teams[2].active].hp
    @inbounds charges[1] != 0 && charges[2] == 0 && hps[2] > 0 && return 1
    @inbounds charges[1] == 0 && charges[2] != 0 && hps[1] > 0 && return 2
    @inbounds attacks = state.teams[1].mons[state.teams[1].active].stats.attack,
        state.teams[2].mons[state.teams[2].active].stats.attack
    @inbounds attacks[1] > attacks[2] && return 1
    @inbounds attacks[1] < attacks[2] && return 2
    return rand(1:2)
end

function apply_buffs(state::BattleState, cmp::Int64)
    next_state = state
    @inbounds if rand(Uniform(0, 1)) < next_state.chargedMovesPending[cmp].move.buffChance
        @inbounds  next_state = @set next_state.teams[get_other_agent(cmp)].buffs.atk = clamp(
            next_state.teams[get_other_agent(cmp)].buffs.atk +
            next_state.chargedMovesPending[cmp].move.oppAtkModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
        @inbounds  next_state = @set next_state.teams[get_other_agent(cmp)].buffs.def = clamp(
            next_state.teams[get_other_agent(cmp)].buffs.def +
            next_state.chargedMovesPending[cmp].move.oppDefModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
        @inbounds  next_state = @set next_state.teams[cmp].buffs.atk = clamp(
            next_state.teams[cmp].buffs.atk +
            next_state.chargedMovesPending[cmp].move.selfAtkModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
        @inbounds  next_state = @set next_state.teams[cmp].buffs.def = clamp(
            next_state.teams[cmp].buffs.def +
            next_state.chargedMovesPending[cmp].move.selfDefModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
    end
    return next_state
end

function evaluate_fast_moves(state::BattleState)
    next_state = state
    @inbounds if next_state.fastMovesPending[1]
        @inbounds next_state = @set next_state.teams[1].mons[next_state.teams[1].active].fastMoveCooldown =
            next_state.teams[1].mons[next_state.teams[1].active].fastMove.cooldown
        @inbounds  next_state = @set next_state.teams[1].mons[next_state.teams[1].active].energy =
            min(next_state.teams[1].mons[next_state.teams[1].active].energy +
                next_state.teams[1].mons[next_state.teams[1].active].fastMove.energy, 100)
        @inbounds  next_state = @set next_state.teams[2].mons[next_state.teams[2].active].hp = max(
            0,
            next_state.teams[2].mons[next_state.teams[2].active].hp -
            calculate_damage(
                next_state.teams[1].mons[next_state.teams[1].active],
                next_state.teams[1].buffs.atk,
                next_state.teams[2].mons[next_state.teams[2].active],
                next_state.teams[2].buffs.def,
                next_state.teams[1].mons[next_state.teams[1].active].fastMove,
                1.0,
            ),
        )
        @inbounds next_state = @set next_state.fastMovesPending[1] = false
    end
    @inbounds if next_state.fastMovesPending[2]
        @inbounds next_state = @set next_state.teams[2].mons[next_state.teams[2].active].fastMoveCooldown =
            next_state.teams[2].mons[next_state.teams[2].active].fastMove.cooldown
        @inbounds  next_state = @set next_state.teams[2].mons[next_state.teams[2].active].energy =
            min(next_state.teams[2].mons[next_state.teams[2].active].energy +
                next_state.teams[2].mons[next_state.teams[2].active].fastMove.energy, 100)
        @inbounds  next_state = @set next_state.teams[1].mons[next_state.teams[1].active].hp = max(
            0,
            next_state.teams[1].mons[next_state.teams[1].active].hp -
            calculate_damage(
                next_state.teams[2].mons[next_state.teams[2].active],
                next_state.teams[2].buffs.atk,
                next_state.teams[1].mons[next_state.teams[1].active],
                next_state.teams[1].buffs.def,
                next_state.teams[2].mons[next_state.teams[2].active].fastMove,
                1.0,
            ),
        )
        @inbounds next_state = @set next_state.fastMovesPending[2] = false
    end
    return next_state
end

function evaluate_charged_moves(state::BattleState)
    cmp = get_cmp(state)
    next_state = state
    if cmp > 0
        @inbounds next_state = @set next_state.teams[cmp].mons[state.teams[cmp].active].energy -=
            next_state.chargedMovesPending[cmp].move.energy
        @inbounds next_state = @set next_state.teams[1].switchCooldown = max(
            0,
            next_state.teams[1].switchCooldown - 10000,
        )
        @inbounds next_state = @set next_state.teams[2].switchCooldown = max(
            0,
            next_state.teams[2].switchCooldown - 10000,
        )
        @inbounds if next_state.teams[get_other_agent(cmp)].shields > 0 &&
            next_state.teams[get_other_agent(cmp)].shielding
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].shields -= 1
        else
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active].hp = max(
                0,
                next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active].hp - calculate_damage(
                    next_state.teams[cmp].mons[next_state.teams[cmp].active],
                    next_state.teams[cmp].buffs.atk,
                    next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active],
                    next_state.teams[get_other_agent(cmp)].buffs.def,
                    next_state.chargedMovesPending[cmp].move,
                    next_state.chargedMovesPending[cmp].charge,
                ),
            )
        end
        next_state = apply_buffs(next_state, cmp)
        next_state = queue_fast_move(next_state, agent = get_other_agent(cmp))
        @inbounds next_state = @set next_state.chargedMovesPending[cmp] =
            ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0)
    end
    return next_state
end

function evaluate_switches(state::BattleState)
    next_state = state
    @inbounds if next_state.switchesPending[1].pokemon != 0
        @inbounds next_state = @set next_state.teams[1].active = next_state.switchesPending[1].pokemon
        @inbounds next_state = @set next_state.teams[1].buffs = StatBuffs(0, 0)
        @inbounds if next_state.switchesPending[1].time != 0
            @inbounds  next_state = @set next_state.teams[2].switchCooldown = max(
                0,
                next_state.teams[2].switchCooldown - next_state.switchesPending[1].time - 500,
            )
        else
            @inbounds next_state = @set next_state.teams[1].switchCooldown = 60000
        end
        @inbounds next_state = @set next_state.switchesPending[1] = SwitchAction(0, 0)
    end

    @inbounds if next_state.switchesPending[2].pokemon != 0
        @inbounds next_state = @set next_state.teams[2].active = next_state.switchesPending[2].pokemon
        @inbounds next_state = @set next_state.teams[2].buffs = StatBuffs(0, 0)
        @inbounds if next_state.switchesPending[2].time != 0
            @inbounds  next_state = @set next_state.teams[1].switchCooldown = max(
                0,
                next_state.teams[1].switchCooldown - next_state.switchesPending[2].time - 500,
            )
        else
            @inbounds next_state = @set next_state.teams[2].switchCooldown = 60000
        end
        @inbounds next_state = @set next_state.switchesPending[2] = SwitchAction(0, 0)
    end
    return next_state
end

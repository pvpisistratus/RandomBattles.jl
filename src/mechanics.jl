using Setfield

function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    @inbounds return type_effectiveness[defenderTypes[1], moveType] *
            type_effectiveness[defenderTypes[2], moveType]
end

function get_buff_modifier(buff::Int8)
    @inbounds return buff >= Int8(0) ? (buff == Int8(0) ? 12 : (4 + buff) * 3) : 48 ÷ (4 - buff)
end

function calculate_damage(
    attacker::Pokemon,
    atkBuff::Int8,
    defender::Pokemon,
    defBuff::Int8,
    move::Move,
    charge::Int8,
)
    return Int16((Int64(move.power) * Int64(move.stab) *
        Int64(attacker.stats.attack) * Int64(get_buff_modifier(atkBuff)) *
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(get_buff_modifier(defBuff)) * 1_280_000_000) + 1)
end

function queue_fast_move(state::BattleState; agent::Int8 = state.agent)
    @inbounds return @set state.fastMovesPending[agent] = true
end

function queue_charged_move(state::BattleState, move::Int8)
    @inbounds return @set state.chargedMovesPending[state.agent] = ChargedAction(move, 100)
end

function queue_switch(state::BattleState, switchTo::Int8; time::Int8 = Int8(0))
    @inbounds return @set state.switchesPending[state.agent] = SwitchAction(switchTo, time)
end

function get_cmp(state::BattleState)
    @inbounds charges = state.chargedMovesPending[1].charge,
        state.chargedMovesPending[2].charge
    @inbounds charges[1] == Int8(0) && charges[2] == Int8(0) && return Int8(0)
    @inbounds hps = state.teams[1].mons[state.teams[1].active].hp,
        state.teams[2].mons[state.teams[2].active].hp
    @inbounds charges[1] != Int8(0) && charges[2] == Int8(0) && hps[2] > Int8(0) && return Int8(1)
    @inbounds charges[1] == Int8(0) && charges[2] != Int8(0) && hps[1] > Int8(0) && return Int8(2)
    @inbounds attacks = state.teams[1].mons[state.teams[1].active].stats.attack,
        state.teams[2].mons[state.teams[2].active].stats.attack
    @inbounds attacks[1] > attacks[2] && return Int8(1)
    @inbounds attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function apply_buffs(state::BattleState, cmp::Int8)
    next_state = state
    @inbounds if rand(Int8(1):Int8(100)) < next_state.chargedMovesPending[cmp].move.buffChance
        @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buffs.atk = clamp(
            next_state.teams[get_other_agent(cmp)].buffs.atk +
            next_state.chargedMovesPending[cmp].move.oppAtkModifier,
            Int8(-4),
            Int8(4),
        )
        @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buffs.def = clamp(
            next_state.teams[get_other_agent(cmp)].buffs.def +
            next_state.chargedMovesPending[cmp].move.oppDefModifier,
            Int8(-4),
            Int8(4),
        )
        @inbounds next_state = @set next_state.teams[cmp].buffs.atk = clamp(
            next_state.teams[cmp].buffs.atk +
            next_state.chargedMovesPending[cmp].move.selfAtkModifier,
            Int8(-4),
            Int8(4),
        )
        @inbounds next_state = @set next_state.teams[cmp].buffs.def = clamp(
            next_state.teams[cmp].buffs.def +
            next_state.chargedMovesPending[cmp].move.selfDefModifier,
            Int8(-4),
            Int8(4),
        )
    end
    return next_state
end

function evaluate_fast_moves(state::BattleState)
    next_state = state
    @inbounds if next_state.fastMovesPending[1]
        @inbounds next_state = @set next_state.teams[1].mons[next_state.teams[1].active].fastMoveCooldown =
            next_state.teams[1].mons[next_state.teams[1].active].fastMove.cooldown
        @inbounds next_state = @set next_state.teams[1].mons[next_state.teams[1].active].energy =
            min(next_state.teams[1].mons[next_state.teams[1].active].energy +
                next_state.teams[1].mons[next_state.teams[1].active].fastMove.energy, Int8(100))
        @inbounds next_state = @set next_state.teams[2].mons[next_state.teams[2].active].hp = max(
            Int16(0),
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
        @inbounds next_state = @set next_state.teams[2].mons[next_state.teams[2].active].energy =
            min(next_state.teams[2].mons[next_state.teams[2].active].energy +
                next_state.teams[2].mons[next_state.teams[2].active].fastMove.energy, Int8(100))
        @inbounds next_state = @set next_state.teams[1].mons[next_state.teams[1].active].hp = max(
            Int16(0),
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
    if cmp > Int8(0)
        move = next_state.teams[cmp].mons[state.teams[cmp].active].chargedMoves[next_state.chargedMovesPending[cmp].move]
        @inbounds next_state = @set next_state.teams[cmp].mons[state.teams[cmp].active].energy -= move.energy
        @inbounds next_state = @set next_state.teams[1].switchCooldown = max(Int8(0), next_state.teams[1].switchCooldown - Int8(20))
        @inbounds next_state = @set next_state.teams[2].switchCooldown = max(Int8(0), next_state.teams[2].switchCooldown - Int8(20))
        @inbounds if next_state.teams[get_other_agent(cmp)].shields > Int8(0) && next_state.teams[get_other_agent(cmp)].shielding
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].shields -= Int8(1)
        else
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active].hp = max(
                Int16(0),
                next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active].hp - calculate_damage(
                    next_state.teams[cmp].mons[next_state.teams[cmp].active],
                    next_state.teams[cmp].buffs.atk,
                    next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active],
                    next_state.teams[get_other_agent(cmp)].buffs.def,
                    move,
                    next_state.chargedMovesPending[cmp].charge,
                ),
            )
        end
        next_state = apply_buffs(next_state, cmp)
        next_state = queue_fast_move(next_state, agent = get_other_agent(cmp))
        @inbounds next_state = @set next_state.chargedMovesPending[cmp] = defaultCharge
    end
    return next_state
end

function evaluate_switches(state::BattleState)
    next_state = state
    @inbounds if next_state.switchesPending[1].pokemon != Int8(0)
        @inbounds next_state = @set next_state.teams[1].active = next_state.switchesPending[1].pokemon
        @inbounds next_state = @set next_state.teams[1].buffs = defaultBuff
        @inbounds if next_state.switchesPending[1].time != Int8(0)
            @inbounds next_state = @set next_state.teams[2].switchCooldown = max(
                Int8(0),
                next_state.teams[2].switchCooldown - next_state.switchesPending[1].time - Int8(1),
            )
        else
            @inbounds next_state = @set next_state.teams[1].switchCooldown = Int8(120)
        end
        @inbounds next_state = @set next_state.switchesPending[1] = defaultSwitch
    end

    @inbounds if next_state.switchesPending[2].pokemon != Int8(0)
        @inbounds next_state = @set next_state.teams[2].active = next_state.switchesPending[2].pokemon
        @inbounds next_state = @set next_state.teams[2].buffs = defaultBuff
        @inbounds if next_state.switchesPending[2].time != Int8(0)
            @inbounds next_state = @set next_state.teams[1].switchCooldown = max(
                Int8(0),
                next_state.teams[1].switchCooldown - next_state.switchesPending[2].time - Int8(1),
            )
        else
            @inbounds next_state = @set next_state.teams[2].switchCooldown = Int8(120)
        end
        @inbounds next_state = @set next_state.switchesPending[2] = defaultSwitch
    end
    return next_state
end

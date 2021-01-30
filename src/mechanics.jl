using Setfield

function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    @inbounds return type_effectiveness[defenderTypes[1], moveType] *
            type_effectiveness[defenderTypes[2], moveType]
end

function get_buff_modifier(buff::Int8)
    @inbounds return buff == Int8(0) ? Int8(12) : (buff > Int8(0) ? Int8(12) + Int8(3) * buff : Int8(48) ÷ (Int8(4) - buff))
end

function calculate_damage(
    attacker::Pokemon,
    atkBuff::Int8,
    defender::Pokemon,
    defBuff::Int8,
    move::FastMove,
    charge::Int8,
)
    return Int16((Int64(move.power) * Int64(move.stab) *
        Int64(attacker.stats.attack) * Int64(get_buff_modifier(atkBuff)) *
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(get_buff_modifier(defBuff)) * 1_280_000_000) + 1)
end

function calculate_damage(
    attacker::Pokemon,
    atkBuff::Int8,
    defender::Pokemon,
    defBuff::Int8,
    move::ChargedMove,
    charge::Int8,
)
    return Int16((Int64(move.power) * Int64(move.stab) *
        Int64(attacker.stats.attack) * Int64(get_buff_modifier(atkBuff)) *
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(get_buff_modifier(defBuff)) * 1_280_000_000) + 1)
end

function queue_fast_move(state::IndividualBattleState, agent::Int64)
    @inbounds return @set state.fastMovesPending[agent] = state.teams[agent].mon.fastMove.cooldown
end

function queue_fast_move(state::State, agent::Int64)
    @inbounds return @set state.fastMovesPending[agent] = state.teams[agent].mons[state.teams[agent].active].fastMove.cooldown
end

function queue_switch(state::State, switchTo::Int8; time::Int8 = Int8(0))
    @inbounds return @set state.switchesPending[state.agent] = SwitchAction(switchTo, time)
end

function get_cmp(state::IndividualBattleState)
    @inbounds charges = state.chargedMovesPending[1].charge, state.chargedMovesPending[2].charge
    @inbounds charges[2] == Int8(0) && return Int8(1)
    @inbounds charges[1] == Int8(0) && return Int8(2)
    @inbounds attacks = state.teams[1].mon.stats.attack, state.teams[2].mon.stats.attack
    @inbounds attacks[1] > attacks[2] && return Int8(1)
    @inbounds attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function get_cmp(state::State)
    @inbounds charges = state.chargedMovesPending[1].charge, state.chargedMovesPending[2].charge
    @inbounds charges[2] == Int8(0) && return Int8(1)
    @inbounds charges[1] == Int8(0) && return Int8(2)
    @inbounds attacks = state.teams[1].mons[state.teams[1].active].stats.attack,
        state.teams[2].mons[state.teams[2].active].stats.attack
    @inbounds attacks[1] > attacks[2] && return Int8(1)
    @inbounds attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function apply_buffs(state::IndividualBattleState, cmp::Int8)
    next_state = state
    move = next_state.teams[cmp].mon.chargedMoves[next_state.chargedMovesPending[cmp].move]
    @inbounds if rand(Int8(0):Int8(99)) < move.buffChance
        if move.opp_buffs != defaultBuff
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buff += move.opp_buffs
        else
            @inbounds next_state = @set next_state.teams[cmp].buff += move.self_buffs
        end
    end
    return next_state
end

function apply_buffs(state::State, cmp::Int8)
    next_state = state
    move = next_state.teams[cmp].mons[next_state.teams[cmp].active].chargedMoves[next_state.chargedMovesPending[cmp].move]
    @inbounds if rand(Int8(0):Int8(99)) < move.buffChance
        if move.opp_buffs != defaultBuff
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buff += move.opp_buffs
        else
            @inbounds next_state = @set next_state.teams[cmp].buff += move.self_buffs
        end
    end
    return next_state
end

function evaluate_fast_moves(state::IndividualBattleState, agent::Int64)
    next_state = state
    @inbounds next_state = @set next_state.teams[agent].mon.energy =
        min(next_state.teams[agent].mon.energy +
        next_state.teams[agent].mon.fastMove.energy, Int8(100))
    other_agent = agent == 1 ? 2 : 1
    @inbounds next_state = @set next_state.teams[other_agent].mon.hp = max(
        Int16(0),
        next_state.teams[other_agent].mon.hp -
        calculate_damage(
            next_state.teams[agent].mon,
            get_atk(next_state.teams[agent].buffs),
            next_state.teams[other_agent].mon,
            get_def(next_state.teams[other_agent].buffs),
            next_state.teams[agent].mon.fastMove,
            Int8(100),
        ),
    )
    @inbounds next_state = @set next_state.fastMovesPending[agent] = Int8(-1)
    return next_state
end

function evaluate_fast_moves(state::State, agent::Int64)
    next_state = state
    @inbounds next_state = @set next_state.teams[agent].mons[next_state.teams[agent].active].energy =
        min(next_state.teams[agent].mons[next_state.teams[agent].active].energy +
        next_state.teams[agent].mons[next_state.teams[agent].active].fastMove.energy, Int8(100))
    other_agent = agent == 1 ? 2 : 1
    @inbounds next_state = @set next_state.teams[other_agent].mons[next_state.teams[other_agent].active].hp = max(
        Int16(0),
        next_state.teams[other_agent].mons[next_state.teams[other_agent].active].hp -
        calculate_damage(
            next_state.teams[agent].mons[next_state.teams[agent].active],
            get_atk(next_state.teams[agent].buffs),
            next_state.teams[other_agent].mons[next_state.teams[other_agent].active],
            get_def(next_state.teams[other_agent].buffs),
            next_state.teams[agent].mons[next_state.teams[agent].active].fastMove,
            Int8(100),
        ),
    )

    return next_state
end

function evaluate_charged_moves(state::IndividualBattleState)
    cmp = get_cmp(state)
    next_state = state
    if cmp > Int8(0)
        move = next_state.teams[cmp].mon.chargedMoves[next_state.chargedMovesPending[cmp].move]
        @inbounds next_state = @set next_state.teams[cmp].mon.energy -= move.energy
        @inbounds if next_state.teams[get_other_agent(cmp)].shields > Int8(0) && next_state.teams[get_other_agent(cmp)].shielding
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].shields -= Int8(1)
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].shielding = false
        else
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].mon.hp = max(
                Int16(0),
                next_state.teams[get_other_agent(cmp)].mon.hp - calculate_damage(
                    next_state.teams[cmp].mon,
                    get_atk(next_state.teams[agent].buffs),
                    next_state.teams[get_other_agent(cmp)].mon,
                    get_def(next_state.teams[other_agent].buffs),
                    move,
                    next_state.chargedMovesPending[cmp].charge,
                ),
            )
        end
        next_state = apply_buffs(next_state, cmp)
        if next_state.fastMovesPending[get_other_agent(cmp)] != Int8(-1)
            next_state = evaluate_fast_moves(next_state, cmp == Int8(2) ? 1 : 2)
        end
        @inbounds next_state = @set next_state.chargedMovesPending[cmp] = defaultCharge
    end
    return next_state
end

function evaluate_charged_moves(state::State)
    cmp = get_cmp(state)
    next_state = state
    if cmp > Int8(0)
        move = next_state.teams[cmp].mons[next_state.teams[cmp].active].chargedMoves[next_state.chargedMovesPending[cmp].move]
        @inbounds next_state = @set next_state.teams[cmp].mons[next_state.teams[cmp].active].energy -= move.energy
        @inbounds next_state = @set next_state.teams[1].switchCooldown = max(Int8(0), next_state.teams[1].switchCooldown - Int8(20))
        @inbounds next_state = @set next_state.teams[2].switchCooldown = max(Int8(0), next_state.teams[2].switchCooldown - Int8(20))
        @inbounds if next_state.teams[get_other_agent(cmp)].shields > Int8(0) && next_state.teams[get_other_agent(cmp)].shielding
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].shields -= Int8(1)
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].shielding = false
        else
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active].hp = max(
                Int16(0),
                next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active].hp - calculate_damage(
                    next_state.teams[cmp].mons[next_state.teams[cmp].active],
                    get_atk(next_state.teams[agent].buffs),
                    next_state.teams[get_other_agent(cmp)].mons[next_state.teams[get_other_agent(cmp)].active],
                    get_def(next_state.teams[other_agent].buffs),
                    move,
                    next_state.chargedMovesPending[cmp].charge,
                ),
            )
        end
        next_state = apply_buffs(next_state, cmp)
        if next_state.fastMovesPending[get_other_agent(cmp)] != Int8(-1)
            next_state = evaluate_fast_moves(next_state, cmp == Int8(2) ? 1 : 2)
        end
        @inbounds next_state = @set next_state.chargedMovesPending[cmp] = defaultCharge
    end
    return next_state
end

function evaluate_switches(state::State)
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
        @inbounds next_state = @set next_state.fastMovesPending[1] = Int8(-1)
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
        @inbounds next_state = @set next_state.fastMovesPending[2] = Int8(-1)
        @inbounds next_state = @set next_state.switchesPending[2] = defaultSwitch
    end
    return next_state
end

function step_timers(state::IndividualBattleState)
    next_state = state
    @inbounds if state.fastMovesPending[1] != -1
        @inbounds next_state = @set next_state.fastMovesPending[1] -= Int8(1)
    end
    @inbounds if state.fastMovesPending[2] != -1
        @inbounds next_state = @set next_state.fastMovesPending[2] -= Int8(1)
    end
    return next_state
end

function step_timers(state::State)
    next_state = state
    @inbounds if state.fastMovesPending[1] != Int8(-1)
        @inbounds next_state = @set next_state.fastMovesPending[1] -= Int8(1)
    end
    @inbounds if state.fastMovesPending[2] != Int8(-1)
        @inbounds next_state = @set next_state.fastMovesPending[2] -= Int8(1)
    end
    @inbounds if state.teams[1].switchCooldown != Int8(0)
        @inbounds next_state = @set next_state.teams[1].switchCooldown -= Int8(1)
    end
    @inbounds if state.teams[2].switchCooldown != Int8(0)
        @inbounds next_state = @set next_state.teams[2].switchCooldown -= Int8(1)
    end
    return next_state
end

using Setfield

function get_buff_modifier(buff::Int8)
    @inbounds return buff == Int8(0) ? 12 : (buff > Int8(0) ? 12 + 3 * buff : 48 ÷ (4 - buff))
end

function calculate_damage(attack::UInt16, defense::UInt16, power::Int64,
    charge::Int8, atk_buff::Int8, def_buff::Int8, effectiveness::Int64,
    stab::Int8)
    return Int16((65 * effectiveness * power * stab * attack * charge *
        get_buff_modifier(atk_buff)) ÷ (1_280_000_000 * defense *
        get_buff_modifier(def_buff)) + 1)
end

function queue_fast_move(state::IndividualBattleState, agent::Int64)
    return @set state.fastMovesPending[agent] = fast_moves[4, state.teams[agent].mon.fastMove]
end

function queue_fast_move(state::State, agent::Int64)
    return @set state.fastMovesPending[agent] = fast_moves[4, state.teams[agent].mons[state.teams[agent].active].fastMove.cooldown]
end

function queue_switch(state::State, switchTo::Int8; time::Int8 = Int8(0))
    return @set state.switchesPending[state.agent] = SwitchAction(switchTo, time)
end

function get_cmp(state::IndividualBattleState)
    state.chargedMovesPending[2].charge == Int8(0) && return Int8(1)
    state.chargedMovesPending[1].charge == Int8(0) && return Int8(2)
    attacks = state.teams[1].mon.stats.attack, state.teams[2].mon.stats.attack
    attacks[1] > attacks[2] && return Int8(1)
    attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function get_cmp(state::State)
    state.chargedMovesPending[2].charge == Int8(0) && return Int8(1)
    state.chargedMovesPending[1].charge == Int8(0) && return Int8(2)
    attacks = state.teams[1].mons[state.teams[1].active].stats.attack,
        state.teams[2].mons[state.teams[2].active].stats.attack
    attacks[1] > attacks[2] && return Int8(1)
    attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function apply_buffs(state::IndividualBattleState, cmp::Int8)
    move = state.chargedMovesPending[cmp].move
    chance = charged_moves[4, move]
    chance == Int8(0) && return state
    next_state = state
    if rand(Int8(1):chance) == Int8(1)
        if charged_moves_buffs[1, move] != defaultBuff
            next_state = @set next_state.teams[get_other_agent(cmp)].buffs += charged_moves_buffs[1, move]
        else
            next_state = @set next_state.teams[cmp].buffs += charged_moves_buffs[2, move]
        end
    end
    return next_state
end

function apply_buffs(state::State, cmp::Int8)
    move = state.chargedMovesPending[cmp].move
    chance = charged_moves[4, move]
    chance == Int8(0) && return state
    next_state = state
    if rand(Int8(1):chance) == Int8(1)
        if charged_moves_buffs[1, move] != defaultBuff
            next_state = @set next_state.teams[get_other_agent(cmp)].buffs += charged_moves_buffs[1, move]
        else
            next_state = @set next_state.teams[cmp].buffs += charged_moves_buffs[2, move]
        end
    end
    return next_state
end

function evaluate_fast_moves(state::IndividualBattleState, agent::Int64)
    next_state = state
    move = fast_moves[1:3, next_state.teams[agent].mon.fastMove]
    next_state = @set next_state.teams[agent].mon.energy =
        min(next_state.teams[agent].mon.energy + move[2], Int8(100))
    other_agent = agent == 1 ? 2 : 1
    next_state = @set next_state.teams[other_agent].mon.hp = max(
        Int16(0),
        next_state.teams[other_agent].mon.hp -
        calculate_damage(
            next_state.teams[agent].mon.stats.attack,
            next_state.teams[other_agent].mon.stats.defense,
            Int64(move[1]),
            Int8(100),
            get_atk(next_state.teams[agent].buffs),
            get_def(next_state.teams[other_agent].buffs),
            eff[effectiveness[next_state.teams[other_agent].mon.typing, move[3]]],
            move[3] in typings[next_state.teams[agent].mon.typing] ? Int8(12) : Int8(10)
        ),
    )
    next_state = @set next_state.fastMovesPending[agent] = Int8(-1)
    return next_state
end

function evaluate_fast_moves(state::State, agent::Int64)
    next_state = state
    move = fast_moves[1:3, next_state.teams[agent].mons[next_state.teams[agent].active].fastMove]
    next_state = @set next_state.teams[agent].mons[next_state.teams[agent].active].energy =
        min(next_state.teams[agent].mons[next_state.teams[agent].active].energy +
        next_state.teams[agent].mons[next_state.teams[agent].active].fastMove.energy, Int8(100))
    other_agent = agent == 1 ? 2 : 1
    next_state = @set next_state.teams[other_agent].mon.hp = max(
        Int16(0),
        next_state.teams[other_agent].mon.hp -
        calculate_damage(
            next_state.teams[agent].mon.stats.attack,
            next_state.teams[other_agent].mon.stats.defense,
            Int64(move[1]),
            Int8(100),
            get_atk(next_state.teams[agent].buffs),
            get_def(next_state.teams[other_agent].buffs),
            eff[effectiveness[next_state.teams[other_agent].mons[next_state.teams[other_agent].active].typing, move[3]]],
            move[3] in typings[next_state.teams[agent].mons[next_state.teams[agent].active].typing] ? Int8(12) : Int8(10)
        ),
    )

    return next_state
end

function evaluate_charged_moves(state::IndividualBattleState)
    cmp = get_cmp(state)
    cmp == Int8(0) && return state
    next_state = state
    move = charged_moves[1:3, next_state.chargedMovesPending[cmp].move]
    next_state = @set next_state.teams[cmp].mon.energy -= move[3]
    other_agent = cmp == 1 ? 2 : 1
    if next_state.teams[other_agent].shields > Int8(0) && next_state.teams[other_agent].shielding
        next_state = @set next_state.teams[other_agent].shields -= Int8(1)
        next_state = @set next_state.teams[other_agent].shielding = false
    else
        next_state = @set next_state.teams[get_other_agent(cmp)].mon.hp = max(
            Int16(0),
            next_state.teams[other_agent].mon.hp - calculate_damage(
                next_state.teams[cmp].mon.stats.attack,
                next_state.teams[other_agent].mon.stats.defense,
                5 * move[2],
                next_state.chargedMovesPending[cmp].charge,
                get_atk(next_state.teams[cmp].buffs),
                get_def(next_state.teams[other_agent].buffs),
                eff[effectiveness[next_state.teams[other_agent].mon.typing, move[1]]],
                move[1] in typings[next_state.teams[cmp].mon.typing] ? Int8(12) : Int8(10)
            )
        )
    end
    next_state = apply_buffs(next_state, cmp)
    if next_state.fastMovesPending[get_other_agent(cmp)] != Int8(-1)
        next_state = evaluate_fast_moves(next_state, cmp == Int8(2) ? 1 : 2)
    end
    next_state = @set next_state.chargedMovesPending[cmp] = defaultCharge
    return next_state
end

function evaluate_charged_moves(state::State)
    cmp = get_cmp(state)
    cmp == Int8(0) && return state
    next_state = state
    move = charged_moves[1:3, next_state.chargedMovesPending[cmp].move]
    next_state = @set next_state.teams[cmp].mons[next_state.teams[cmp].active].energy -= move[3]
    next_state = @set next_state.teams[1].switchCooldown = max(Int8(0), next_state.teams[1].switchCooldown - Int8(20))
    next_state = @set next_state.teams[2].switchCooldown = max(Int8(0), next_state.teams[2].switchCooldown - Int8(20))
    other_agent = cmp == 1 ? 2 : 1
    if next_state.teams[other_agent].shields > Int8(0) && next_state.teams[other_agent].shielding
        next_state = @set next_state.teams[other_agent].shields -= Int8(1)
        next_state = @set next_state.teams[other_agent].shielding = false
    else
        next_state = @set next_state.teams[other_agent].mon.hp = max(
            Int16(0),
            next_state.teams[other_agent].mon.hp - calculate_damage(
                next_state.teams[cmp].mon.stats.attack,
                next_state.teams[other_agent].mon.stats.defense,
                5 * move[2],
                next_state.chargedMovesPending[cmp].charge,
                get_atk(next_state.teams[cmp].buffs),
                get_def(next_state.teams[other_agent].buffs),
                eff[effectiveness[next_state.teams[other_agent].mons[next_state.teams[other_agent].active].typing, move[1]]],
                move[1] in typings[next_state.teams[cmp].mons[next_state.teams[cmp].active].typing] ? Int8(12) : Int8(10)
            )
        )
    end
    next_state = apply_buffs(next_state, cmp)
    if next_state.fastMovesPending[other_agent] != Int8(-1)
        next_state = evaluate_fast_moves(next_state, cmp == Int8(2) ? 1 : 2)
    end
    next_state = @set next_state.chargedMovesPending[cmp] = defaultCharge
    return next_state
end

function evaluate_switches(state::State)
    next_state = state
    if next_state.switchesPending[1].pokemon != Int8(0)
        next_state = @set next_state.teams[1].active = next_state.switchesPending[1].pokemon
        next_state = @set next_state.teams[1].buffs = defaultBuff
        if next_state.switchesPending[1].time != Int8(0)
            next_state = @set next_state.teams[2].switchCooldown = max(
                Int8(0),
                next_state.teams[2].switchCooldown - next_state.switchesPending[1].time - Int8(1),
            )
        else
            next_state = @set next_state.teams[1].switchCooldown = Int8(120)
        end
        next_state = @set next_state.fastMovesPending[1] = Int8(-1)
        next_state = @set next_state.switchesPending[1] = defaultSwitch
    end

    if next_state.switchesPending[2].pokemon != Int8(0)
        next_state = @set next_state.teams[2].active = next_state.switchesPending[2].pokemon
        next_state = @set next_state.teams[2].buffs = defaultBuff
        if next_state.switchesPending[2].time != Int8(0)
            next_state = @set next_state.teams[1].switchCooldown = max(
                Int8(0),
                next_state.teams[1].switchCooldown - next_state.switchesPending[2].time - Int8(1),
            )
        else
            next_state = @set next_state.teams[2].switchCooldown = Int8(120)
        end
        next_state = @set next_state.fastMovesPending[2] = Int8(-1)
        next_state = @set next_state.switchesPending[2] = defaultSwitch
    end
    return next_state
end

function step_timers(state::IndividualBattleState)
    next_state = state
    if state.fastMovesPending[1] != Int8(-1)
        next_state = @set next_state.fastMovesPending[1] -= Int8(1)
    end
    if state.fastMovesPending[2] != Int8(-1)
        next_state = @set next_state.fastMovesPending[2] -= Int8(1)
    end
    return next_state
end

function step_timers(state::State)
    next_state = state
    if state.fastMovesPending[1] != Int8(-1)
        next_state = @set next_state.fastMovesPending[1] -= Int8(1)
    end
    if state.fastMovesPending[2] != Int8(-1)
        next_state = @set next_state.fastMovesPending[2] -= Int8(1)
    end
    if state.teams[1].switchCooldown != Int8(0)
        next_state = @set next_state.teams[1].switchCooldown -= Int8(1)
    end
    if state.teams[2].switchCooldown != Int8(0)
        next_state = @set next_state.teams[2].switchCooldown -= Int8(1)
    end
    return next_state
end

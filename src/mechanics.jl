using Setfield

function get_buff_modifier(buff::Int8)
    @inbounds return buff == Int8(0) ? 12 : (buff > Int8(0) ? 12 + 3 * buff : 48 ÷ (4 - buff))
end

function calculate_damage(attack::Int64, defense::Int64, power::Int64,
    charge::Int64, atk_buff::Int8, def_buff::Int8, atk_typing::Int8,
    def_typing::Int8, move_typing::Int8
)
    stab = move_typing in typings[atk_typing] ? 12 : 10
    return Int16((power * stab * attack * get_buff_modifier(atk_buff) *
        get_eff(effectiveness[def_typing, move_typing]) * charge * 65) ÷
        (defense * get_buff_modifier(def_buff) * 1_280_000_000) + 1)
end

function queue_fast_move(state::IndividualBattleState, agent::Int64)
    @inbounds return @set state.fastMovesPending[agent] = fast_moves[state.teams[agent].mon.fastMove, 4]
end

function queue_fast_move(state::State, agent::Int64)
    @inbounds return @set state.fastMovesPending[agent] = fast_moves[state.teams[agent].mons[state.teams[agent].active].fastMove.cooldown, 4]
end

function queue_switch(state::State, switchTo::Int8; time::Int8 = Int8(0))
    @inbounds return @set state.switchesPending[state.agent] = SwitchAction(switchTo, time)
end

function get_cmp(state::IndividualBattleState)
    @inbounds state.chargedMovesPending[2].charge == Int8(0) && return Int8(1)
    @inbounds state.chargedMovesPending[1].charge == Int8(0) && return Int8(2)
    @inbounds attacks = state.teams[1].mon.stats.attack, state.teams[2].mon.stats.attack
    @inbounds attacks[1] > attacks[2] && return Int8(1)
    @inbounds attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function get_cmp(state::State)
    @inbounds state.chargedMovesPending[2].charge == Int8(0) && return Int8(1)
    @inbounds state.chargedMovesPending[1].charge == Int8(0) && return Int8(2)
    @inbounds attacks = state.teams[1].mons[state.teams[1].active].stats.attack,
        state.teams[2].mons[state.teams[2].active].stats.attack
    @inbounds attacks[1] > attacks[2] && return Int8(1)
    @inbounds attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function apply_buffs(state::IndividualBattleState, cmp::Int8)
    next_state = state
    move = next_state.chargedMovesPending[cmp].move
    @inbounds if rand(Int8(1):charged_moves[move, 4]) == Int8(1)
        if charged_moves_buffs[move, 1] != defaultBuff
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buffs += charged_moves_buffs[move, 1]
        else
            @inbounds next_state = @set next_state.teams[cmp].buffs += charged_moves_buffs[move, 2]
        end
    end
    return next_state
end

function apply_buffs(state::State, cmp::Int8)
    next_state = state
    move = next_state.chargedMovesPending[cmp].move
    @inbounds if rand(Int8(1):charged_moves[move, 4]) == Int8(1)
        if charged_moves_buffs[move, 1] != defaultBuff
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buffs += charged_moves_buffs[move, 1]
        else
            @inbounds next_state = @set next_state.teams[cmp].buffs += charged_moves_buffs[move, 2]
        end
    end
    return next_state
end

function evaluate_fast_moves(state::IndividualBattleState, agent::Int64)
    next_state = state
    move = fast_moves[next_state.teams[agent].mon.fastMove, 1:3]
    @inbounds next_state = @set next_state.teams[agent].mon.energy =
        min(next_state.teams[agent].mon.energy + move[2], Int8(100))
    other_agent = agent == 1 ? 2 : 1
    @inbounds next_state = @set next_state.teams[other_agent].mon.hp = max(
        Int16(0),
        next_state.teams[other_agent].mon.hp -
        calculate_damage(
            Int64(next_state.teams[agent].mon.stats.attack),
            Int64(next_state.teams[other_agent].mon.stats.defense),
            Int64(move[1]),
            Int64(100),
            get_atk(next_state.teams[agent].buffs),
            get_def(next_state.teams[other_agent].buffs),
            next_state.teams[agent].mon.typing,
            next_state.teams[other_agent].mon.typing,
            move[1]
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
    @inbounds next_state = @set next_state.teams[other_agent].mon.hp = max(
        Int16(0),
        next_state.teams[other_agent].mon.hp -
        calculate_damage(
            Int64(next_state.teams[agent].mons[next_state.teams[agent].active].stats.attack),
            Int64(next_state.teams[other_agent].mons[next_state.teams[other_agent].active].stats.defense),
            Int64(move[1]),
            Int64(100),
            get_atk(next_state.teams[agent].buffs),
            get_def(next_state.teams[other_agent].buffs),
            next_state.teams[agent].mons[next_state.teams[agent].active].typing,
            next_state.teams[other_agent].mons[next_state.teams[other_agent].active].typing,
            move[1]
        ),
    )

    return next_state
end

function evaluate_charged_moves(state::IndividualBattleState)
    cmp = get_cmp(state)
    next_state = state
    if cmp > Int8(0)
        @inbounds move = charged_moves[next_state.chargedMovesPending[cmp].move, 1:3]
        @inbounds next_state = @set next_state.teams[cmp].mon.energy -= move[3]
        other_agent = cmp == 1 ? 2 : 1
        @inbounds if next_state.teams[other_agent].shields > Int8(0) && next_state.teams[other_agent].shielding
            @inbounds next_state = @set next_state.teams[other_agent].shields -= Int8(1)
            @inbounds next_state = @set next_state.teams[other_agent].shielding = false
        else
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].mon.hp = max(
                Int16(0),
                    next_state.teams[other_agent].mon.hp - calculate_damage(
                    Int64(next_state.teams[cmp].mon.stats.attack),
                    Int64(next_state.teams[other_agent].mon.stats.defense),
                    5 * move[2],
                    Int65(next_state.chargedMovesPending[cmp].charge),
                    get_atk(next_state.teams[cmp].buffs),
                    get_def(next_state.teams[other_agent].buffs),
                    next_state.teams[cmp].mon.typing,
                    next_state.teams[other_agent].mon.typing,
                    move[1]
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
        @inbounds move = charged_moves[next_state.chargedMovesPending[cmp].move, 1:3]
        @inbounds next_state = @set next_state.teams[cmp].mons[next_state.teams[cmp].active].energy -= move[3]
        @inbounds next_state = @set next_state.teams[1].switchCooldown = max(Int8(0), next_state.teams[1].switchCooldown - Int8(20))
        @inbounds next_state = @set next_state.teams[2].switchCooldown = max(Int8(0), next_state.teams[2].switchCooldown - Int8(20))
        other_agent = cmp == 1 ? 2 : 1
        @inbounds if next_state.teams[get_other_agent(cmp)].shields > Int8(0) && next_state.teams[get_other_agent(cmp)].shielding
            @inbounds next_state = @set next_state.teams[other_agent].shields -= Int8(1)
            @inbounds next_state = @set next_state.teams[other_agent].shielding = false
        else
            @inbounds next_state = @set next_state.teams[other_agent].mon.hp = max(
                Int16(0),
                    next_state.teams[other_agent].mon.hp - calculate_damage(
                    Int64(next_state.teams[cmp].mons[next_state.teams[cmp].active].stats.attack),
                    Int64(next_state.teams[other_agent].mons[next_state.teams[other_agent].active].stats.defense),
                    5 * move[2],
                    Int64(next_state.chargedMovesPending[cmp].charge),
                    get_atk(next_state.teams[cmp].buffs),
                    get_def(next_state.teams[other_agent].buffs),
                    next_state.teams[cmp].mons[next_state.teams[cmp].active].typing,
                    next_state.teams[other_agent].mons[next_state.teams[other_agent].active].typing,
                    move[1]
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

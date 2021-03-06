using Setfield

function queue_fast_move(state::IndividualBattleState, agent::Int8)
    @inbounds return @set state.fastMovesPending[agent] = state.teams[agent].mon.fastMove.cooldown
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

function apply_buffs(state::IndividualBattleState, cmp::Int8)
    next_state = state
    move = next_state.teams[cmp].mon.chargedMoves[next_state.chargedMovesPending[cmp].move]
    @inbounds if rand(Int8(0):Int8(99)) < move.buffChance
        if move.opp_buffs != defaultBuff
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buffs += move.opp_buffs
        else
            @inbounds next_state = @set next_state.teams[cmp].buffs += move.self_buffs
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
                    get_atk(next_state.teams[cmp].buffs),
                    next_state.teams[get_other_agent(cmp)].mon,
                    get_def(next_state.teams[get_other_agent(cmp)].buffs),
                    move,
                    next_state.chargedMovesPending[cmp].charge,
                ),
            )
        end
        next_state = apply_buffs(next_state, cmp)
        if next_state.fastMovesPending[get_other_agent(cmp)] != Int8(-1)
            next_state = evaluate_fast_moves(next_state, cmp)
        end
        @inbounds next_state = @set next_state.chargedMovesPending[cmp] = defaultCharge
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

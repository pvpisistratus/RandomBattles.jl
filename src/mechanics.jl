using Setfield

function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    @inbounds return type_effectiveness[defenderTypes[1], moveType] *
            type_effectiveness[defenderTypes[2], moveType]
end

function get_buff_modifier(buff::Int8)
    @inbounds return buff == Int8(0) ? Int8(12) : (buff > Int8(0) ? Int8(12) + Int8(3) * buff : Int8(48) ÷ (Int8(4) - buff))
end

function calculate_damage(
    attacker::StaticPokemon,
    atkBuff::Int8,
    defender::StaticPokemon,
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
    attacker::StaticPokemon,
    atkBuff::Int8,
    defender::StaticPokemon,
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

function queue_fast_move(state::DynamicState, static_state::StaticState, agent::Int8)
    @inbounds return @set state.fastMovesPending[agent] = static_state.teams[agent].mons[
        state.teams[agent].active].fastMove.cooldown
end

function evaluate_fast_moves(state::DynamicState, static_state::StaticState, agent::Int8)
    if agent == Int8(1)
        return DynamicState(@SVector[DynamicTeam(map(
            (x -> x == Int8(state.teams[1].active) ? DynamicPokemon(state.teams[1].mons[x].hp,
            min(state.teams[1].mons[x].energy + static_state.teams[1].mons[x].fastMove.energy,
            Int8(100))) : state.teams[1].mons[x]), 1:3), state.teams[1].buffs,
            state.teams[1].switchCooldown, state.teams[1].shields, state.teams[1].active),
            DynamicTeam(map(x -> x == Int8(state.teams[2].active) ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[x].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[x],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[2].mons[x].energy) : state.teams[2].mons[x], 1:3), state.teams[2].buffs,
            state.teams[2].switchCooldown, state.teams[2].shields, state.teams[2].active)], state.fastMovesPending)
    else
        return DynamicState(@SVector[DynamicTeam(map(x -> x == Int8(state.teams[1].active) ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[x].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[x],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[1].mons[x].energy) : state.teams[1].mons[x], 1:3), state.teams[1].buffs,
            state.teams[1].switchCooldown, state.teams[1].shields, state.teams[1].active),
            DynamicTeam(map(
            x -> x == Int8(state.teams[2].active) ? DynamicPokemon(state.teams[2].mons[x].hp,
            min(state.teams[2].mons[x].energy + static_state.teams[2].mons[x].fastMove.energy,
            Int8(100))) : state.teams[2].mons[x], 1:3), state.teams[2].buffs,
            state.teams[2].switchCooldown, state.teams[2].shields, state.teams[2].active)], state.fastMovesPending)
    end
end

function get_cmp(state::DynamicState, static_state::StaticState, dec::Decision)
    @inbounds dec.chargedMovesPending[1].charge + dec.chargedMovesPending[2].charge == Int8(0) && return Int8(0)
    @inbounds dec.chargedMovesPending[2].charge == Int8(0) && return Int8(1)
    @inbounds dec.chargedMovesPending[1].charge == Int8(0) && return Int8(2)
    @inbounds static_state.teams[1].mons[state.teams[1].active].stats.attack > static_state.teams[2].mons[
        state.teams[2].active].stats.attack && return Int8(1)
    @inbounds static_state.teams[1].mons[state.teams[1].active].stats.attack < static_state.teams[2].mons[
        state.teams[2].active].stats.attack && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function apply_buffs(state::DynamicState, static_state::StaticState, cmp::Int8, move_id::Int8)
    next_state = state
    @inbounds move = static_state.teams[cmp].mons[state.teams[cmp].active].chargedMoves[move_id]
    @inbounds if rand(Int8(0):Int8(99)) < move.buffChance
        if move.opp_buffs != defaultBuff
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buffs += move.opp_buffs
        else
            @inbounds next_state = @set next_state.teams[cmp].buffs += move.self_buffs
        end
    end
    return next_state
end

function evaluate_charged_moves(state::DynamicState, static_state::StaticState, cmp::Int8, move_id::Int8, charge::Int8,
  shielding::Bool)
    next_state = state
    move = static_state.teams[cmp].mons[next_state.teams[cmp].active].chargedMoves[move_id]
    @inbounds next_state = @set next_state.teams[cmp].mons[next_state.teams[cmp].active].energy -= move.energy
    other_agent = get_other_agent(cmp)
    @inbounds if shielding
        @inbounds next_state = @set next_state.teams[other_agent].shields -= Int8(1)
    else
        @inbounds next_state = @set next_state.teams[other_agent].mons[next_state.teams[other_agent].active].hp = max(
            Int16(0),
            next_state.teams[other_agent].mons[next_state.teams[other_agent].active].hp - calculate_damage(
                static_state.teams[cmp].mons[next_state.teams[cmp].active],
                get_atk(next_state.teams[cmp].buffs),
                static_state.teams[other_agent].mons[next_state.teams[other_agent].active],
                get_def(next_state.teams[other_agent].buffs),
                move,
                charge,
            ),
        )
    end
    next_state = apply_buffs(next_state, static_state, cmp, move_id)
    if next_state.fastMovesPending[other_agent] != Int8(-1)
        next_state = evaluate_fast_moves(next_state, static_state, cmp)
    end
    @inbounds next_state = @set next_state.teams[1].switchCooldown = max(Int8(0), next_state.teams[1].switchCooldown - Int8(20))
    @inbounds next_state = @set next_state.teams[2].switchCooldown = max(Int8(0), next_state.teams[2].switchCooldown - Int8(20))
    return next_state
end

function evaluate_switch(state::DynamicState, agent::Int8, to_switch::Int8, time::Int8)
    return agent == Int8(1) ? DynamicState(
        @SVector[DynamicTeam(state.teams[1].mons, defaultBuff, Int8(120), state.teams[1].shields, to_switch),
            DynamicTeam(state.teams[2].mons, state.teams[2].buffs, max(Int8(0), state.teams[2].switchCooldown - time),
            state.teams[2].shields, state.teams[2].active)],
        @SVector[Int8(-1), state.fastMovesPending[2]]) : DynamicState(
            @SVector[DynamicTeam(state.teams[1].mons, state.teams[1].buffs, max(Int8(0),
                state.teams[1].switchCooldown - time), state.teams[1].shields, state.teams[1].active),
                DynamicTeam(state.teams[2].mons, defaultBuff, Int8(120), state.teams[2].shields, to_switch)],
            @SVector[state.fastMovesPending[1], Int8(-1)])
end


function step_timers(state::DynamicState)
    return DynamicState(
        @SVector[DynamicTeam(state.teams[1].mons, state.teams[1].buffs, max(Int8(0), state.teams[1].switchCooldown - Int8(1)),
            state.teams[1].shields, state.teams[1].active), DynamicTeam(state.teams[2].mons, state.teams[2].buffs, max(Int8(0),
            state.teams[2].switchCooldown - Int8(1)), state.teams[2].shields, state.teams[2].active)],
        @SVector[max(Int8(-1), state.fastMovesPending[1] - Int8(1)), max(Int8(-1), state.fastMovesPending[2] - Int8(1))])
end

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

function evaluate_fast_moves(state::DynamicState, static_state::StaticState, agent::Int8)
    if agent == Int8(1)
        return DynamicState(@SVector[DynamicTeam(@SVector[
            (Int8(1) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[1].hp,
            min(state.teams[1].mons[1].energy + static_state.teams[1].mons[1].fastMove.energy,
            Int8(100))) : state.teams[1].mons[1]),
            (Int8(2) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[2].hp,
            min(state.teams[1].mons[2].energy + static_state.teams[1].mons[2].fastMove.energy,
            Int8(100))) : state.teams[1].mons[2]),
            (Int8(3) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[3].hp,
            min(state.teams[1].mons[3].energy + static_state.teams[1].mons[3].fastMove.energy,
            Int8(100))) : state.teams[1].mons[3]),
            ], state.teams[1].buffs, state.teams[1].switchCooldown,
            state.teams[1].shields, state.teams[1].active),
            DynamicTeam(@SVector[Int8(1) == state.teams[2].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[1].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[1],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[2].mons[1].energy) : state.teams[2].mons[1],
            Int8(2) == state.teams[2].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[2].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[2],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[2].mons[2].energy) : state.teams[2].mons[2],
            Int8(3) == state.teams[2].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[3].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[3],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[2].mons[3].energy) : state.teams[2].mons[3]], state.teams[2].buffs,
            state.teams[2].switchCooldown, state.teams[2].shields, state.teams[2].active)], state.fastMovesPending)
    else
        return DynamicState(@SVector[
            DynamicTeam(@SVector[Int8(1) == state.teams[1].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[1].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[1],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[1].mons[1].energy) : state.teams[1].mons[1],
            Int8(2) == state.teams[1].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[2].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[2],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[1].mons[2].energy) : state.teams[1].mons[2],
            Int8(3) == state.teams[1].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[3].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[3],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].fastMove,
                    Int8(100),
                ),
            ), state.teams[1].mons[3].energy) : state.teams[1].mons[3]], state.teams[1].buffs,
            state.teams[1].switchCooldown, state.teams[1].shields, state.teams[1].active),
            DynamicTeam(@SVector[
                (Int8(1) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[1].hp,
                min(state.teams[2].mons[1].energy + static_state.teams[2].mons[1].fastMove.energy,
                Int8(100))) : state.teams[2].mons[1]),
                (Int8(2) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[2].hp,
                min(state.teams[2].mons[2].energy + static_state.teams[2].mons[2].fastMove.energy,
                Int8(100))) : state.teams[2].mons[2]),
                (Int8(3) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[3].hp,
                min(state.teams[2].mons[3].energy + static_state.teams[2].mons[3].fastMove.energy,
                Int8(100))) : state.teams[2].mons[3]),
                ], state.teams[2].buffs, state.teams[2].switchCooldown,
                state.teams[2].shields, state.teams[2].active)], state.fastMovesPending)
    end
end

function get_cmp(state::DynamicState, static_state::StaticState, dec::Decision)
    @inbounds dec.chargedMovesPending[1].charge + dec.chargedMovesPending[2].charge == Int8(0) && return Int8(0), Int8(0)
    @inbounds dec.chargedMovesPending[2].charge == Int8(0) && return Int8(1), Int8(0)
    @inbounds dec.chargedMovesPending[1].charge == Int8(0) && return Int8(2), Int8(0)
    @inbounds static_state.teams[1].mons[state.teams[1].active].stats.attack > static_state.teams[2].mons[
        state.teams[2].active].stats.attack && return Int8(1), Int8(2)
    @inbounds static_state.teams[1].mons[state.teams[1].active].stats.attack < static_state.teams[2].mons[
        state.teams[2].active].stats.attack && return Int8(2), Int8(1)
    cmp = rand((Int8(1), Int8(2)))
    return cmp, (cmp == Int8(1) ? Int8(2) : Int8(1))
end

function evaluate_charged_moves(state::DynamicState, static_state::StaticState, cmp::Int8, move_id::Int8, charge::Int8, shielding::Bool, buffs_applied::Bool)
    if cmp == Int8(1)
        return DynamicState(@SVector[DynamicTeam(@SVector[
            (Int8(1) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[1].hp,
            min(state.teams[1].mons[1].energy - static_state.teams[1].mons[1].chargedMoves[move_id].energy,
            Int8(100))) : state.teams[1].mons[1]),
            (Int8(2) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[2].hp,
            min(state.teams[1].mons[2].energy - static_state.teams[1].mons[2].chargedMoves[move_id].energy,
            Int8(100))) : state.teams[1].mons[2]),
            (Int8(3) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[3].hp,
            min(state.teams[1].mons[3].energy - static_state.teams[1].mons[3].chargedMoves[move_id].energy,
            Int8(100))) : state.teams[1].mons[3]),
            ], buffs_applied ? state.teams[1].buffs + static_state.teams[1].mons[3].chargedMoves[move_id].self_buffs : state.teams[1].buffs,
            max(Int8(0), state.teams[1].switchCooldown - Int8(20)), state.teams[1].shields, state.teams[1].active),
            DynamicTeam((!shielding ? state.teams[2].mons : @SVector[Int8(1) == state.teams[2].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[1].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[1],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id],
                    Int8(100),
                ),
            ), state.teams[2].mons[1].energy) : state.teams[2].mons[1],
            Int8(2) == state.teams[2].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[2].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[2],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id],
                    Int8(100),
                ),
            ), state.teams[2].mons[2].energy) : state.teams[2].mons[2],
            Int8(3) == state.teams[2].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[3].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[3],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id],
                    Int8(100),
                ),
            ), state.teams[2].mons[3].energy) : state.teams[2].mons[3]]),
            buffs_applied ? (state.teams[2].buffs + static_state.teams[1].mons[3].chargedMoves[move_id].opp_buffs) : state.teams[2].buffs,
            max(Int8(0), state.teams[2].switchCooldown - Int8(20)), (shielding ? state.teams[2].shields - Int8(1) : state.teams[2].shields),
            state.teams[2].active)], state.fastMovesPending)
    else
        DynamicState(@SVector[
            DynamicTeam((!shielding ? state.teams[1].mons : @SVector[Int8(1) == state.teams[1].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[1].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[1],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].chargedMoves[move_id],
                    Int8(100),
                ),
            ), state.teams[1].mons[1].energy) : state.teams[1].mons[1],
            Int8(2) == state.teams[1].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[2].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[2],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].chargedMoves[move_id],
                    Int8(100),
                ),
            ), state.teams[1].mons[2].energy) : state.teams[1].mons[2],
            Int8(3) == state.teams[1].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[3].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[3],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].chargedMoves[move_id],
                    Int8(100),
                ),
            ), state.teams[1].mons[3].energy) : state.teams[1].mons[3]]),
            buffs_applied ? (state.teams[1].buffs + static_state.teams[2].mons[state.teams[2].active].chargedMoves[move_id].opp_buffs) : state.teams[1].buffs,
            max(Int8(0), state.teams[1].switchCooldown - Int8(20)), (shielding ? state.teams[1].shields - Int8(1) : state.teams[1].shields),
            state.teams[1].active), DynamicTeam(@SVector[
                (Int8(1) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[1].hp,
                min(state.teams[2].mons[1].energy - static_state.teams[2].mons[1].chargedMoves[move_id].energy,
                Int8(100))) : state.teams[2].mons[1]),
                (Int8(2) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[2].hp,
                min(state.teams[2].mons[2].energy - static_state.teams[2].mons[2].chargedMoves[move_id].energy,
                Int8(100))) : state.teams[2].mons[2]),
                (Int8(3) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[3].hp,
                min(state.teams[2].mons[3].energy - static_state.teams[2].mons[3].chargedMoves[move_id].energy,
                Int8(100))) : state.teams[2].mons[3]),
                ], buffs_applied ? state.teams[2].buffs + static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id].self_buffs : state.teams[2].buffs,
                max(Int8(0), state.teams[2].switchCooldown - Int8(20)), state.teams[2].shields, state.teams[2].active)], state.fastMovesPending)
    end
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


function step_timers(state::DynamicState, fmCooldown1::Int8, fmCooldown2::Int8)
    return DynamicState(
        @SVector[DynamicTeam(state.teams[1].mons, state.teams[1].buffs, max(Int8(0), state.teams[1].switchCooldown - Int8(1)),
            state.teams[1].shields, state.teams[1].active), DynamicTeam(state.teams[2].mons, state.teams[2].buffs, max(Int8(0),
            state.teams[2].switchCooldown - Int8(1)), state.teams[2].shields, state.teams[2].active)],
        @SVector[fmCooldown1 == Int8(0) ? max(Int8(-1), state.fastMovesPending[1] - Int8(1)) : fmCooldown1 - Int8(1),
            fmCooldown2 == Int8(0) ? max(Int8(-1), state.fastMovesPending[2] - Int8(1)) : fmCooldown2 - Int8(1)])
end

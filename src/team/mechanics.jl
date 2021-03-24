using StaticArrays

"""
    get_effectiveness(defenderTypes, moveType)

Compute the effectiveness of a particular move against a type combination.
In the example below, flying is super-effective against a pure fighting type.

# Examples
```jldoctest
julia> using StaticArrays; get_effectiveness(@SVector[Int8(2), Int8(19)], Int8(3))
1.6
"""
function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    @inbounds return type_effectiveness[defenderTypes[1], moveType] *
            type_effectiveness[defenderTypes[2], moveType]
end

"""
    get_buff_modifier(buff)

Compute the mulitplier associated with stat buffs (multiplied by 12 to return an integer).
As a result, the multiplier for no buff effect is 0. Inputs should be between -4 and 4.

# Examples
```jldoctest
julia> get_buff_modifier(Int8(0))
12
"""
function get_buff_modifier(buff::Int8)
    return buff == Int8(0) ? Int8(12) : (buff > Int8(0) ? Int8(12) + Int8(3) * buff : Int8(48) ÷ (Int8(4) - buff))
end

"""
    calculate_damage(
        attacker::StaticPokemon,
        atkBuff::Int8,
        defender::StaticPokemon,
        defBuff::Int8,
        move::FastMove,
        charge::Int8,
    )

Calculate the damage a particular pokemon does against another using its fast move

"""
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

"""
    calculate_damage(
        attacker::StaticPokemon,
        atkBuff::Int8,
        defender::StaticPokemon,
        defBuff::Int8,
        move::ChargedMove,
        charge::Int8,
    )

Calculate the damage a particular pokemon does against another using a charged move

"""
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

"""
    evaluate_fast_moves(state, static_state, agent)

Takes in the dynamic state, the static state, and the attacking agent and returns
the dynamic state after the fast move has occurred, with precisely one copy
"""
function evaluate_fast_moves(state::DynamicState, static_state::StaticState, team1::Bool, team2::Bool)
    @inbounds return DynamicState(@SVector[DynamicTeam(@SVector[
        (Int8(1) == state.teams[1].active ? DynamicPokemon(team2 ? abs(
            state.teams[1].mons[1].hp -
            calculate_damage(
                static_state.teams[2].mons[state.teams[2].active],
                get_atk(state.teams[2].buffs),
                static_state.teams[1].mons[1],
                get_def(state.teams[1].buffs),
                static_state.teams[2].mons[state.teams[2].active].fastMove,
                Int8(100),
            )) : state.teams[1].mons[1].hp,
        team1 ? min(state.teams[1].mons[1].energy + static_state.teams[1].mons[1].fastMove.energy, Int8(100)) : state.teams[1].mons[1].energy
        ) : state.teams[1].mons[1]),
        (Int8(2) == state.teams[1].active ? DynamicPokemon(team2 ? abs(
            state.teams[1].mons[2].hp -
            calculate_damage(
                static_state.teams[2].mons[state.teams[2].active],
                get_atk(state.teams[2].buffs),
                static_state.teams[1].mons[2],
                get_def(state.teams[1].buffs),
                static_state.teams[2].mons[state.teams[2].active].fastMove,
                Int8(100),
            )) : state.teams[1].mons[2].hp,
        team1 ? min(state.teams[1].mons[2].energy + static_state.teams[1].mons[2].fastMove.energy, Int8(100)) : state.teams[1].mons[2].energy
        ) : state.teams[1].mons[2]),
        (Int8(3) == state.teams[1].active ? DynamicPokemon(team2 ? abs(
            state.teams[1].mons[3].hp -
            calculate_damage(
                static_state.teams[2].mons[state.teams[2].active],
                get_atk(state.teams[2].buffs),
                static_state.teams[1].mons[3],
                get_def(state.teams[1].buffs),
                static_state.teams[2].mons[state.teams[2].active].fastMove,
                Int8(100),
            )) : state.teams[1].mons[3].hp,
        team1 ? min(state.teams[1].mons[3].energy + static_state.teams[1].mons[3].fastMove.energy, Int8(100)) : state.teams[1].mons[3].energy
        ) : state.teams[1].mons[3])], state.teams[1].buffs, state.teams[1].switchCooldown,
        state.teams[1].shields, state.teams[1].active),
        DynamicTeam(@SVector[
            (Int8(1) == state.teams[2].active ? DynamicPokemon(team1 ? abs(
                state.teams[2].mons[1].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[1],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].fastMove,
                    Int8(100),
                )) : state.teams[2].mons[1].hp,
            team2 ? min(state.teams[2].mons[1].energy + static_state.teams[2].mons[1].fastMove.energy, Int8(100)) : state.teams[2].mons[1].energy
            ) : state.teams[2].mons[1]),
            (Int8(2) == state.teams[2].active ? DynamicPokemon(team1 ? max(
                Int16(0),
                state.teams[2].mons[2].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[2],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].fastMove,
                    Int8(100),
                )) : state.teams[2].mons[2].hp,
            team2 ? min(state.teams[2].mons[2].energy + static_state.teams[2].mons[2].fastMove.energy, Int8(100)) : state.teams[2].mons[2].energy
            ) : state.teams[2].mons[2]),
            (Int8(3) == state.teams[2].active ? DynamicPokemon(team1 ? abs(
                state.teams[2].mons[3].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[3],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].fastMove,
                    Int8(100),
                )) : state.teams[2].mons[3].hp,
            team2 ? min(state.teams[2].mons[3].energy + static_state.teams[2].mons[3].fastMove.energy, Int8(100)) : state.teams[2].mons[3].energy
            ) : state.teams[2].mons[3])], state.teams[2].buffs, state.teams[2].switchCooldown,
            state.teams[2].shields, state.teams[2].active)], state.fastMovesPending)
end

function get_cmp(state::DynamicState, static_state::StaticState, team1throwing::Bool, team2throwing::Bool)
    !team1throwing && !team2throwing && return Int8(0), Int8(0)
    !team2throwing && return Int8(1), Int8(0)
    !team1throwing && return Int8(2), Int8(0)
    @inbounds static_state.teams[1].mons[state.teams[1].active].stats.attack > static_state.teams[2].mons[
        state.teams[2].active].stats.attack && return Int8(1), Int8(2)
    @inbounds static_state.teams[1].mons[state.teams[1].active].stats.attack < static_state.teams[2].mons[
        state.teams[2].active].stats.attack && return Int8(2), Int8(1)
    cmp = rand((Int8(1), Int8(2)))
    return cmp, (cmp == Int8(1) ? Int8(2) : Int8(1))
end

"""
    evaluate_charged_moves(state, static_state, cmp, move_id, charge, shielding, buffs_applied)

Takes in the dynamic state, the static state, the attacking agent, the move,
the charge, whether or not the opponent shields, and whether or not buffs are
applied (say in the case of a random buff move) and returns
the dynamic state after the charged move has occurred, with precisely one copy
"""
function evaluate_charged_moves(state::DynamicState, static_state::StaticState, cmp::Int8, move_id::Int8, charge::Int8, shielding::Bool, buffs_applied::Bool)
    if cmp == Int8(1)
        @inbounds return DynamicState(@SVector[DynamicTeam(@SVector[
            (Int8(1) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[1].hp,
            min(state.teams[1].mons[1].energy - static_state.teams[1].mons[1].chargedMoves[move_id].energy,
            Int8(100))) : state.teams[1].mons[1]),
            (Int8(2) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[2].hp,
            min(state.teams[1].mons[2].energy - static_state.teams[1].mons[2].chargedMoves[move_id].energy,
            Int8(100))) : state.teams[1].mons[2]),
            (Int8(3) == state.teams[1].active ? DynamicPokemon(state.teams[1].mons[3].hp,
            min(state.teams[1].mons[3].energy - static_state.teams[1].mons[3].chargedMoves[move_id].energy,
            Int8(100))) : state.teams[1].mons[3]),
            ], buffs_applied ? state.teams[1].buffs + static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id].self_buffs : state.teams[1].buffs,
            max(Int8(0), state.teams[1].switchCooldown - Int8(20)), state.teams[1].shields, state.teams[1].active),
            DynamicTeam((shielding ? state.teams[2].mons : @SVector[Int8(1) == state.teams[2].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[2].mons[1].hp -
                calculate_damage(
                    static_state.teams[1].mons[state.teams[1].active],
                    get_atk(state.teams[1].buffs),
                    static_state.teams[2].mons[1],
                    get_def(state.teams[2].buffs),
                    static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id],
                    charge,
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
                    charge,
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
                    charge,
                ),
            ), state.teams[2].mons[3].energy) : state.teams[2].mons[3]]),
            buffs_applied ? (state.teams[2].buffs + static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id].opp_buffs) : state.teams[2].buffs,
            max(Int8(0), state.teams[2].switchCooldown - Int8(20)), (shielding ? state.teams[2].shields - Int8(1) : state.teams[2].shields),
            state.teams[2].active)], state.fastMovesPending)
    else
        @inbounds return DynamicState(@SVector[
            DynamicTeam((shielding ? state.teams[1].mons : @SVector[Int8(1) == state.teams[1].active ? DynamicPokemon(max(
                Int16(0),
                state.teams[1].mons[1].hp -
                calculate_damage(
                    static_state.teams[2].mons[state.teams[2].active],
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1].mons[1],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].mons[state.teams[2].active].chargedMoves[move_id],
                    charge,
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
                    charge,
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
                    charge,
                ),
            ), state.teams[1].mons[3].energy) : state.teams[1].mons[3]]),
            buffs_applied ? (state.teams[1].buffs + static_state.teams[2].mons[state.teams[2].active].chargedMoves[move_id].opp_buffs) : state.teams[1].buffs,
            max(Int8(0), state.teams[1].switchCooldown - Int8(20)), (shielding ? state.teams[1].shields - Int8(1) : state.teams[1].shields),
            state.teams[1].active), DynamicTeam(@SVector[
                (Int8(1) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[1].hp,
                min(state.teams[2].mons[1].energy - static_state.teams[2].mons[1].chargedMoves[move_id].energy,
                charge)) : state.teams[2].mons[1]),
                (Int8(2) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[2].hp,
                min(state.teams[2].mons[2].energy - static_state.teams[2].mons[2].chargedMoves[move_id].energy,
                charge)) : state.teams[2].mons[2]),
                (Int8(3) == state.teams[2].active ? DynamicPokemon(state.teams[2].mons[3].hp,
                min(state.teams[2].mons[3].energy - static_state.teams[2].mons[3].chargedMoves[move_id].energy,
                charge)) : state.teams[2].mons[3]),
                ], buffs_applied ? state.teams[2].buffs + static_state.teams[1].mons[state.teams[1].active].chargedMoves[move_id].self_buffs : state.teams[2].buffs,
                max(Int8(0), state.teams[2].switchCooldown - Int8(20)), state.teams[2].shields, state.teams[2].active)], state.fastMovesPending)
    end
end

"""
    evaluate_switch(state, agent, to_switch, time)

Takes in the dynamic state, the switching agent, which team member they switch to,
and the time in the switch (only applies in switches after a faint) and returns
the dynamic state after the switch has occurred, with precisely one copy
"""
function evaluate_switch(state::DynamicState, agent::Int8, to_switch::Int8, time::Int8)
    @inbounds return agent == Int8(1) ? DynamicState(
        @SVector[DynamicTeam(state.teams[1].mons, defaultBuff, Int8(120), state.teams[1].shields, to_switch),
            DynamicTeam(state.teams[2].mons, state.teams[2].buffs, max(Int8(0), state.teams[2].switchCooldown - time),
            state.teams[2].shields, state.teams[2].active)],
        @SVector[Int8(-1), state.fastMovesPending[2]]) : DynamicState(
            @SVector[DynamicTeam(state.teams[1].mons, state.teams[1].buffs, max(Int8(0),
                state.teams[1].switchCooldown - time), state.teams[1].shields, state.teams[1].active),
                DynamicTeam(state.teams[2].mons, defaultBuff, Int8(120), state.teams[2].shields, to_switch)],
            @SVector[state.fastMovesPending[1], Int8(-1)])
end

"""
    step_timers(state, fmCooldown1, fmCooldown2)

Given the dynamic state and the fast move cooldowns, adjust the times so that
one turn has elapsed, and reset fast move cooldowns as needed. This returns a
new DynamicState using precisely one copy
"""
function step_timers(state::DynamicState, fmCooldown1::Int8, fmCooldown2::Int8)
    @inbounds return DynamicState(
        @SVector[DynamicTeam(state.teams[1].mons, state.teams[1].buffs, max(Int8(0), state.teams[1].switchCooldown - Int8(1)),
            state.teams[1].shields, state.teams[1].active), DynamicTeam(state.teams[2].mons, state.teams[2].buffs, max(Int8(0),
            state.teams[2].switchCooldown - Int8(1)), state.teams[2].shields, state.teams[2].active)],
        @SVector[fmCooldown1 == Int8(0) ? max(Int8(-1), state.fastMovesPending[1] - Int8(1)) : fmCooldown1 - Int8(1),
            fmCooldown2 == Int8(0) ? max(Int8(-1), state.fastMovesPending[2] - Int8(1)) : fmCooldown2 - Int8(1)])
end

"""
    get_min_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the first agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
function get_min_score(state::DynamicState, static_state::StaticState)
    return 0.5 * (static_state.teams[2].mons[1].stats.hitpoints -
      state.teams[2].mons[1].hp +
      static_state.teams[2].mons[2].stats.hitpoints -
      state.teams[2].mons[2].hp +
      static_state.teams[2].mons[3].stats.hitpoints -
      state.teams[2].mons[3].hp) /
     (static_state.teams[2].mons[1].stats.hitpoints +
      static_state.teams[2].mons[2].stats.hitpoints +
      static_state.teams[2].mons[3].stats.hitpoints)
end

"""
    get_max_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the second agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
function get_max_score(state::DynamicState, static_state::StaticState)
    return 0.5 + (0.5 * (state.teams[1].mons[1].hp + state.teams[1].mons[2].hp +
         state.teams[1].mons[3].hp) /
        (static_state.teams[1].mons[1].stats.hitpoints +
         static_state.teams[1].mons[2].stats.hitpoints +
         static_state.teams[1].mons[3].stats.hitpoints))
end

"""
    get_battle_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score for the battle. Note that this can also be computed for
battles in progress, and thus differs from PvPoke's use cases
"""
function get_battle_score(state::DynamicState, static_state::StaticState)
    return get_min_score(state, static_state) + get_max_score(state, static_state) - 0.5
end

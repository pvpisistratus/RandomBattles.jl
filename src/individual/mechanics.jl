"""
    get_buff_modifier(buff)

Compute the mulitplier associated with stat buffs (multiplied by 12 to return
an integer). As a result, the multiplier for no buff effect is 0. Inputs should
be between -4 and 4.

# Examples
```jldoctest
julia> get_buff_modifier(Int8(0))
12
"""
function get_buff_modifier(i::UInt32, agent::UInt8)
    a, d = agent == 0x01 ?
        (UInt8((i ÷ UInt32(13230))   % 9),
        UInt8((i ÷ UInt32(119070))   % 9)) :
        (UInt8((i ÷ UInt32(1071630)) % 9),
        UInt8((i ÷ UInt32(9644670))  % 9))
    a1, a2 = a > UInt8(3) ? (a, UInt8(4)) :
        (UInt8(4), UInt8(8) - a)
    d1, d2 = d > UInt8(3) ? (d, UInt8(4)) :
        (UInt8(4), UInt8(8) - d)
    return a1*d2, a2*d1
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

Calculate the damage a particular pokemon does against another using its fast
move

"""
function calculate_damage(
    attack::UInt16,
    buff_data::UInt32,
    agent::UInt8,
    defender::StaticPokemon,
    move::FastMove
)
    a, d = get_buff_modifier(buff_data, agent)
    return UInt16((Int64(move.power) * Int64(move.stab) *
        Int64(attack) * Int64(a) *
        floor(Int64, get_effectiveness(defender.primary_type,
        defender.secondary_type, move.moveType) *
        12_800) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(d) * 12_800_000) + 1)
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

Calculate the damage a particular pokemon does against another using a charged
move

"""
function calculate_damage(
    attack::UInt16,
    buff_data::UInt32,
    agent::UInt8,
    defender::StaticPokemon,
    move::ChargedMove,
    charge::Int8,
)
    a, d = get_buff_modifier(buff_data, agent)
    return UInt16((Int64(move.power) * Int64(move.stab) *
        Int64(attack) * Int64(a) *
        floor(Int64, get_effectiveness(defender.primary_type,
        defender.secondary_type, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(d) * 1_280_000_000) + 1)
end

evaluate_fast_moves(state::DynamicIndividualState,
    static_state::StaticIndividualState, using_fm::Tuple{Bool, Bool}) =
    DynamicIndividualState(
        add_energy(damage(state[0x01],
            using_fm[0x02] ? calculate_damage(
                static_state[0x02].stats.attack,
                state.data,
                0x02,
                static_state[0x01],
                static_state[0x02].fastMove,
            ) : 0x0000), (using_fm[0x01] ?
            static_state[0x01].fastMove.energy : Int8(0))),
        add_energy(damage(state[0x02],
            using_fm[0x01] ? calculate_damage(
                static_state[0x01].stats.attack,
                state.data,
                0x01,
                static_state[0x02],
                static_state[0x01].fastMove,
            ) : 0x0000), (using_fm[0x02] ?
            static_state[0x02].fastMove.energy : Int8(0))),
        state.data)

"""
    evaluate_charged_move(state, static_state, cmp, move_id, charge,
        shielding, buffs_applied)

Takes in the dynamic state, the static state, the attacking agent, the move,
the charge, whether or not the opponent shields, and whether or not buffs are
applied (say in the case of a random buff move) and returns
the dynamic state after the charged move has occurred, with precisely one copy
"""
function evaluate_charged_move(state::DynamicIndividualState,
    static_state::StaticIndividualState, cmp::UInt32, move_id::UInt8,
    charge::UInt8, shielding::Bool)
    next_state = state
    agent = isodd(cmp) ? 1 : 2
    d_agent = get_other_agent(agent)
    data = next_state.data
    move = move_id == 0x01 ? static_state[agent].charged_move_1 :
        static_state[agent].charged_move_2

    buff_chance = move.buffChance
    if buff_chance == Int8(100)
        data = apply_buff(data, move, agent)
    elseif buff_chance != Int8(0)
        data += agent == 0x01 ? move_id == 0x01 ? UInt32(2205) : UInt32(4410) :
                             move_id == 0x01 ? UInt32(6615) : UInt32(8820)
    end

    attacking_team = subtract_energy(next_state[agent], move.energy)

    if shielding
        defending_team = damage(next_state[d_agent], 0x0001)
        data -= d_agent == 0x01 ? 1 : 3
    else
        defending_team = damage(next_state[d_agent], calculate_damage(
                static_state[agent].stats.attack,
                state.data,
                agent,
                static_state[d_agent],
                move,
                Int8(100)
            ))
    end
    return DynamicIndividualState(
        @SVector[agent == 1 ? attacking_team : defending_team,
                 agent == 2 ? attacking_team : defending_team],
        # go from cmp 4 (2 then 1) to cmp 1
        # or go from cmp 3 (1 then 2) to cmp 2
        # or go from cmp 2 to 0
        # or go from cmp 1 to 0
        data  - (cmp == 4 ? (get_hp(defending_team) != 0x0000 ?
                    1323 : 1764) :
                (cmp == 3 ? (get_hp(defending_team) != 0x0000 ?
                    441 : 1323) :
                (cmp == 2 ? 882 : 441)))
    )
end

function apply_buff(data::UInt32, move::ChargedMove, agent::UInt8)
    buffs1 = get_buffs(data, 1)
    buffs2 = get_buffs(data, 2)
     return agent == 1 ? data + Int32(13230) * clamp(
        get_atk(move.self_buffs), -Int8(buffs1[1]), 9 - Int8(buffs1[1])) +
        Int32(119070) * clamp(get_def(move.opp_buffs),
        -Int8(buffs1[2]), 9 - Int8(buffs1[2]))  +
        Int32(1071630) * clamp(get_atk(move.opp_buffs),
        -Int8(buffs2[1]), 9 - Int8(buffs2[1]))  +
        Int32(9644670) * clamp(get_def(move.self_buffs),
        -Int8(buffs2[2]), 9 - Int8(buffs2[2])) :
        data + Int32(13230) * clamp(get_atk(move.opp_buffs),
        -Int8(buffs1[1]), 9 - Int8(buffs1[1])) +
        Int32(119070) * clamp(get_def(move.self_buffs),
        -Int8(buffs1[2]), 9 - Int8(buffs1[2]))  +
        Int32(1071630) * clamp(get_atk(move.self_buffs),
        -Int8(buffs2[1]), 9 - Int8(buffs2[1]))  +
        Int32(9644670) * clamp(get_def(move.opp_buffs),
        -Int8(buffs2[2]), 9 - Int8(buffs2[2]))
end

function step_timers(state::DynamicIndividualState, fmCooldown1::Int8,
    fmCooldown2::Int8)
    fmPending = get_fast_moves_pending(state)
    data = state.data
    if fmCooldown1 != Int8(0)
        data += (UInt32(fmCooldown1) - fmPending[1]) * 9
    elseif fmPending[1] != UInt32(0)
        data -= 9
    end
    if fmCooldown2 != Int8(0)
        data += (UInt32(fmCooldown2) - fmPending[2]) * 63
    elseif fmPending[2] != UInt32(0)
        data -= 63
    end

    return DynamicIndividualState(state[0x01], state[0x02], data)
end

"""
    min_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the first agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
function min_score(state::DynamicIndividualState,
    static_state::StaticIndividualState)
     return 0.5 * (static_state[0x02].stats.hitpoints - get_hp(state[0x02])) /
        static_state[0x02].stats.hitpoints
end

"""
    max_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the second agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
function max_score(state::DynamicIndividualState,
    static_state::StaticIndividualState)
     return 0.5 + 0.5 * get_hp(state[0x01]) / static_state[0x01].stats.hitpoints
end

"""
    battle_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score for the battle. Note that this can also be computed for
battles in progress, and thus differs from PvPoke's use cases
"""
function battle_score(state::DynamicIndividualState,
    static_state::StaticIndividualState)
    return get_min_score(state, static_state) +
        get_max_score(state, static_state) - 0.5
end

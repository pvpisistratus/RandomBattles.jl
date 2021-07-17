"""
    get_effectiveness(defenderTypes, moveType)

Compute the effectiveness of a particular move against a type combination.
In the example below, flying is super-effective against a pure fighting type.

# Examples
```jldoctest
julia> using StaticArrays; get_effectiveness(@SVector[Int8(2), Int8(19)], Int8(3))
1.6
"""
function get_effectiveness(defender_primary::Int8, defender_secondary::Int8,
    moveType::Int8)
    return type_effectiveness[defender_primary, moveType] *
            type_effectiveness[defender_secondary, moveType]
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
function get_buff_modifier(i::UInt8)
    a = i ÷ UInt8(27)
    d = (i ÷ UInt8(3)) % UInt8(9)
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

Calculate the damage a particular pokemon does against another using its fast move

"""
function calculate_damage(
    attack::UInt16,
    buff_data::UInt8,
    defender::StaticPokemon,
    move::FastMove
)
    a, d = get_buff_modifier(buff_data)
    return UInt16((Int64(move.power) * Int64(move.stab) *
        Int64(attack) * Int64(a) *
        floor(Int64, get_effectiveness(defender.primary_type,
        defender.secondary_type, move.moveType) *
        12_800) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(d) * 12_800_000) + 1)
end

"""
    calculate_damage(@inbounds
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
    attack::UInt16,
    buff_data::UInt8,
    defender::StaticPokemon,
    move::ChargedMove,
    charge::Int8,
)
    a, d = get_buff_modifier(buff_data)
    return UInt16((Int64(move.power) * Int64(move.stab) *
        Int64(attack) * Int64(a) *
        floor(Int64, get_effectiveness(defender.primary_type,
        defender.secondary_type, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(d) * 1_280_000_000) + 1)
end

"""
    evaluate_fast_moves(state, static_state, agent)

Takes in the dynamic state, the static state, and the attacking agent and returns
the dynamic state after the fast move has occurred, with precisely one copy
"""
function evaluate_fast_moves(state::DynamicState, static_state::StaticState,
        using_fm::Tuple{Bool, Bool})
    active = get_active(state)
    active_mon_1 = add_energy(damage(state[0x01][active[1]],
            using_fm[0x02] ? calculate_damage(
                static_state[0x02][active[2]].stats.attack,
                state[0x02].data,
                static_state[0x01][active[1]],
                static_state[0x02][active[2]].fastMove,
            ) : 0x0000), (using_fm[0x01] ?
            static_state[0x01][active[1]].fastMove.energy : Int8(0)))
    active_mon_2 = add_energy(damage(state[0x02][active[2]],
            using_fm[0x01] ? calculate_damage(
                static_state[0x01][active[1]].stats.attack,
                state[0x01].data,
                static_state[0x02][active[2]],
                static_state[0x01][active[1]].fastMove,
            ) : 0x0000), (using_fm[0x02] ?
            static_state[0x02][active[2]].fastMove.energy : Int8(0)))
    return DynamicState(
        DynamicTeam(
            active[1] == 0x0001 ? active_mon_1 : state[0x01][0x0001],
            active[1] == 0x0002 ? active_mon_1 : state[0x01][0x0002],
            active[1] == 0x0003 ? active_mon_1 : state[0x01][0x0003],
            state[0x01].switchCooldown,
            state[0x01].data
        ), DynamicTeam(
            active[2] == 0x0001 ? active_mon_2 : state[0x02][0x0001],
            active[2] == 0x0002 ? active_mon_2 : state[0x02][0x0002],
            active[2] == 0x0003 ? active_mon_2 : state[0x02][0x0003],
            state[0x02].switchCooldown,
            state[0x02].data
        ), state.data
    )
end


"""
    evaluate_charged_move(state, static_state, cmp, move_id, charge, shielding, buffs_applied)

Takes in the dynamic state, the static state, the attacking agent, the move,
the charge, whether or not the opponent shields, and whether or not buffs are
applied (say in the case of a random buff move) and returns
the dynamic state after the charged move has occurred, with precisely one copy
"""
function evaluate_charged_move(state::DynamicState, static_state::StaticState,
    cmp::UInt16, move_id::UInt8, charge::UInt8, shielding::Bool)
    next_state = state
    active = get_active(next_state)
    agent = isodd(cmp) ? 0x01 : 0x02
    d_agent = get_other_agent(agent)
    data = next_state.data
    a_data = next_state[agent].data
    d_data = next_state[d_agent].data
    move = move_id == 0x01 ? static_state[agent][active[agent]].charged_move_1 :
        static_state[agent][active[agent]].charged_move_2
    buff_chance = move.buffChance

    if buff_chance == Int8(100)
        a_data, d_data = apply_buff(a_data, d_data, move)
    elseif buff_chance != Int8(0)
        data += agent == 0x01 ? (move_id == 0x01 ? 0x0f50 : 0x1ea0) :
            (move_id == 0x01 ? 0x2df0 : 0x3d40)
    end

    attacking_team = DynamicTeam(
        active[agent] == 0x0001 ? subtract_energy(next_state[agent][0x0001],
            move.energy) : next_state[agent][0x0001],
        active[agent] == 0x0002 ? subtract_energy(next_state[agent][0x0002],
            move.energy) : next_state[agent][0x0002],
        active[agent] == 0x0003 ? subtract_energy(next_state[agent][0x0003],
            move.energy) : next_state[agent][0x0003],
        next_state[agent].switchCooldown,
        a_data
    )

    damage_dealt = shielding ? 0x0001 : calculate_damage(
        static_state[agent][active[agent]].stats.attack,
        state[agent].data,
        static_state[d_agent][active[d_agent]],
        move,
        Int8(100)
    )

    defending_team = DynamicTeam(
        active[d_agent] == 0x0001 ? damage(next_state[d_agent][0x0001],
            damage_dealt) : next_state[d_agent][0x0001],
        active[d_agent] == 0x0002 ? damage(next_state[d_agent][0x0002],
            damage_dealt) : next_state[d_agent][0x0002],
        active[d_agent] == 0x0003 ? damage(next_state[d_agent][0x0003],
            damage_dealt) : next_state[d_agent][0x0003],
        next_state[d_agent].switchCooldown,
        d_data - (shielding ? 0x01 : 0x00)
    )

    return DynamicState(
        agent == 0x01 ? attacking_team : defending_team,
        agent == 0x01 ? defending_team : attacking_team,
        # go from cmp 4 (2 then 1) to cmp 1
        # or go from cmp 3 (1 then 2) to cmp 2
        # or go from cmp 2 to 0
        # or go from cmp 1 to 0
        data  - (cmp == 0x0004 ?
                    (get_hp(defending_team[active[d_agent]]) != 0x0000 ?
                        0x0930 : 0x0c40) :
                (cmp == 0x0003 ?
                    (get_hp(defending_team[active[d_agent]]) != 0x0000 ?
                        0x0130 : 0x0930) :
                (cmp == 0x0002 ? 0x0620 : 0x0310)))
    )
end

function apply_buff(a_data::UInt8, d_data::UInt8, move::ChargedMove)
    a1 = a_data ÷ UInt8(27)
    d1 = (a_data ÷ UInt8(3)) % UInt8(9)
    a2 = d_data ÷ UInt8(27)
    d2 = (d_data ÷ UInt8(3)) % UInt8(9)
    return (a_data + Int8(27) * clamp(get_atk(move.self_buffs),
        -Int8(a1), Int8(9 - a1)) + Int8(3) * clamp(get_def(move.opp_buffs),
        -Int8(d1), Int8(9 - a1)), d_data + Int8(27) * clamp(
        get_atk(move.opp_buffs), -Int8(a2), Int8(9 - a1)) + Int8(3) *
        clamp(get_def(move.self_buffs), -Int8(d2), Int8(9 - a1))
    )
end

"""
    evaluate_switch(state, agent, to_switch, time)

Takes in the dynamic state, the switching agent, which team member they switch to,
and the time in the switch (only applies in switches after a faint) and returns
the dynamic state after the switch has occurred, with precisely one copy
"""
function evaluate_switch(state::DynamicState, agent::UInt8, active::UInt16,
    to_switch::UInt8, time::UInt8)
    data = state.data
    fmPending = get_fast_moves_pending(state)
    if agent == 0x01
        data += active == 0x0001 ? to_switch == 0x01 ? Int16(1)  : Int16(2) :
                active == 0x0002 ? to_switch == 0x01 ? Int16(-1) : Int16(1) :
                                   to_switch == 0x01 ? Int16(-2) : Int16(-1)
        data -= fmPending[1] * 0x0010
    else
        data += active == 0x0001 ? to_switch == 0x01 ? Int16(4)  : Int16(8) :
                active == 0x0002 ? to_switch == 0x01 ? Int16(-4) : Int16(4) :
                                   to_switch == 0x01 ? Int16(-8) : Int16(-8)
        data -= fmPending[2] * 0x0070
    end
    return DynamicState(
        DynamicTeam(state[0x01][0x0001],
            state[0x01][0x0002],
            state[0x01][0x0003],
            agent == 0x01 && time == 0x00 ? Int8(120) :
                state[0x01].switchCooldown -
                min(state[0x01].switchCooldown, time),
            state[0x01].data),
        DynamicTeam(state[0x02][0x0001],
            state[0x02][0x0002],
            state[0x02][0x0003],
            agent == 0x02 && time == 0x00 ? Int8(120) :
                state[0x02].switchCooldown -
                min(state[0x02].switchCooldown, time),
            state[0x02].data),
        data)
end

"""
    step_timers(state, fmCooldown1, fmCooldown2)

Given the dynamic state and the fast move cooldowns, adjust the times so that
one turn has elapsed, and reset fast move cooldowns as needed. This returns a
new DynamicState using precisely one copy
"""
function step_timers(state::DynamicState, fmCooldown1::Int8, fmCooldown2::Int8)
    fmPending = get_fast_moves_pending(state)
    data = state.data
    if fmCooldown1 != Int8(0)
        data += (UInt16(fmCooldown1) - fmPending[1]) * 0x0010
    elseif fmPending[1] != 0x0000
        data -= 0x0010
    end
    if fmCooldown2 != Int8(0)
        data += (UInt16(fmCooldown2) - fmPending[2]) * 0x0070
    elseif fmPending[2] != 0x0000
        data -= 0x0070
    end

    return DynamicState(
        DynamicTeam(state[0x01][0x0001], state[0x01][0x0002],
            state[0x01][0x0003], max(Int8(0), state[0x01].switchCooldown -
            Int8(1)), state[0x01].data),
        DynamicTeam(state[0x02][0x0001], state[0x02][0x0002],
            state[0x02][0x0003], max(Int8(0), state[0x02].switchCooldown -
            Int8(1)), state[0x02].data),
        data)
end

"""
    min_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the first agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
min_score(s::DynamicState, static_s::StaticState) = 0.5 *
    mapreduce(x -> get_hp(s[0x02][x]), +, 0x0001:0x0003) /
    mapreduce(x -> static_s[0x02][x].stats.hitpoints, +, 0x0001:0x0003)

"""
    max_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the second agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
max_score(s::DynamicState, static_s::StaticState) = 0.5 +
    0.5 * mapreduce(x -> get_hp(s[0x01][x]), +, 0x0001:0x0003) /
    mapreduce(x -> static_s[0x01][x].stats.hitpoints, +, 0x0001:0x0003)

"""
    battle_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score for the battle. Note that this can also be computed for
battles in progress, and thus differs from PvPoke's use cases
"""
battle_score(s::DynamicState, static_s::StaticState) =
    min_score(s, static_s) + max_score(s, static_s) - 0.5

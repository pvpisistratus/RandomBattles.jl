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
    return a1 * d2, a2 * d1
end

function evaluate_fast_moves(team::DynamicTeam, active::UInt8, dmg::UInt16,
    energy::Int8)
    active_mon = add_energy(damage(team[active], dmg), energy)
    return DynamicTeam(
        active == 0x01 ? active_mon : team[0x01],
        active == 0x02 ? active_mon : team[0x02],
        active == 0x03 ? active_mon : team[0x03],
        team.switchCooldown,
        team.data
    )
end

"""
    evaluate_fast_moves(state, static_state, agent)

Takes in the dynamic state, the static state, and the attacking agent and returns
the dynamic state after the fast move has occurred, with precisely one copy
"""
function evaluate_fast_moves(state::DynamicState, static_state::StaticState,
    using_fm::Tuple{Bool, Bool})
    active1, active2 = get_active(state)
    fm_dmg1, fm_dmg2 = get_fm_damage(state)

    return DynamicState(
        evaluate_fast_moves(state[0x01], active1,
            using_fm[2] ? fm_dmg1 : 0x0000,
            using_fm[1] ? get_energy(static_state[0x01][active1].fastMove) :
            Int8(0)),
        evaluate_fast_moves(state[0x02], active2,
            using_fm[1] ? fm_dmg2 : 0x0000,
            using_fm[2] ? get_energy(static_state[0x02][active2].fastMove) :
            Int8(0)),
        state.data
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
    cmp::UInt8, move_id::UInt8, charge::UInt8, shielding::Bool)
    next_state = state
    active1, active2 = get_active(next_state)
    a_active, d_active, agent, d_agent = isodd(cmp) ?
        (active1, active2, 0x01, 0x02) : (active2, active1, 0x02, 0x01)
    data = next_state.data
    a_data = next_state[agent].data
    d_data = next_state[d_agent].data
    move = move_id == 0x01 ? static_state[agent][a_active].charged_move_1 :
        static_state[agent][a_active].charged_move_2
    buff_chance = get_buff_chance(move)

    if buff_chance == 1.0
        a_data, d_data = apply_buff(a_data, d_data, move)
    elseif buff_chance != 0.0
        data += agent == 0x01 ? (move_id == 0x01 ? 0x0f50 : 0x1ea0) :
            (move_id == 0x01 ? 0x2df0 : 0x3d40)
    end

    attacking_team = DynamicTeam(
        a_active == 0x01 ? subtract_energy(next_state[agent][0x01],
            get_energy(move)) : next_state[agent][0x01],
        a_active == 0x02 ? subtract_energy(next_state[agent][0x02],
            get_energy(move)) : next_state[agent][0x02],
        a_active == 0x03 ? subtract_energy(next_state[agent][0x03],
            get_energy(move)) : next_state[agent][0x03],
        next_state[agent].switchCooldown,
        a_data
    )

    damage_dealt = shielding ? 0x0001 : calculate_damage(
        static_state[agent][a_active].stats.attack,
        state[agent].data,
        static_state[d_agent][d_active],
        move,
        Int8(100)
    )

    defending_team = DynamicTeam(
        d_active == 0x01 ? damage(next_state[d_agent][0x01], damage_dealt) :
            next_state[d_agent][0x01],
        d_active == 0x02 ? damage(next_state[d_agent][0x02], damage_dealt) :
            next_state[d_agent][0x02],
        d_active == 0x03 ? damage(next_state[d_agent][0x03], damage_dealt) :
            next_state[d_agent][0x03],
        next_state[d_agent].switchCooldown,
        d_data - (shielding ? 0x01 : 0x00)
    )

    next_state = DynamicState(
        agent == 0x01 ? attacking_team : defending_team,
        agent == 0x01 ? defending_team : attacking_team,
        # go from cmp 4 (2 then 1) to cmp 1
        # or go from cmp 3 (1 then 2) to cmp 2
        # or go from cmp 2 to 0
        # or go from cmp 1 to 0
        data  - (cmp == 0x04 ? (get_hp(defending_team[d_active]) != 0x0000 ?
            0x0930 : 0x0c40) : (cmp == 0x03 ?
            (get_hp(defending_team[d_active]) != 0x0000 ? 0x0310 : 0x0930) :
            (cmp == 0x02 ? 0x0620 : 0x0310)))
    )

    if buff_chance == Int8(100)
        return update_fm_damage(next_state, static_state)
    else
        return next_state
    end
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
    evaluate_switch(state, static_state, agent, to_switch, time)

Takes in the dynamic state, the switching agent, which team member they switch to,
and the time in the switch (only applies in switches after a faint) and returns
the dynamic state after the switch has occurred, with precisely one copy
"""
function evaluate_switch(state::DynamicState, static_state::StaticState,
    agent::UInt8, to_switch::UInt8, time::UInt8)
    data = state.data
    active1, active2 = get_active(state)
    fmPending = get_fast_moves_pending(state)
    if agent == 0x01
        data += active1 == 0x01 ? to_switch == 0x01 ? Int16(1)  : Int16(2) :
                active1 == 0x02 ? to_switch == 0x01 ? Int16(-1) : Int16(1) :
                                  to_switch == 0x01 ? Int16(-2) : Int16(-1)
        data -= fmPending[1] * UInt32(16)
    else
        data += active2 == 0x01 ? to_switch == 0x01 ? Int16(4)  : Int16(8) :
                active2 == 0x02 ? to_switch == 0x01 ? Int16(-4) : Int16(4) :
                                  to_switch == 0x01 ? Int16(-8) : Int16(-4)
        data -= fmPending[2] * UInt32(112)
    end
    next_state =  DynamicState(
        DynamicTeam(
            state[0x01][0x01], state[0x01][0x02], state[0x01][0x03],
            ((agent == 0x01 && time == 0x00) ? Int8(120) :
                state[0x01].switchCooldown -
                min(state[0x01].switchCooldown, time)),
            0x78 + state[0x01].data % 3),
        DynamicTeam(
            state[0x02][0x01], state[0x02][0x02], state[0x02][0x03],
            ((agent == 0x02 && time == 0x00) ? Int8(120) :
                state[0x02].switchCooldown -
                min(state[0x02].switchCooldown, time)),
            0x78 + state[0x02].data % 3),
        data)
    next_state = update_fm_damage(next_state, static_state)
    return next_state
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
    elseif fmPending[1] != 0x00
        data -= 0x0010
    end
    if fmCooldown2 != Int8(0)
        data += (UInt16(fmCooldown2) - fmPending[2]) * 0x0070
    elseif fmPending[2] != 0x00
        data -= 0x0070
    end

    return DynamicState(
        DynamicTeam(state[0x01][0x01], state[0x01][0x02], state[0x01][0x03],
            max(Int8(0), state[0x01].switchCooldown - Int8(1)),
            state[0x01].data),
        DynamicTeam(state[0x02][0x01], state[0x02][0x02], state[0x02][0x03],
            max(Int8(0), state[0x02].switchCooldown - Int8(1)),
            state[0x02].data),
        data)
end

"""
    min_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the first agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
min_score(s::DynamicState, static_s::StaticState) = 0.5 * mapreduce(x ->
    static_s[0x02][x].stats.hitpoints - get_hp(s[0x02][x]), +, 0x01:0x03) /
    mapreduce(x -> static_s[0x02][x].stats.hitpoints, +, 0x01:0x03)

"""
    max_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the second agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
max_score(s::DynamicState, static_s::StaticState) = 0.5 +
    0.5 * mapreduce(x -> get_hp(s[0x01][x]), +, 0x01:0x03) /
    mapreduce(x -> static_s[0x01][x].stats.hitpoints, +, 0x01:0x03)

"""
    battle_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score for the battle. Note that this can also be computed for
battles in progress, and thus differs from PvPoke's use cases
"""
battle_score(s::DynamicState, static_s::StaticState) =
    min_score(s, static_s) + max_score(s, static_s) - 0.5

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
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
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
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
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
    @inbounds new_mons = @SMatrix [UInt16(j) == active[i] ?
                    add_energy(damage(state.teams[i].mons[j],
                    using_fm[get_other_agent(i)] ? calculate_damage(
                        static_state.teams[get_other_agent(i)].mons[
                            active[get_other_agent(i)]].stats.attack,
                        state.teams[get_other_agent(i)].data,
                        static_state.teams[i].mons[j],
                        static_state.teams[get_other_agent(i)].mons[
                            active[get_other_agent(i)]].fastMove,
                    ) : 0x0000), (using_fm[i] ?
                    static_state.teams[i].mons[j].fastMove.energy :
                    Int8(0))) : state.teams[i].mons[j] for i = 1:2, j = 1:3]
    return DynamicState(@SVector[DynamicTeam(new_mons[1, :],
        state.teams[1].switchCooldown, state.teams[1].data),
        DynamicTeam(new_mons[2, :], state.teams[2].switchCooldown,
        state.teams[2].data)], state.data)
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
    agent = isodd(cmp) ? 1 : 2
    d_agent = get_other_agent(agent)
    data = next_state.data
    a_data = next_state.teams[agent].data
    d_data = next_state.teams[d_agent].data
    move = static_state.teams[agent].mons[active[agent]].chargedMoves[move_id]

    buff_chance = move.buffChance
    if buff_chance == Int8(100)
        a_data, d_data = apply_buff(a_data, d_data, move)
    elseif buff_chance != Int8(0)
        data += agent == 1 ? (move_id == 0x01 ? 0x0f50 : 0x1ea0) :
                             (move_id == 0x01 ? 0x2df0 : 0x3d40)
    end

    attacking_team = DynamicTeam(@SVector[
        subtract_energy(next_state.teams[agent].mons[i], move.energy)
        for i = 1:3], next_state.teams[agent].switchCooldown,
        a_data)

    if shielding
        defending_team = DynamicTeam(@SVector[UInt16(i) == active[d_agent] ?
            damage(next_state.teams[d_agent].mons[i], 0x0001) :
            next_state.teams[d_agent].mons[i] for i = 1:3],
            next_state.teams[d_agent].switchCooldown, d_data - UInt8(1))
    else
        defending_team = DynamicTeam(@SVector[
            UInt16(i) == active[d_agent] ? damage(next_state.teams[d_agent].mons[i],
            calculate_damage(
                static_state.teams[agent].mons[active[agent]].stats.attack,
                state.teams[agent].data,
                static_state.teams[d_agent].mons[active[d_agent]],
                move,
                Int8(100)
            )) : next_state.teams[d_agent].mons[i] for i = 1:3],
            next_state.teams[d_agent].switchCooldown, d_data)
    end
    return DynamicState(
        @SVector[agent == 1 ? attacking_team : defending_team,
                 agent == 2 ? attacking_team : defending_team],
        # go from cmp 4 (2 then 1) to cmp 1
        # or go from cmp 3 (1 then 2) to cmp 2
        # or go from cmp 2 to 0
        # or go from cmp 1 to 0
        data  - (cmp == 0x0004 ?
                    (get_hp(defending_team.mons[active[d_agent]]) != 0x0000 ?
                        0x0930 : 0x0c40) :
                (cmp == 0x0003 ?
                    (get_hp(defending_team.mons[active[d_agent]]) != 0x0000 ?
                        0x0130 : 0x0930) :
                (cmp == 0x0002 ? 0x0620 : 0x0310)))
    )
end

function apply_buff(a_data::UInt8, d_data::UInt8, move::ChargedMove)
    return (a_data + Int8(27) * get_atk(move.self_buffs) +
                     Int8(3) * get_def(move.opp_buffs),
            d_data + Int8(27) * get_atk(move.opp_buffs) +
                     Int8(3) * get_def(move.self_buffs)
    )
end

"""
    evaluate_switch(state, agent, to_switch, time)

Takes in the dynamic state, the switching agent, which team member they switch to,
and the time in the switch (only applies in switches after a faint) and returns
the dynamic state after the switch has occurred, with precisely one copy
"""
function evaluate_switch(state::DynamicState, agent::Int64, active::UInt16,
    to_switch::UInt8, time::UInt8)
    data = state.data
    fmPending = get_fast_moves_pending(state)
    if agent == 1
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
    return DynamicState(@SVector[
        DynamicTeam(state.teams[1].mons,
            agent == 1 && time == 0x00 ? Int8(120) :
            state.teams[1].switchCooldown -
            min(state.teams[1].switchCooldown, time),
            state.teams[1].data),
        DynamicTeam(state.teams[2].mons,
            agent == 2 && time == 0x00 ? Int8(120) :
            state.teams[2].switchCooldown -
            min(state.teams[2].switchCooldown, time),
            state.teams[2].data),
    ], data)
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
        data += (UInt16(fmCooldown1) + 0x0001 - fmPending[1]) * 0x0010
    elseif fmPending[1] != 0x0000
        data -= 0x0010
    end
    if fmCooldown2 != Int8(0)
        data += (UInt16(fmCooldown2) + 0x0001 - fmPending[2]) * 0x0070
    elseif fmPending[2] != 0x0000
        data -= 0x0070
    end

    return DynamicState(@SVector[DynamicTeam(state.teams[1].mons,
        max(Int8(0), state.teams[1].switchCooldown - Int8(1)),
        state.teams[1].data), DynamicTeam(state.teams[2].mons,
        max(Int8(0), state.teams[2].switchCooldown - Int8(1)),
        state.teams[2].data)], data)
end

"""
    get_min_score(state, static_state)

Given the state and the static state (here just for starting hp values), compute
the PvPoke-like score that would occur if the first agent stopped attacking
altogether. This is currently only used in computing the final score, but it
could be used as strict bounds for α/β pruning, for example.
"""
function get_min_score(state::DynamicState, static_state::StaticState)
    @inbounds return 0.5 * (static_state.teams[2].mons[1].stats.hitpoints -
      get_hp(state.teams[2].mons[1]) +
      static_state.teams[2].mons[2].stats.hitpoints -
      get_hp(state.teams[2].mons[2]) +
      static_state.teams[2].mons[3].stats.hitpoints -
      get_hp(state.teams[2].mons[3])) /
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
    @inbounds return 0.5 + (0.5 *
        (get_hp(state.teams[1].mons[1]) +
         get_hp(state.teams[1].mons[2]) +
         get_hp(state.teams[1].mons[3])) /
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

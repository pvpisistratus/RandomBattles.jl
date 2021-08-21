"""
    get_buff_modifier(buff)

Compute the mulitplier associated with stat buffs (multiplied by 12 to return an integer).
As a result, the multiplier for no buff effect is 0. Inputs should be between -4 and 4.

# Examples
```jldoctest
julia> get_buff_modifier(Int8(0))
12
"""
function get_buff_modifier(a::UInt8, d::UInt8)
    a1, a2 = a > UInt8(3) ? (a, UInt8(4)) : (UInt8(4), UInt8(8) - a)
    d1, d2 = d > UInt8(3) ? (d, UInt8(4)) : (UInt8(4), UInt8(8) - d)
    return a1 * d2, a2 * d1
end


struct EvaluateFastMovesOutput
    attacker_energy::UInt8
    defender_hp::UInt16
end

"""
    evaluate_fast_moves(state, static_state, agent)

Takes in the dynamic state, the static state, and the attacking agent and returns
the dynamic state after the fast move has occurred, with precisely one copy
"""
function evaluate_fast_move(static_state::StaticState, agent::UInt8, 
    attacker_active::UInt8, attacker_energy::UInt8, 
    defender_hp::UInt16, fm_dmg::UInt16)

    attacker_energy += get_energy(static_state[agent][attacker_active].fast_move)
    defender_hp -= min(defender_hp, fm_dmg)

    return EvaluateFastMovesOutput(attacker_energy, defender_hp)
end

struct EvaluateChargedMovesOutput
    chance::UInt8
    a1::UInt8
    d1::UInt8 
    a2::UInt8
    d2::UInt8
    fm_dmg_1::UInt16
    fm_dmg_2::UInt16
    attacker_energy::UInt8
    defender_hp::UInt16
    shields::UInt8
    cmp::UInt8
end

"""
    evaluate_charged_move(state, static_state, cmp, move_id, charge, shielding, buffs_applied)

Takes in the dynamic state, the static state, the attacking agent, the move,
the charge, whether or not the opponent shields, and whether or not buffs are
applied (say in the case of a random buff move) and returns
the dynamic state after the charged move has occurred, with precisely one copy
"""
function evaluate_charged_move(static_state::StaticState, cmp::UInt8, move_id::UInt8, 
    shielding::Bool, active_1::UInt8, active_2::UInt8, a1::UInt8, d1::UInt8, a2::UInt8, 
    d2::UInt8, attacker_energy::UInt8, defender_hp::UInt16, shields::UInt8, 
    fm_dmg_1::UInt16, fm_dmg_2::UInt16)

    a_active, d_active, agent, d_agent = isodd(cmp) ?
        (active_1, active_2, 0x01, 0x02) : (active_2, active_1, 0x02, 0x01)
    move = move_id == 0x01 ? static_state[agent][a_active].charged_move_1 :
        static_state[agent][a_active].charged_move_2

    chance = 0x00
    buff_chance = get_buff_chance(move)
    if buff_chance == 1.0
        a1, d1, a2, d2 = apply_buff(a1, d1, a2, d2, move)
        fm_dmg_1 = calculate_damage(static_state[0x01][active_1].stats.attack, 
            static_state[0x02][active_2].stats.defense, 
            (static_state[0x02][active_2].primary_type, static_state[0x02][active_2].secondary_type), 
            a1, d2, static_state[0x01][active_1].fast_move)
        fm_dmg_2 = calculate_damage(static_state[0x02][active_2].stats.attack, 
            static_state[0x01][active_1].stats.defense, 
            (static_state[0x01][active_1].primary_type, static_state[0x01][active_1].secondary_type), 
            a2, d1, static_state[0x02][active_2].fast_move)
    elseif !iszero(buff_chance)
        chance = agent == 0x01 ? (move_id == 0x01 ? 0x01 : 0x02) :
            (move_id == 0x01 ? 0x03 : 0x04)
    end

    attacker_energy -= get_energy(move)
    defender_hp -= shielding ? 0x0001 : min(defender_hp, 
        calculate_damage(static_state[agent][a_active].stats.attack, 
        static_state[d_agent][d_active].stats.defense, 
        (static_state[d_agent][d_active].primary_type, static_state[d_agent][d_active].secondary_type), 
        agent == 0x01 ? a1 : a2, agent == 0x02 ? d1 : d2, static_state[agent][a_active].fast_move))
    shields -= shielding ? 0x01 : 0x00
    cmp = defender_hp == 0x0000 || cmp < 0x03 ? 0x00 : cmp == 0x04 ? 0x01 : 0x02
    
    return EvaluateChargedMovesOutput(chance, a1, d1, a2, d2, fm_dmg_1, fm_dmg_2, attacker_energy, defender_hp, shields, cmp)
end

function apply_buff(a1::UInt8, d1::UInt8, a2::UInt8, d2::UInt8, move::ChargedMove)
    return clamp(iszero(get_buff_target(move)) ? a1 + get_atk(move.buff) : a1, 0x00, 0x09),
           clamp(iszero(get_buff_target(move)) ? d1 + get_def(move.buff) : d1, 0x00, 0x09), 
          clamp(!iszero(get_buff_target(move)) ? a2 + get_atk(move.buff) : a2, 0x00, 0x09),
          clamp(!iszero(get_buff_target(move)) ? d2 + get_def(move.buff) : d2, 0x00, 0x09)
end

struct EvaluateSwitchOutput
    active::UInt8
    switch_cooldown_1::UInt8
    switch_cooldown_2::UInt8 
    fm_dmg_1::UInt16 
    fm_dmg_2::UInt16
end

"""
    evaluate_switch(state, static_state, agent, to_switch, time)

Takes in the dynamic state, the switching agent, which team member they switch to,
and the time in the switch (only applies in switches after a faint) and returns
the dynamic state after the switch has occurred, with precisely one copy
"""
function evaluate_switch(static_state::StaticState, agent::UInt8, to_switch::UInt8, 
    time::UInt8, active_1::UInt8, active_2::UInt8, switch_cooldown_1::UInt8, 
    switch_cooldown_2::UInt8)

    active_1 = agent == 0x01 ? 
        (active_1 == 0x01 ? to_switch == 0x01 ? 0x02 : 0x03  :
         active_1 == 0x02 ? to_switch == 0x01 ? 0x01 : 0x03  :
                            to_switch == 0x01 ? 0x01 : 0x02) : active_1
    active_2 = agent == 0x02 ? 
        (active_2 == 0x01 ? to_switch == 0x01 ? 0x02 : 0x03  :
         active_2 == 0x02 ? to_switch == 0x01 ? 0x01 : 0x03  :
                            to_switch == 0x01 ? 0x01 : 0x02) : active_2
    
    switch_cooldown_1 = (agent == 0x01 && time == 0x00) ? 0x78 :
        switch_cooldown_1 - min(switch_cooldown_1, time)
    switch_cooldown_2 = (agent == 0x02 && time == 0x00) ? 0x78 :
        switch_cooldown_2 - min(switch_cooldown_2, time)

    fm_dmg_1 = calculate_damage(static_state[0x01][active_1].stats.attack, 
        static_state[0x02][active_2].stats.defense, 
        (static_state[0x02][active_2].primary_type, static_state[0x02][active_2].secondary_type), 
        0x04, 0x04, static_state[0x01][active_1].fast_move)
    fm_dmg_2 = calculate_damage(static_state[0x02][active_2].stats.attack, 
        static_state[0x01][active_1].stats.defense, 
        (static_state[0x01][active_1].primary_type, static_state[0x01][active_1].secondary_type), 
        0x04, 0x04, static_state[0x02][active_2].fast_move)

    return EvaluateSwitchOutput(agent == 0x01 ? active_1 : active_2, switch_cooldown_1, switch_cooldown_2, fm_dmg_1, fm_dmg_2)
end

struct StepTimersOutput
    fm_pending_1::UInt8 
    fm_pending_2::UInt8 
    switch_cooldown_1::UInt8 
    switch_cooldown_2::UInt8
end

"""
    step_timers(state, fmCooldown1, fmCooldown2)

Given the dynamic state and the fast move cooldowns, adjust the times so that
one turn has elapsed, and reset fast move cooldowns as needed. This returns a
new DynamicState using precisely one copy
"""
function step_timers(fm_cooldown_1::UInt8, fm_cooldown_2::UInt8, 
    fm_pending_1::UInt8, fm_pending_2::UInt8, 
    switch_cooldown_1::UInt8, switch_cooldown_2::UInt8)

    fm_pending_1 = !iszero(fm_cooldown_1) ? fm_cooldown_1 : 
                   !iszero(fm_pending_1)  ? fm_pending_1 - 0x01 : 0x00
    fm_pending_2 = !iszero(fm_cooldown_2) ? fm_cooldown_2 : 
                   !iszero(fm_pending_2)  ? fm_pending_2 - 0x01 : 0x00

    switch_cooldown_1 = max(0x00, switch_cooldown_1 - 0x01)
    switch_cooldown_2 = max(0x00, switch_cooldown_2 - 0x01)

    return StepTimersOutput(fm_pending_1, fm_pending_2, switch_cooldown_1, switch_cooldown_2)
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

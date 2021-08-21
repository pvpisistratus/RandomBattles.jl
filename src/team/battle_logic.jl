struct TurnOutput
    next_state_1::DynamicState
    next_state_2::DynamicState
    odds::Float64
end

function play_turn(state::DynamicState, static_state::StaticState,
    decision::Tuple{UInt8, UInt8})

    # unpack state
    active_1, active_2 = get_active(state)
    fm_pending_1, fm_pending_2 = get_fast_moves_pending(state)
    cmp = get_cmp(state)
    chance = 0x00
    fm_dmg_1, fm_dmg_2 = get_fm_damage(state)

    # unpack teams
    switch_cooldown_1, switch_cooldown_2 = state[0x01].switch_cooldown, state[0x02].switch_cooldown
    a1, d1 = get_buffs(state[0x01])
    a2, d2 = get_buffs(state[0x02])
    shields_1, shields_2 = get_shields(state[0x01]), get_shields(state[0x02])

    # unpack pokemon
    hp_1_1, hp_1_2, hp_1_3, hp_2_1, hp_2_2, hp_2_3 = 
        get_hp(state[0x01][0x01]), get_hp(state[0x01][0x02]), get_hp(state[0x01][0x03]),
        get_hp(state[0x02][0x01]), get_hp(state[0x02][0x02]), get_hp(state[0x02][0x03])
    energy_1_1, energy_1_2, energy_1_3, energy_2_1, energy_2_2, energy_2_3 = 
        get_energy(state[0x01][0x01]), get_energy(state[0x01][0x02]), get_energy(state[0x01][0x03]),
        get_energy(state[0x02][0x01]), get_energy(state[0x02][0x02]), get_energy(state[0x02][0x03])

    # if in charged move state
    if !iszero(cmp)
        agent, o_agent = isodd(cmp) ? (0x01, 0x02) : (0x02, 0x01)

        attacker_energy = agent == 0x01 ? (active_1 == 0x01 ? energy_1_1 : 
            active_1 == 0x02 ? energy_1_2 : energy_1_3) : 
            (active_2 == 0x01 ? energy_2_1 : active_2 == 0x02 ? 
            energy_2_2 : energy_2_3)
        defender_hp = agent == 0x01 ? 
            (active_2 == 0x01 ? hp_2_1 : active_2 == 0x02 ? hp_2_2 : hp_2_3) : 
            (active_1 == 0x01 ? hp_1_1 : active_1 == 0x02 ? hp_1_2 : hp_1_3)

        cm_output = evaluate_charged_move(static_state, cmp, decision[agent] - 0x06, 
            decision[o_agent] == 0x01, active_1, active_2, a1, d1, a2, d2, 
            attacker_energy, defender_hp, agent == 0x02 ? shields_1 : shields_2, 
            fm_dmg_1, fm_dmg_2)

        chance = cm_output.chance
        a1 = cm_output.a1
        d1 = cm_output.d1
        a2 = cm_output.a2
        d2 = cm_output.d2
        fm_dmg_1 = cm_output.fm_dmg_1
        fm_dmg_2 = cm_output.fm_dmg_2
        cmp = cm_output.cmp

        if agent == 0x01
            shields_2 = cm_output.shields
            fm_pending_1 = 0x00
            fm_pending_2 = min(0x01, fm_pending_2)
            active_1 == 0x01 ? energy_1_1 = cm_output.attacker_energy : active_1 == 0x02 ? 
                energy_1_2 = cm_output.attacker_energy : energy_1_3 = cm_output.attacker_energy
            active_2 == 0x01 ? hp_2_1 = cm_output.defender_hp : active_2 == 0x02 ? 
                hp_2_2 = cm_output.defender_hp : hp_2_3 = cm_output.defender_hp
        else
            shields_1 = cm_output.shields
            fm_pending_1 = min(0x01, fm_pending_1)
            fm_pending_2 = 0x00
            active_1 == 0x01 ? hp_1_1 = cm_output.defender_hp : active_1 == 0x02 ? 
                hp_1_2 = cm_output.defender_hp : hp_1_3 = cm_output.defender_hp
            active_2 == 0x01 ? energy_2_1 = cm_output.attacker_energy : active_2 == 0x02 ? 
                energy_2_2 = cm_output.attacker_energy : energy_2_3 = cm_output.attacker_energy
        end
    else
        # evaluate fast moves
        defender_hp_1 = active_1 == 0x01 ? hp_1_1 : active_1 == 0x02 ? hp_1_2 : hp_1_3
        defender_hp_2 = active_2 == 0x01 ? hp_2_1 : active_2 == 0x02 ? hp_2_2 : hp_2_3
        if fm_pending_1 == 0x01 && !iszero(defender_hp_1)
            attacker_energy = active_1 == 0x01 ? energy_1_1 : active_1 == 0x02 ? energy_1_2 : energy_1_3
            fm_output = evaluate_fast_move(static_state, 0x01, 
                active_1, attacker_energy, defender_hp_2, fm_dmg_1)
            active_1 == 0x01 ? energy_1_1 = fm_output.attacker_energy : active_1 == 0x02 ? 
                energy_1_2 = fm_output.attacker_energy : energy_1_3 = fm_output.attacker_energy
            active_2 == 0x01 ? hp_2_1 = fm_output.defender_hp : active_2 == 0x02 ? 
                hp_2_2 = fm_output.defender_hp : hp_2_3 = fm_output.defender_hp
        end
        if fm_pending_2 == 0x01 && !iszero(defender_hp_2)
            attacker_energy = active_2 == 0x01 ? energy_2_1 : active_2 == 0x02 ? energy_2_2 : energy_2_3
            fm_output = evaluate_fast_move(static_state, 0x02, 
                active_2, attacker_energy, defender_hp_1, fm_dmg_2)
            active_2 == 0x01 ? energy_2_1 = fm_output.attacker_energy : active_2 == 0x02 ? 
                energy_2_2 = fm_output.attacker_energy : energy_2_3 = fm_output.attacker_energy
            active_1 == 0x01 ? hp_1_1 = fm_output.defender_hp : active_1 == 0x02 ? 
                hp_1_2 = fm_output.defender_hp : hp_1_3 = fm_output.defender_hp
        end

        # step timers
        fm_cooldown_1 = decision[1] == 0x03 ? get_cooldown(static_state[0x01][active_1].fast_move) : 0x00
        fm_cooldown_2 = decision[2] == 0x03 ? get_cooldown(static_state[0x02][active_2].fast_move) : 0x00
        step_timers_output = step_timers(fm_cooldown_1, 
            fm_cooldown_2, fm_pending_1, fm_pending_2, switch_cooldown_1, switch_cooldown_2)
        fm_pending_1 = step_timers_output.fm_pending_1
        fm_pending_2 = step_timers_output.fm_pending_2
        switch_cooldown_1 = step_timers_output.switch_cooldown_1
        switch_cooldown_2 = step_timers_output.switch_cooldown_2

        # evaluate switches
        if decision[1] == 0x05 || decision[1] == 0x06
            active_hp_1 = active_1 == 0x01 ? hp_1_1 : active_1 == 0x02 ? hp_1_2 : hp_1_3
            switch_output = evaluate_switch(static_state, 0x01, decision[1] - 0x04, 
                    iszero(active_hp_1) ? 0x18 : 0x00, 
                    active_1, active_2, switch_cooldown_1, switch_cooldown_2)
                    
            active_1 = switch_output.active
            switch_cooldown_1 = switch_output.switch_cooldown_1
            switch_cooldown_2 = switch_output.switch_cooldown_2
            fm_dmg_1 = switch_output.fm_dmg_1
            fm_dmg_2 = switch_output.fm_dmg_2

            fm_pending_1 = 0x00
            a1, d1 = 0x04, 0x04
        end
        if decision[2] == 0x05 || decision[2] == 0x06
            active_hp_2 = active_2 == 0x01 ? hp_2_1 : active_2 == 0x02 ? hp_2_2 : hp_2_3
            switch_output = evaluate_switch(static_state, 0x02, decision[2] - 0x04, 
                    iszero(active_hp_2) ? 0x18 : 0x00, 
                    active_1, active_2, switch_cooldown_1, switch_cooldown_2)
            
            active_2 = switch_output.active
            switch_cooldown_1 = switch_output.switch_cooldown_1
            switch_cooldown_2 = switch_output.switch_cooldown_2
            fm_dmg_1 = switch_output.fm_dmg_1
            fm_dmg_2 = switch_output.fm_dmg_2

            fm_pending_2 = 0x00
            a2, d2 = 0x04, 0x04
        end

        active_hp_1 = active_1 == 0x01 ? hp_1_1 : active_1 == 0x02 ? hp_1_2 : hp_1_3
        active_hp_2 = active_2 == 0x01 ? hp_2_1 : active_2 == 0x02 ? hp_2_2 : hp_2_3
        if !iszero(active_hp_1) && !iszero(active_hp_2)
            if decision[1] == 0x04
                if decision[2] == 0x04
                    atk_cmp = Base.cmp(
                        static_state[0x01][active_1].stats.attack,
                        static_state[0x02][active_2].stats.attack
                    )
                    atk_cmp == 1 ? cmp = 0x03 : atk_cmp == -1 ? cmp = 0x04 : chance = 0x05
                else
                    cmp = 0x01
                end
            elseif decision[2] == 0x04
                cmp = 0x02
            end
        end
    end

    # check chance and repack
    if iszero(chance)
        # no chance to evaluate
        next_state_1 = DynamicState(
            DynamicTeam(
                DynamicPokemon(hp_1_1, energy_1_1), 
                DynamicPokemon(hp_1_2, energy_1_2), 
                DynamicPokemon(hp_1_3, energy_1_3), 
                switch_cooldown_1, a1, d1, shields_1
            ), DynamicTeam(
                DynamicPokemon(hp_2_1, energy_2_1), 
                DynamicPokemon(hp_2_2, energy_2_2), 
                DynamicPokemon(hp_2_3, energy_2_3), 
                switch_cooldown_2, a2, d2, shields_2
            ), active_1, active_2, fm_pending_1, fm_pending_2, cmp, 0x00, fm_dmg_1, fm_dmg_2
        )
        next_state_2 = next_state_1
        odds = 1.0
    elseif chance == 0x05
        # decide randomly who gets cmp
        next_state_1 = DynamicState(
            DynamicTeam(
                DynamicPokemon(hp_1_1, energy_1_1), 
                DynamicPokemon(hp_1_2, energy_1_2), 
                DynamicPokemon(hp_1_3, energy_1_3), 
                switch_cooldown_1, a1, d1, shields_1
            ), DynamicTeam(
                DynamicPokemon(hp_2_1, energy_2_1), 
                DynamicPokemon(hp_2_2, energy_2_2), 
                DynamicPokemon(hp_2_3, energy_2_3), 
                switch_cooldown_2, a2, d2, shields_2
            ), active_1, active_2, fm_pending_1, fm_pending_2, 0x03, 0x00, fm_dmg_1, fm_dmg_2
        )
        next_state_2 = DynamicState(
            DynamicTeam(
                DynamicPokemon(hp_1_1, energy_1_1), 
                DynamicPokemon(hp_1_2, energy_1_2), 
                DynamicPokemon(hp_1_3, energy_1_3), 
                switch_cooldown_1, a1, d1, shields_1
            ), DynamicTeam(
                DynamicPokemon(hp_2_1, energy_2_1), 
                DynamicPokemon(hp_2_2, energy_2_2), 
                DynamicPokemon(hp_2_3, energy_2_3), 
                switch_cooldown_2, a2, d2, shields_2
            ), active_1, active_2, fm_pending_1, fm_pending_2, 0x04, 0x00, fm_dmg_1, fm_dmg_2
        )
        odds = 0.5
    else
        # apply or don't apply a buff from a charged move
        next_state_2 = DynamicState(
            DynamicTeam(
                DynamicPokemon(hp_1_1, energy_1_1), 
                DynamicPokemon(hp_1_2, energy_1_2), 
                DynamicPokemon(hp_1_3, energy_1_3), 
                switch_cooldown_1, a1, d1, shields_1
            ), DynamicTeam(
                DynamicPokemon(hp_2_1, energy_2_1), 
                DynamicPokemon(hp_2_2, energy_2_2), 
                DynamicPokemon(hp_2_3, energy_2_3), 
                switch_cooldown_2, a2, d2, shields_2
            ), active_1, active_2, fm_pending_1, fm_pending_2, cmp, 0x00, fm_dmg_1, fm_dmg_2
        )

        move = isodd(chance) ?
            static_state[chance < 0x03 ? 0x01 : 0x02][active_1].charged_move_1 :
            static_state[chance < 0x03 ? 0x01 : 0x02][active_2].charged_move_2
        a1, d1, a2, d2 = apply_buff(a1, d1, a2, d2, move)

        next_state_1 =  DynamicState(
            DynamicTeam(
                DynamicPokemon(hp_1_1, energy_1_1), 
                DynamicPokemon(hp_1_2, energy_1_2), 
                DynamicPokemon(hp_1_3, energy_1_3), 
                switch_cooldown_1, a1, d1, shields_1
            ), DynamicTeam(
                DynamicPokemon(hp_2_1, energy_2_1), 
                DynamicPokemon(hp_2_2, energy_2_2), 
                DynamicPokemon(hp_2_3, energy_2_3), 
                switch_cooldown_2, a2, d2, shields_2
            ), active_1, active_2, fm_pending_1, fm_pending_2, cmp, 0x00, fm_dmg_1, fm_dmg_2
        )
        odds = get_buff_chance(move)
    end

    return TurnOutput(next_state_1, next_state_2, odds)
end

"""
    play_battle(state, static_state)

Play through one battle, starting from the inputted state with random,
equally weighted decisions.
"""
function play_battle(state::DynamicState, static_state::StaticState;
  allow_nothing::Bool = false, allow_overfarming::Bool = false)
    while true
        d1, d2 = get_possible_decisions(state, static_state,
            allow_nothing = allow_nothing,
            allow_overfarming = allow_overfarming)
        (iszero(d1) || iszero(d2)) &&
            return battle_score(state, static_state)
        turn_output = play_turn(
            state, static_state, select_random_decision(d1, d2))
        if turn_output.odds == 1.0
            state = turn_output.next_state_1
        else
            state = rand(rb_rng) < turn_output.odds ? 
                turn_output.next_state_1 : turn_output.next_state_2
        end
    end
end

"""
    battle_scores(state, static_state, N)

Play through N battles, starting from the inputted state with random,
equally weighted decisions.
"""
function battle_scores(starting_state::DynamicState,
  static_state::StaticState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

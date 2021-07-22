function play_turn(state::DynamicState, static_state::StaticState,
    decision::Tuple{UInt8, UInt8})
    next_state = state

    fm_pending = get_fast_moves_pending(state)
    active1, active2 = get_active(next_state)
    cmp = get_cmp(state)

    if !iszero(cmp)
        agent, o_agent = isodd(cmp) ? (0x01, 0x02) : (0x02, 0x01)
        next_state = evaluate_charged_move(next_state, static_state, cmp,
            decision[agent] - 0x06, 0x64, decision[o_agent] == 0x01)
        data = next_state.data - UInt32(fm_pending[agent]) *
            UInt32(agent == 0x01 ? 0x10 : 0x70)
        if !iszero(fm_pending[o_agent])
            data -= UInt32(fm_pending[o_agent] - 0x01) *
                UInt32(o_agent == 0x01 ? 0x10 : 0x70)
        end
        next_state = DynamicState(next_state[0x01], next_state[0x02], data)
    else
        if fm_pending[1] == 0x01 || fm_pending[2] == 0x01
            next_state = evaluate_fast_moves(next_state, static_state,
                (fm_pending[1] == 0x01 &&
                    get_hp(next_state[0x01][active1]) != 0x0000,
                fm_pending[2] == 0x01 &&
                    get_hp(next_state[0x02][active2]) != 0x0000))
        end

        next_state = step_timers(next_state,
            decision[1] == 0x03 ?
                static_state[0x01][active1].fastMove.cooldown : Int8(0),
            decision[2] == 0x03 ?
                static_state[0x02][active2].fastMove.cooldown : Int8(0))
        if decision[1] == 0x05 || decision[1] == 0x06
            next_state = evaluate_switch(next_state,
                static_state, 0x01, decision[1] - 0x04,
                iszero(get_hp(state[0x01][active1])) ?
                0x18 : 0x00)
        end
        if decision[2] == 0x05 || decision[2] == 0x06
            next_state = evaluate_switch(next_state,
                static_state, 0x02, decision[2] - 0x04,
                iszero(get_hp(state[0x02][active2])) ?
                0x18 : 0x00)
        end
        active1, active2 = get_active(next_state)

        if get_hp(next_state[0x01][active1]) != 0x0000 &&
            get_hp(next_state[0x02][active2]) != 0x0000
            if decision[1] == 0x04
                if decision[2] == 0x04
                    atk_cmp = Base.cmp(
                        static_state[0x01][active1].stats.attack,
                        static_state[0x02][active2].stats.attack
                    )
                    return DynamicState(next_state[0x01],
                        next_state[0x02], next_state.data +
                        (atk_cmp == 1 ? UInt32(2352) :
                        atk_cmp == -1 ? UInt32(3136) : UInt32(19600)))
                else
                    return DynamicState(next_state[0x01],
                        next_state[0x02], next_state.data + UInt32(784))
                end
            elseif decision[2] == 0x04
                return DynamicState(next_state[0x01],
                    next_state[0x02], next_state.data + UInt32(2*784))
            end
        end
    end

    return next_state
end

function resolve_chance(state::DynamicState, static_state::StaticState)
    chance = get_chance(state)
    if chance == 0x00
        return state
    elseif chance == 0x05
        return rand() < 0.5 ?
            # subtract chance, add cmp
            DynamicState(state[0x01], state[0x02],
            state.data - 0x4360) : DynamicState(state[0x01],
            state[0x02], state.data - 0x4050)
    else
        active1, active2 = get_active(state)
        agent, o_agent = chance < 0x03 ? (0x01, 0x02) : (0x02, 0x01)
        move = isodd(chance) ?
            static_state[agent][active1].charged_move_1 :
            static_state[agent][active2].charged_move_2
        if rand(Int8(0):Int8(99)) < move.buffChance
            a_data = state[agent].data
            d_data = state[o_agent].data
            a_data, d_data = apply_buff(a_data, d_data, move)
            return update_fm_damage(DynamicState(
                DynamicTeam(state[0x01][0x01], state[0x01][0x02],
                    state[0x01][0x03], state[0x01].switchCooldown,
                    agent == 0x01 ? a_data : d_data),
                DynamicTeam(state[0x02][0x01], state[0x02][0x02],
                    state[0x02][0x03], state[0x02].switchCooldown,
                    agent == 0x02 ? a_data : d_data),
                state.data - UInt32(chance) * UInt32(3920)), static_state)
        else
            return DynamicState(state[0x01], state[0x02],
                state.data - UInt32(chance) * UInt32(3920))
        end
    end
end

"""
    play_battle(state, static_state)

Play through one battle, starting from the inputted state with random,
equally weighted decisions.
"""
function play_battle(state::DynamicState, static_state::StaticState;
  allow_nothing::Bool = false, allow_overfarming::Bool = false)
    active1, active2 = get_active(state)
    while true
        state = resolve_chance(state, static_state)
        d1, d2 = get_possible_decisions(state, static_state,
            allow_nothing = allow_nothing,
            allow_overfarming = allow_overfarming)
        (iszero(d1) || iszero(d2)) &&
            return battle_score(state, static_state)
        state = play_turn(
            state, static_state, select_random_decision(d1, d2))
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

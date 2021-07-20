function play_turn(state::DynamicState, static_state::StaticState,
    decision::Tuple{UInt8, UInt8})
    next_state = state

    fm_pending = get_fast_moves_pending(state)
    active = get_active(next_state)
    cmp = get_cmp(state)

    if !iszero(cmp)
        agent = isodd(cmp) ? 0x01 : 0x02
        next_state = evaluate_charged_move(next_state,
            static_state, cmp, decision[agent] == 0x07 ? 0x01 : 0x02,
            0x64, decision[get_other_agent(agent)] == 0x01)
        if !iszero(fm_pending[get_other_agent(agent)])
            next_state = DynamicState(next_state[0x01], next_state[0x02],
                next_state.data - (fm_pending[get_other_agent(agent)] -
                0x0001) * (agent == 0x02 ? 0x0010 : 0x0070))
        end
        next_state = DynamicState(next_state[0x01], next_state[0x02],
            next_state.data - fm_pending[agent] *
            (agent == 0x01 ? 0x0010 : 0x0070))
    else
        if fm_pending[1] == 0x0001 || fm_pending[2] == 0x0001
            next_state = evaluate_fast_moves(next_state, static_state,
                (fm_pending[1] == 0x0001 &&
                get_hp(next_state[0x01][active[1]]) != 0x0000,
                fm_pending[2] == 0x0001 &&
                get_hp(next_state[0x02][active[2]]) != 0x0000))
        end

        next_state = step_timers(next_state,
            decision[1] == 0x03 ?
                static_state[0x01][active[1]].fastMove.cooldown : Int8(0),
            decision[2] == 0x03 ?
                static_state[0x02][active[2]].fastMove.cooldown : Int8(0))
        for agent = 0x01:0x02
            if decision[agent] == 0x05 || decision[agent] == 0x06
                next_state = evaluate_switch(next_state,
                    static_state, agent, active[agent], decision[agent] - 0x04,
                    iszero(get_hp(state[agent][active[agent]])) ?
                    0x18 : 0x00)
            end
        end
        new_active = get_active(next_state)
        if get_hp(next_state[0x01][new_active[1]]) != 0x0000 &&
            get_hp(next_state[0x02][new_active[2]]) != 0x0000
            if decision[1] == 0x04
                if decision[2] == 0x04
                    atk_cmp = Base.cmp(
                        static_state[0x01][active[1]].stats.attack,
                        static_state[0x02][active[2]].stats.attack
                    )
                    if atk_cmp == 1
                        next_state = DynamicState(next_state[0x01],
                            next_state[0x02], next_state.data + 0x0930)
                    elseif atk_cmp == -1
                        next_state = DynamicState(next_state[0x01],
                            next_state[0x02], next_state.data + 0x0c40)
                    else
                        next_state = DynamicState(next_state[0x01],
                            next_state[0x02], next_state.data + 0x4c90)
                    end
                else
                    next_state = DynamicState(next_state[0x01],
                        next_state[0x02], next_state.data + 0x0310)
                end
            elseif decision[2] == 0x04
                next_state = DynamicState(next_state[0x01],
                    next_state[0x02], next_state.data + 0x0620)
            end
        end
    end

    return next_state
end

function resolve_chance(state::DynamicState, static_state::StaticState)
    chance = get_chance(state)
    if chance == 0x0000
        return state
    elseif chance == 0x0005
        return rand() < 0.5 ?
            # subtract chance, add cmp
            DynamicState(state[0x01], state[0x02],
            state.data - 0x4360) : DynamicState(state[0x01],
            state[0x02], state.data - 0x4050)
    else
        active = get_active(state)
        agent = chance < 0x0003 ? 0x01 : 0x02
        move = isodd(chance) ?
            static_state[agent][active[agent]].charged_move_1 :
            static_state[agent][active[agent]].charged_move_2
        if rand(Int8(0):Int8(99)) < move.buffChance
            a_data = state[agent].data
            d_data = state[get_other_agent(agent)].data
            a_data, d_data = apply_buff(a_data, d_data, move)
            next_state = DynamicState(
                DynamicTeam(state[0x01][0x0001], state[0x01][0x0002],
                    state[0x01][0x0003], state[0x01].switchCooldown,
                    agent == 0x01 ? a_data : d_data),
                DynamicTeam(state[0x02][0x0001], state[0x02][0x0002],
                    state[0x02][0x0003], state[0x02].switchCooldown,
                    agent == 0x02 ? a_data : d_data),
                state.data - chance * 0x0f50)
            return update_fm_damage(next_state, get_fast_move_damages(
                next_state, static_state, active[1], active[2]))
        else
            return DynamicState(state[0x01], state[0x02],
                state.data - chance * 0x0f50)
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

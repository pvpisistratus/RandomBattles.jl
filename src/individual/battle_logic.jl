function play_turn(state::DynamicIndividualState,
    next_state = state

    fm_pending = get_fast_moves_pending(state)
    active = get_active(next_state)
    cmp = get_cmp(state)

    if !iszero(cmp)
        agent = isodd(cmp) ? 1 : 2
        @inbounds next_state = evaluate_charged_move(next_state,
            static_state, cmp, decision[agent] == 0x05 ? 0x01 : 0x02,
            0x64, decision[get_other_agent(agent)] == 0x01)
        @inbounds if !iszero(fm_pending[get_other_agent(agent)])
            @inbounds next_state = DynamicState(next_state.teams,
                next_state.data - (fm_pending[get_other_agent(agent)] -
                0x0001) * (get_other_agent(agent) == 1 ? UInt32(9) :
                UInt32(63)))
        end
        @inbounds next_state = DynamicState(next_state.teams,
            next_state.data - fm_pending[agent] * (agent == 1 ? UInt32(9) :
            UInt32(63)))
    else
        @inbounds if fm_pending[1] == UInt32(1) || fm_pending[2] == UInt32(1)
            next_state = evaluate_fast_moves(next_state, static_state,
                (fm_pending[1] == UInt32(1) &&
                get_hp(next_state.teams[1]) != 0x0000,
                fm_pending[2] == UInt32(1) &&
                get_hp(next_state.teams[2]) != 0x0000))
        end

        @inbounds next_state = step_timers(next_state,
            decision[1] == 0x03 ?
                static_state.teams[1].fastMove.cooldown : Int8(0),
            decision[2] == 0x03 ?
                static_state.teams[2].fastMove.cooldown : Int8(0))

        if get_hp(next_state.teams[1]) != 0x0000 &&
            get_hp(next_state.teams[2]) != 0x0000
            if decision[1] == 0x04
                if decision[2] == 0x04
                    atk_cmp = Base.cmp(
                        static_state.teams[1].stats.attack,
                        static_state.teams[2].stats.attack
                    )
                    if atk_cmp == 1
                        next_state = DynamicState(next_state.teams,
                            next_state.data + UInt32(1323))
                    elseif atk_cmp == -1
                        next_state = DynamicState(next_state.teams,
                            next_state.data + UInt32(1764))
                    else
                        next_state = DynamicState(next_state.teams,
                            next_state.data + UInt32(11025))
                    end
                else
                    next_state = DynamicState(next_state.teams,
                        next_state.data + UInt32(441))
                end
            elseif decision[2] == 0x04
                next_state = DynamicState(next_state.teams,
                    next_state.data + UInt32(882))
            end
        end
    end

    return next_state
end

function play_battle(starting_state::DynamicIndividualState, static_state::StaticIndividualState)
    state = starting_state
    while true
        weights1, weights2 = get_possible_decisions(state, static_state, 1), get_possible_decisions(state, static_state, 2)
        (iszero(weights1) || iszero(weights2)) && return get_battle_score(state, static_state)
        state = play_turn(state, static_state, select_random_decision(weights1, weights2))
    end
end

function get_battle_scores(starting_state::DynamicIndividualState, static_state::StaticIndividualState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

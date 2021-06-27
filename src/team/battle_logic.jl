function play_turn(state::DynamicState, static_state::StaticState, decision::Tuple{UInt8, UInt8})
    next_state = state

    fm_pending = get_fast_moves_pending(state)

    @inbounds if fm_pending[1] == 0x0001 || fm_pending[2] == 0x0001
        next_state = evaluate_fast_moves(next_state, static_state,
            (fm_pending[1] == 0x0001, fm_pending[2] == 0x0001))
    end

    active = get_active(next_state)
    cmp = get_cmp(state)

    if !iszero(cmp)
        agent = isodd(cmp) ? 1 : 2
        @inbounds next_state = evaluate_charged_move(next_state,
            static_state, cmp, decision[agent] == 0x07 ? 0x01 : 0x02,
            0x64, decision[get_other_agent(agent)] == 0x01)
        @inbounds if !iszero(fm_pending[get_other_agent(agent)])
            @inbounds next_state = evaluate_fast_moves(next_state,
                static_state, (1 == agent, 2 == agent))
        end
    else
        @inbounds next_state = step_timers(next_state,
            decision[1] == 0x03 ?
                static_state.teams[1].mons[active[1]].fastMove.cooldown :
                Int8(0),
            decision[2] == 0x03 ?
                static_state.teams[2].mons[active[2]].fastMove.cooldown :
                Int8(0))
        for agent = 1:2
            @inbounds if decision[agent] == 0x05 || decision[agent] == 0x06
                @inbounds next_state = evaluate_switch(next_state, agent,
                    active[agent], decision[agent] - 0x04,
                    iszero(get_hp(state.teams[agent].mons[active[agent]])) ?
                    0x18 : 0x00)
            end
        end
        if decision[1] == 0x04
            if decision[2] == 0x04
                atk_cmp = Base.cmp(
                    static_state.teams[1].mons[active[1]].stats.attack,
                    static_state.teams[2].mons[active[2]].stats.attack
                )
                if atk_cmp == 1
                    next_state = DynamicState(next_state.teams,
                        next_state.data + 0x0930)
                elseif atk_cmp == -1
                    next_state = DynamicState(next_state.teams,
                        next_state.data + 0x0c40)
                else
                    next_state = DynamicState(next_state.teams,
                        next_state.data + 0x4c90)
                end
            else
                next_state = DynamicState(next_state.teams,
                    next_state.data + 0x0310)
            end
        elseif decision[2] == 0x04
            next_state = DynamicState(next_state.teams,
                next_state.data + 0x0620)
        end
    end

    return next_state
end

function resolve_chance(state::DynamicState, static_state::StaticState)
    chance = get_chance(state::DynamicState)
    if chance == 0x0005
        return rand() < 0.5 ?
            # subtract chance, add cmp
            DynamicState(state.teams, state.data - 0x4360) :
            DynamicState(state.teams, state.data - 0x4050)
    else
        agent = chance >> 0x0002
        move = static_state.teams[agent].mons[active[agent]].chargedMoves[
            chance & 0x0003]
        if rand(Int8(0):Int8(99)) < move.buffChance
            a_data = static_state.teams[agent].data
            d_data = static_state.teams[get_other_agent(agent)].data
            a_data, d_data = apply_buff(a_data, d_data, move)
            return DynamicState(@SVector[
                DynamicTeam(state.teams[1].mons, state.teams[1].switchCooldown,
                    agent == 0x0001 ? a_data : d_data),
                DynamicTeam(state.teams[2].mons, state.teams[2].switchCooldown,
                    agent == 0x0002 ? a_data : d_data)
            ], state.data - chance * 0x0f50)
        else
            return DynamicState(state.teams, state.data - chance * 0x0f50)
        end
    end
end

function play_battle(state::DynamicState, static_state::StaticState;
    allow_nothing::Bool = false, allow_overfarming::Bool = false)
    while true
        d1, d2 = get_possible_decisions(state, static_state,
            allow_nothing = allow_nothing, allow_overfarming = allow_overfarming)
        (iszero(d1) || iszero(d2)) && return get_battle_score(state, static_state)
        dec = select_random_decision(d1, d2)
        println(dec)
        state = play_turn(state, static_state, dec)
    end
end

function get_battle_scores(starting_state::DynamicState, static_state::StaticState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

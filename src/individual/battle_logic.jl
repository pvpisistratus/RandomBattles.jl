using StaticArrays

function get_possible_decisions(state::DynamicIndividualState, static_state::StaticIndividualState, agent::Int64; allow_nothing::Bool = false, allow_overfarming::Bool = false)
    @inbounds activeTeam = state.teams[agent]
    @inbounds activeMon = state.teams[agent].mon
    activeMon.hp == Int16(0) && return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    if !(state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1))
        if activeTeam.shields == Int8(0)
            return  @SVector [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        else
            return @SVector [1/2, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        end
    else
        @inbounds activeStaticMon = static_state.teams[agent].mon
        if allow_nothing
            if activeTeam.shields == Int8(0)
                @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[1].energy
                    @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                        if activeMon.energy >= Int8(100) && !allow_overfarming
                            return @SVector [1/3, 0.0, 0.0, 0.0, 1/3, 0.0, 1/3, 0.0]
                        else
                            return @SVector [1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0]
                        end
                    else
                        return @SVector [1/3, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0]
                    end
                elseif @inbounds activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                    return @SVector [1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 1/3, 0.0]
                else
                    return @SVector [1/2, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0]
                end
            else
                @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[1].energy
                    @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                        if activeMon.energy >= Int8(100) && !allow_overfarming
                            return @SVector [1/6, 1/6, 0.0, 0.0, 1/6, 1/6, 1/6, 1/6]
                        else
                            return @SVector [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8]
                        end
                    else
                        return @SVector [1/6, 1/6, 1/6, 1/6, 1/6, 1/6, 0.0, 0.0]
                    end
                elseif @inbounds activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                    return @SVector [1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 1/6, 1/6]
                else
                    return @SVector [1/4, 1/4, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0]
                end
            end
        else
            if activeTeam.shields == Int8(0)
                @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[1].energy
                    @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                        if activeMon.energy >= Int8(100) && !allow_overfarming
                            return @SVector [0.0, 0.0, 0.0, 0.0, 1/2, 0.0, 1/2, 0.0]
                        else
                            return @SVector [0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 1/3, 0.0]
                        end
                    else
                        return @SVector [0.0, 0.0, 1/2, 0.0, 1/2, 0.0, 0.0, 0.0]
                    end
                elseif @inbounds activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                    return @SVector [0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 1/2, 0.0]
                else
                    return @SVector [0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                end
            else
                @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[1].energy
                    @inbounds if activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                        if activeMon.energy >= Int8(100) && !allow_overfarming
                            return @SVector [0.0, 0.0, 0.0, 0.0, 1/4, 1/4, 1/4, 1/4]
                        else
                            return @SVector [0.0, 0.0, 1/6, 1/6, 1/6, 1/6, 1/6, 1/6]
                        end
                    else
                        return @SVector [0.0, 0.0, 1/4, 1/4, 1/4, 1/4, 0.0, 0.0]
                    end
                elseif @inbounds activeMon.energy >= activeStaticMon.chargedMoves[2].energy
                    return @SVector [0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 1/4, 1/4]
                else
                    return @SVector [0.0, 0.0, 1/2, 1/2, 0.0, 0.0, 0.0, 0.0]
                end
            end
        end
    end
end

function play_turn(state::DynamicIndividualState, static_state::StaticIndividualState, decision::Tuple{Int64,Int64})
    next_state = state

    @inbounds if next_state.fastMovesPending[1] == Int8(0) || next_state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, next_state.fastMovesPending[1] == Int8(0), next_state.fastMovesPending[2] == Int8(0))
    end

    @inbounds next_state = step_timers(next_state,
        3 <= decision[1] <= 4 ? static_state.teams[1].mon.fastMove.cooldown : Int8(0),
        3 <= decision[2] <= 4 ? static_state.teams[2].mon.fastMove.cooldown : Int8(0))

    cmp = get_cmp(static_state, 5 <= decision[1], 5 <= decision[2])
    @inbounds if cmp[1] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[1],
            5 <= decision[cmp[1]] <= 6 ? Int8(1) : Int8(2), Int8(100), iseven(decision[get_other_agent(cmp[1])]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[1]].mon.chargedMoves[5 <= decision[cmp[1]] <= 6 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[get_other_agent(cmp[1])] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[1] == Int8(1), cmp[1] == Int8(2))
        end
    end
    @inbounds if cmp[2] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[2],
            5 <= decision[cmp[2]] <= 6 ? Int8(1) : Int8(2), Int8(100), iseven(decision[cmp[1]]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[2]].mon.chargedMoves[5 <= decision[cmp[2]] <= 6 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[cmp[1]] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[1] == Int8(1), cmp[1] == Int8(2))
        end
    end

    return next_state
end

function play_battle(starting_state::DynamicIndividualState, static_state::StaticIndividualState)
    state = starting_state
    while true
        weights1, weights2 = get_possible_decisions(state, static_state, 1), get_possible_decisions(state, static_state, 2)
        (iszero(weights1) || iszero(weights2)) && return get_battle_score(state, static_state)
        d1, d2 = rand(), rand()
        j = 0.0
        decision1, decision2 = 8, 8
        for i = 1:7
            @inbounds j += weights1[i]
            if d1 < j
                decision1 = i
                break
            end
        end
        j = 0.0
        for i = 1:7
            @inbounds j += weights2[i]
            if d2 < j
                decision2 = i
                break
            end
        end
        state = play_turn(state, static_state, (decision1, decision2))
    end
end

function get_battle_scores(starting_state::DynamicIndividualState, static_state::StaticIndividualState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

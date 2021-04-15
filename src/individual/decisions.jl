using StaticArrays

function get_possible_decisions(state::DynamicIndividualState, static_state::StaticIndividualState, agent::Int64; allow_nothing::Bool = false, allow_overfarming::Bool = false)
    @inbounds activeTeam = state.teams[agent]
    @inbounds activeMon = state.teams[agent]
    activeMon.hp == Int16(0) && return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    if !(state.fastMovesPending[agent] == Int8(0) || state.fastMovesPending[agent] == Int8(-1))
        if activeTeam.shields == Int8(0)
            return  @SVector [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        else
            return @SVector [1/2, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        end
    else
        @inbounds activeStaticMon = static_state.teams[agent]
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

function get_simultaneous_decisions(state::DynamicIndividualState, static_state::StaticIndividualState;
        allow_waiting::Bool = false, allow_overfarming::Bool = false)
    decisions1 = findall(x -> x > 0, RandomBattles.get_possible_decisions(state, static_state, 1,
        allow_nothing = allow_waiting, allow_overfarming = allow_overfarming))
    length(decisions1) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    decisions2 = findall(x -> x > 0, RandomBattles.get_possible_decisions(state, static_state, 2,
        allow_nothing = allow_waiting))
    length(decisions2) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    !(5 in decisions1 || 7 in decisions1) && filter!(isodd, decisions2)
    !(5 in decisions2 || 7 in decisions2) && filter!(isodd, decisions1)
    return decisions1, decisions2
end

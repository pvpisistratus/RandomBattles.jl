using StaticArrays

function get_possible_decisions(state::DynamicState, static_state::StaticState, agent::Int64; allow_nothing::Bool = false)
    @inbounds activeTeam = state.teams[agent]
    @inbounds if activeTeam.mons[activeTeam.active].hp == Int16(0)
        if activeTeam.shields == Int8(0)
            @inbounds if activeTeam.mons[1].hp != Int16(0)
                @inbounds if activeTeam.mons[2].hp != Int16(0)
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 1/3, 0.0]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/2, 0.0, 1/2, 0.0, 0.0, 0.0]
                    end
                else
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 1/2, 0.0]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    end
                end
            else
                @inbounds if activeTeam.mons[2].hp != Int16(0)
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1/2, 0.0]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
                    end
                else
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    end
                end
            end
        else
            @inbounds if activeTeam.mons[1].hp != Int16(0)
                @inbounds if activeTeam.mons[2].hp != Int16(0)
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/6, 1/6, 1/6, 1/6, 1/6, 1/6]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/4, 1/4, 1/4, 1/4, 0.0, 0.0]
                    end
                else
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 1/4, 1/4]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/2, 1/2, 0.0, 0.0, 0.0, 0.0]
                    end
                end
            else
                @inbounds if activeTeam.mons[2].hp != Int16(0)
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/4, 1/4, 1/4, 1/4]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/2, 1/2, 0.0, 0.0]
                    end
                else
                    @inbounds if activeTeam.mons[3].hp != Int16(0)
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/2, 1/2]
                    else
                        return @SVector [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    end
                end
            end
        end
    elseif @inbounds state.fastMovesPending[agent] != Int8(0) && state.fastMovesPending[agent] != Int8(-1)
        return @SVector [1/2, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    elseif activeTeam.shields != Int8(0)
        @inbounds activeStaticMon = static_state.teams[agent].mons[activeTeam.active]
        if activeTeam.switchCooldown == Int8(0)
            if allow_nothing
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/20, 1/20, 1/20, 1/20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/20, 1/20, 0.0, 0.0, 1/20, 1/20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/18, 1/18, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 1/10, 0.0, 0.0, 1/20, 1/20, 1/20, 1/20, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 0.0, 0.0, 0.0, 0.0, 1/18, 1/18, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 0.0, 0.0, 0.0, 0.0, 1/18, 1/18, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    else
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 1/16, 1/16, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 1/16, 1/16, 0.0, 0.0, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 1/16, 1/16, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/6, 1/6, 1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 1/8, 1/8, 1/16, 1/16, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 1/8, 1/8, 1/16, 1/16, 0.0, 0.0, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 1/7, 1/7, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 1/8, 1/8, 0.0, 0.0, 1/16, 1/16, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 1/7, 1/7, 0.0, 0.0, 0.0, 0.0, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 1/7, 1/7, 0.0, 0.0, 0.0, 0.0, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                else
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 1/12, 1/12, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 1/12, 1/12, 0.0, 0.0, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [1/5, 1/5, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/12, 1/12, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/5, 1/5, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [1/5, 1/5, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [1/4, 1/4, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                end
            else
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/16, 1/16, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/16, 1/16, 0.0, 0.0, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 1/16, 1/16, 1/16, 1/16, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [0.0, 0.0, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 0.0, 0.0, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 0.0, 0.0, 0.0, 0.0, 1/14, 1/14, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/6, 1/6, 1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    else
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 1/12, 1/12, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 1/12, 1/12, 0.0, 0.0, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/5, 1/5, 1/5, 1/5, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [0.0, 0.0, 1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 1/12, 1/12, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [0.0, 0.0, 1/5, 1/5, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/5, 1/5, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/4, 1/4, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 1/6, 1/6, 1/12, 1/12, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 1/6, 1/6, 1/12, 1/12, 0.0, 0.0, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 1/5, 1/5, 0.0, 0.0, 1/5, 1/5, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 1/12, 1/12, 1/12, 1/12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/5, 1/5, 0.0, 0.0, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/5, 1/5, 0.0, 0.0, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 1/10, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                else
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 1/8, 1/8, 0.0, 0.0, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 1/3, 1/3, 0.0, 0.0, 0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/8, 1/8, 1/8, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/3, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/3, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 1/2, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                end
            end
        else
            @inbounds activeStaticMon = static_state.teams[agent].mons[activeTeam.active]
            if allow_nothing
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        return @SVector [1/7, 1/7, 1/7, 1/7, 1/7, 0.0, 1/7, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    else
                        return @SVector [1/5, 1/5, 1/5, 1/5, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    return @SVector [1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                else
                    return @SVector [1/4, 1/4, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                end
            else
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        return @SVector [0.0, 0.0, 1/6, 1/6, 1/6, 1/6, 1/6, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    else
                        return @SVector [0.0, 0.0, 1/4, 1/4, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    return @SVector [0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 1/4, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                else
                    return @SVector [0.0, 0.0, 1/2, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                end
            end
        end
    else
        if activeTeam.switchCooldown == Int8(0)
            if allow_nothing
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [1/5, 0.0, 1/5, 0.0, 1/5, 0.0, 1/5, 0.0, 1/10, 0.0, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/5, 0.0, 1/5, 0.0, 1/5, 0.0, 1/5, 0.0, 1/10, 0.0, 0.0, 0.0, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [2/9, 0.0, 2/9, 0.0, 2/9, 0.0, 2/9, 0.0, 1/9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [1/5, 0.0, 1/5, 0.0, 1/5, 0.0, 1/5, 0.0, 0.0, 0.0, 1/10, 0.0, 1/10, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [2/9, 0.0, 2/9, 0.0, 2/9, 0.0, 2/9, 0.0, 0.0, 0.0, 0.0, 0.0, 1/9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [2/9, 0.0, 2/9, 0.0, 2/9, 0.0, 2/9, 0.0, 0.0, 0.0, 0.0, 0.0, 1/9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    else
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 1/8, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 1/8, 0.0, 0.0, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [2/7, 0.0, 2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 1/8, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [2/7, 0.0, 2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [2/7, 0.0, 2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [1/3, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 1/4, 0.0, 1/8, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 1/4, 0.0, 1/8, 0.0, 0.0, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 2/7, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 1/4, 0.0, 0.0, 0.0, 1/8, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 2/7, 0.0, 0.0, 0.0, 0.0, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 2/7, 0.0, 0.0, 0.0, 0.0, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                else
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 1/6, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 1/6, 0.0, 0.0, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [2/5, 0.0, 2/5, 0.0, 0.0, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/6, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [2/5, 0.0, 2/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [2/5, 0.0, 2/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [1/2, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                end
            else
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 1/8, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 1/8, 0.0, 0.0, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 2/7, 0.0, 2/7, 0.0, 2/7, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [0.0, 0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 1/8, 0.0, 1/8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [0.0, 0.0, 2/7, 0.0, 2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 0.0, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 2/7, 0.0, 2/7, 0.0, 2/7, 0.0, 0.0, 0.0, 0.0, 0.0, 1/7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    else
                        @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 1/6, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 1/6, 0.0, 0.0, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 2/5, 0.0, 2/5, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        else
                            @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                                @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                    return @SVector [0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 1/6, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                else
                                    return @SVector [0.0, 0.0, 2/5, 0.0, 2/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                                end
                            elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 2/5, 0.0, 2/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 1/2, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        end
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 1/3, 0.0, 1/6, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 1/3, 0.0, 1/6, 0.0, 0.0, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 2/5, 0.0, 0.0, 0.0, 2/5, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 1/6, 0.0, 1/6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 2/5, 0.0, 0.0, 0.0, 2/5, 0.0, 0.0, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 2/5, 0.0, 0.0, 0.0, 2/5, 0.0, 0.0, 0.0, 0.0, 0.0, 1/5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                else
                    @inbounds if activeTeam.active != Int8(1) && activeTeam.mons[1].hp != Int16(0)
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 1/4, 0.0, 0.0, 0.0, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 2/3, 0.0, 0.0, 0.0, 0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    else
                        @inbounds if activeTeam.active != Int8(2) && activeTeam.mons[2].hp != Int16(0)
                            @inbounds if activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                                return @SVector [0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            else
                                return @SVector [0.0, 0.0, 2/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                            end
                        elseif activeTeam.active != Int8(3) && activeTeam.mons[3].hp != Int16(0)
                            return @SVector [0.0, 0.0, 2/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        else
                            return @SVector [0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                        end
                    end
                end
            end
        else
            if allow_nothing
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        return @SVector [1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 1/4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    else
                        return @SVector [1/3, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    return @SVector [1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                else
                    return @SVector [1/2, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                end
            else
                @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[1].energy)
                    @inbounds if (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                        return @SVector [0.0, 0.0, 1/3, 0.0, 1/3, 0.0, 1/3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    else
                        return @SVector [0.0, 0.0, 1/2, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                    end
                elseif @inbounds (activeTeam.mons[activeTeam.active].energy >= activeStaticMon.chargedMoves[2].energy)
                    return @SVector [0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 1/2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                else
                    return @SVector [0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                end
            end
        end
    end
end

function play_turn(state::DynamicState, static_state::StaticState, decision::Tuple{Int64,Int64})
    next_state = state

    @inbounds if next_state.fastMovesPending[1] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, Int8(1))
    end
    @inbounds if next_state.fastMovesPending[2] == Int8(0)
        next_state = evaluate_fast_moves(next_state, static_state, Int8(2))
    end

    @inbounds next_state = step_timers(next_state,
        2 < decision[1] < 5 ? static_state.teams[1].mons[next_state.teams[1].active].fastMove.cooldown : Int8(0),
        2 < decision[2] < 5 ? static_state.teams[2].mons[next_state.teams[2].active].fastMove.cooldown : Int8(0))

    @inbounds if 8 < decision[1]
        next_state = evaluate_switch(next_state, Int8(1),
            decision[1] < 11 || 14 < decision[1] < 17 ? Int8(1) :
            decision[1] < 13 || 16 < decision[1] < 19 ? Int8(2) : Int8(3),
            decision[1] < 15 ? Int8(0) : Int8(24))
    end
    @inbounds if 8 < decision[2]
        next_state = evaluate_switch(next_state, Int8(2),
            decision[2] < 11 || 14 < decision[2] < 17 ? Int8(1) :
            decision[2] < 13 || 16 < decision[2] < 19 ? Int8(2) : Int8(3),
            decision[2] < 15 ? Int8(0) : Int8(24))
    end

    cmp = get_cmp(next_state, static_state, 4 < decision[1] < 9, 4 < decision[2] < 9)
    @inbounds if cmp[1] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[1],
            decision[cmp[1]] < 7 ? Int8(1) : Int8(2), Int8(100), iseven(decision[get_other_agent(cmp[1])]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[1]].mons[next_state.teams[cmp[1]].active].chargedMoves[decision[cmp[1]] < 7 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[get_other_agent(cmp[1])] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[1])
        end
    end
    @inbounds if cmp[2] != Int8(0)
        @inbounds next_state = evaluate_charged_moves(next_state, static_state, cmp[2],
            decision[cmp[2]] < 7 ? Int8(1) : Int8(2), Int8(100), iseven(decision[cmp[1]]),
            rand(Int8(0):Int8(99)) < static_state.teams[cmp[2]].mons[next_state.teams[cmp[2]].active].chargedMoves[decision[cmp[2]] < 7 ? Int8(1) : Int8(2)].buffChance)
        @inbounds if next_state.fastMovesPending[cmp[1]] != Int8(-1)
            @inbounds next_state = evaluate_fast_moves(next_state, static_state, cmp[2])
        end
    end

    return next_state
end

function play_battle(starting_state::DynamicState, static_state::StaticState)
    state = starting_state
    while true
        weights1, weights2 = get_possible_decisions(state, static_state, 1), get_possible_decisions(state, static_state, 2)
        d1, d2 = rand(), rand()
        j = 0.0
        decision1, decision2 = 20, 20
        for i = 1:19
            @inbounds j += weights1[i]
            if d1 < j
                decision1 = i
                break
            end
        end
        (decision1 == 20 && iszero(weights1)) && return get_battle_score(state, static_state)
        j = 0.0
        for i = 1:19
            @inbounds j += weights2[i]
            if d2 < j
                decision2 = i
                break
            end
        end
        (decision2 == 20 && iszero(weights2)) && return get_battle_score(state, static_state)
        state = play_turn(state, static_state, (decision1, decision2))
    end
end

function get_battle_scores(starting_state::DynamicState, static_state::StaticState, N::Int64)
    return map(x -> play_battle(starting_state, static_state), 1:N)
end

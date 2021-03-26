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
        @inbounds activeStaticMon = static_state.teams[agent].mons[activeTeam.active]
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

function get_simultaneous_decisions(state::DynamicState, static_state::StaticState;
  allow_waiting::Bool = false)
    decisions1 = findall(x -> x != 0.0, get_possible_decisions(state, static_state, 1,
        allow_nothing = allow_waiting))
    length(decisions1) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    decisions2 = findall(x -> x != 0.0, get_possible_decisions(state, static_state, 2,
        allow_nothing = allow_waiting))
    length(decisions2) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    !(5 in decisions1 || 7 in decisions1) && filter!(isodd, decisions2)
    !(5 in decisions2 || 7 in decisions2) && filter!(isodd, decisions1)
    return decisions1, decisions2
end

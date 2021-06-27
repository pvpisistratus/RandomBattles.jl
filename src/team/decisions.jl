function get_decision(d1::UInt8, d2::UInt8, i::UInt8, j::UInt8)
    to_return_1, to_return_2 = 0x08, 0x08
    for n = 0x00:0x06
        to_return_1 -= isodd(d1 >> n) && Base.ctpop_int(d1 >> n) == i ? 0x07 - n : 0x00
        to_return_2 -= isodd(d2 >> n) && Base.ctpop_int(d2 >> n) == j ? 0x07 - n : 0x00
    end
    return to_return_1, to_return_2
end

function select_random_decision(d1::UInt8, d2::UInt8)
    return get_decision(d1, d2,
        rand(0x01:Base.ctpop_int(d1)), rand(0x01:Base.ctpop_int(d2)))
end

function get_possible_decisions(state::DynamicState, static_state::StaticState;
    allow_nothing::Bool = false, allow_overfarming::Bool = false)
    # 00000001 - shield
    # 00000010 - nothing
    # 00000100 - fast move
    # 00001000 - charged move
    # 00010000 - switch 1
    # 00100000 - switch 2
    # 01000000 - charged move 1
    # 10000000 - charged move 2

    d = 0x00, 0x00

    active = get_active(state)
    fast_moves_pending = get_fast_moves_pending(state)

    cmp = get_cmp(state)
    if isodd(cmp) # if team 1 is using a charged move and has cmp
        @inbounds d = (get_energy(state.teams[1].mons[active[1]]) >=
            static_state.teams[1].mons[active[1]].chargedMoves[2].energy ?
            0xc0 : 0x40, has_shield(state.teams[2]) ? 0x03 : 0x02)
    elseif !iszero(cmp) # if team 2 is using a charged move and has cmp
        @inbounds d = (has_shield(state.teams[1]) ? 0x03 : 0x02,
            get_energy(state.teams[2].mons[active[2]]) >=
            static_state.teams[2].mons[active[2]].chargedMoves[2].energy ?
            0xc0 : 0x40)
    else
        for i = 1:2
            if get_hp(state.teams[i].mons[active[i]]) == 0x0000
                @inbounds if get_hp(state.teams[i].mons[(active[i] == 0x0001 ?
                    2 : 1)]) != 0x0000
                    @inbounds d = i == 1 ? (d[1] + 0x10, d[2]) :
                        (d[1], d[2] + 0x10)
                end
                @inbounds if get_hp(state.teams[i].mons[(active[i] == 0x0003 ?
                    2 : 3)]) != 0x0000
                    @inbounds d = i == 1 ? (d[1] + 0x20, d[2]) :
                        (d[1], d[2] + 0x20)
                end
            else
                if fast_moves_pending[i] <= 0x0001
                    @inbounds if allow_overfarming ||
                        get_energy(state.teams[i].mons[active[i]]) != 0x0064
                        @inbounds d = i == 1 ? (d[1] + 0x04, d[2]) :
                            (d[1], d[2] + 0x04)
                    end
                    @inbounds if get_energy(state.teams[i].mons[active[i]]) >=
                        static_state.teams[i].mons[active[i]].chargedMoves[1].energy
                        @inbounds d = i == 1 ? (d[1] + 0x08, d[2]) :
                            (d[1], d[2] + 0x08)
                    end
                    @inbounds if get_hp(state.teams[i].mons[active[i] == 0x0001 ?
                        2 : 1]) != 0x0000 && state.teams[i].switchCooldown == Int8(0)
                        @inbounds d = i == 1 ? (d[1] + 0x10, d[2]) :
                            (d[1], d[2] + 0x10)
                    end
                    @inbounds if get_hp(state.teams[i].mons[active[i] == 0x0003 ?
                        2 : 3]) != 0x0000 && state.teams[i].switchCooldown == Int8(0)
                        @inbounds d = i == 1 ? (d[1] + 0x20, d[2]) :
                            (d[1], d[2] + 0x20)
                    end
                    if allow_nothing
                        @inbounds d = i == 1 ? (d[1] + 0x02, d[2]) :
                            (d[1], d[2] + 0x02)
                    end
                else
                    @inbounds d = i == 1 ? (d[1] + 0x02, d[2]) :
                        (d[1], d[2] + 0x02)
                end
            end
        end
    end

    return d
end

function get_decision(d1::UInt8, d2::UInt8, i::UInt8, j::UInt8)
    to_return_1, to_return_2 = 0x08, 0x08
    for n = 0x00:0x06
        to_return_1 -= isodd(d1 >> n) &&
            Base.ctpop_int(d1 >> n) == i ? 0x07 - n : 0x00
        to_return_2 -= isodd(d2 >> n) &&
            Base.ctpop_int(d2 >> n) == j ? 0x07 - n : 0x00
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

    active = get_active(state)
    fast_moves_pending = get_fast_moves_pending(state)
    cmp = get_cmp(state)

    if isodd(cmp) # if team 1 is using a charged move and has cmp
        return (get_energy(state[0x01][active[1]]) >=
            static_state[0x01][active[1]].charged_move_2.energy ?
            0xc0 : 0x40, has_shield(state[0x02]) ? 0x03 : 0x02)
    elseif !iszero(cmp) # if team 2 is using a charged move and has cmp
        return (has_shield(state[0x01]) ? 0x03 : 0x02,
            get_energy(state[0x02][active[2]]) >=
            static_state[0x02][active[2]].charged_move_2.energy ?
            0xc0 : 0x40)
    else
        d = 0x00, 0x00
        for i = 0x01:0x02
            if get_hp(state[i][active[i]]) == 0x0000
                if get_hp(state[i][(active[i] == 0x0001 ?
                    0x0002 : 0x0001)]) != 0x0000
                    d = i == 0x0001 ? (d[1] + 0x10, d[2]) : (d[1], d[2] + 0x10)
                end
                if get_hp(state[i][(active[i] == 0x0003 ?
                    0x0002 : 0x0003)]) != 0x0000
                    d = i == 0x0001 ? (d[1] + 0x20, d[2]) : (d[1], d[2] + 0x20)
                end
            else
                if fast_moves_pending[i] <= 0x0001
                    if allow_overfarming ||
                        get_energy(state[i][active[i]]) != 0x0064
                        d = i == 0x0001 ? (d[1] + 0x04, d[2]) :
                            (d[1], d[2] + 0x04)
                    end
                    if get_energy(state[i][active[i]]) >=
                        static_state[i][active[i]].charged_move_1.energy
                        d = i == 0x0001 ? (d[1] + 0x08, d[2]) :
                            (d[1], d[2] + 0x08)
                    end
                    if get_hp(state[i][active[i] == 0x0001 ?
                        0x0002 : 0x0001]) != 0x0000 && state[
                        i].switchCooldown == Int8(0)
                        d = i == 0x0001 ? (d[1] + 0x10, d[2]) :
                            (d[1], d[2] + 0x10)
                    end
                    if get_hp(state[i][active[i] == 0x0003 ?
                        0x0002 : 0x0003]) != 0x0000 && state[
                        i].switchCooldown == Int8(0)
                        d = i == 1 ? (d[1] + 0x20, d[2]) :
                            (d[1], d[2] + 0x20)
                    end
                    if allow_nothing
                        d = i == 0x0001 ? (d[1] + 0x02, d[2]) :
                            (d[1], d[2] + 0x02)
                    end
                else
                    d = i == 0x0001 ? (d[1] + 0x02, d[2]) : (d[1], d[2] + 0x02)
                end
            end
        end
        return d
    end
end

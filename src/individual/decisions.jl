function get_possible_decisions(state::DynamicIndividualState,
    static_state::StaticIndividualState;
    allow_nothing::Bool = false, allow_overfarming::Bool = false)
    # 00000001 - shield
    # 00000010 - nothing
    # 00000100 - fast move
    # 00001000 - charged move
    # 00010000 - charged move 1
    # 00100000 - charged move 2

    fast_moves_pending = get_fast_moves_pending(state)

    if get_hp(state[0x01]) == 0x0000 || get_hp(state[0x02]) == 0x0000
        return 0x00, 0x00
    end

    cmp = get_cmp(state)
    if isodd(cmp) # if team 1 is using a charged move and has cmp
         return (get_energy(state[0x01]) >=
            static_state[0x01].charged_move_2.energy ?
            0x30 : 0x10, has_shield(state, 2) ? 0x03 : 0x02)
    elseif !iszero(cmp) # if team 2 is using a charged move and has cmp
         return (has_shield(state, 1) ? 0x03 : 0x02,
            get_energy(state[0x02]) >=
            static_state[0x02].charged_move_2.energy ?
            0x30 : 0x10)
    end

    d = 0x00, 0x00
    for i = 0x01:0x02
        if fast_moves_pending[i] <= 0x0001
             if allow_overfarming ||
            get_energy(state[i]) != 0x0064
                 d = i == 0x01 ? (d[1] + 0x04, d[2]) : (d[1], d[2] + 0x04)
            end
             if get_energy(state[i]) >=
                static_state[i].charged_move_1.energy
                 d = i == 0x01 ? (d[1] + 0x08, d[2]) : (d[1], d[2] + 0x08)
            end
            if allow_nothing
                 d = i == 0x01 ? (d[1] + 0x02, d[2]) : (d[1], d[2] + 0x02)
            end
        else
             d = i == 0x01 ? (d[1] + 0x02, d[2]) : (d[1], d[2] + 0x02)
        end
    end

    return d
end

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

    if get_hp(state.teams[1]) == 0x0000 || get_hp(state.teams[2]) == 0x0000
        return 0x00, 0x00
    end

    cmp = get_cmp(state)
    if isodd(cmp) # if team 1 is using a charged move and has cmp
        @inbounds return (get_energy(state.teams[1]) >=
            static_state.teams[1].chargedMoves[2].energy ?
            0x30 : 0x10, has_shield(state, 2) ? 0x03 : 0x02)
    elseif !iszero(cmp) # if team 2 is using a charged move and has cmp
        @inbounds return (has_shield(state, 1) ? 0x03 : 0x02,
            get_energy(state.teams[2]) >=
            static_state.teams[2].chargedMoves[2].energy ?
            0x30 : 0x10)
    end

    d = 0x00, 0x00
    for i = 1:2
        if fast_moves_pending[i] <= 0x0001
            @inbounds if allow_overfarming ||
            get_energy(state.teams[i]) != 0x0064
                @inbounds d = i == 1 ? (d[1] + 0x04, d[2]) : (d[1], d[2] + 0x04)
            end
            @inbounds if get_energy(state.teams[i]) >=
                static_state.teams[i].chargedMoves[1].energy
                @inbounds d = i == 1 ? (d[1] + 0x08, d[2]) : (d[1], d[2] + 0x08)
            end
            if allow_nothing
                @inbounds d = i == 1 ? (d[1] + 0x02, d[2]) : (d[1], d[2] + 0x02)
            end
        else
            @inbounds d = i == 1 ? (d[1] + 0x02, d[2]) : (d[1], d[2] + 0x02)
        end
    end

    return d
end

function diff(p1::DynamicPokemon, p2::DynamicPokemon)
    if get_hp(p1) != get_hp(p2)
        println("       hp changed from $(get_hp(p1)) to $(get_hp(p2))")
    end
    if get_energy(p1) != get_energy(p2)
        println("       energy changed from $(get_energy(p1)) to " *
            "$(get_energy(p2))")
    end
end

function diff(t1::DynamicTeam, t2::DynamicTeam)
    println("   Mon 1: ")
    diff(t1[0x01], t2[0x01])
    println("   Mon 2: ")
    diff(t1[0x02], t2[0x02])
    println("   Mon 3: ")
    diff(t1[0x03], t2[0x03])
    if t1.data % 0x03 != t2.data % 0x03
        println("   shields changed from $(t1.data % 0x03) to " *
            "$(t2.data % 0x03)")
    end
    if (t1.data ÷ 0x1b, (t1.data ÷ 0x03) % 0x09) !=
        (t2.data ÷ 0x1b, (t2.data ÷ 0x03) % 0x09)
        println("   buffs changed from " *
            "$((t1.data ÷ 0x1b, (t1.data ÷ 0x03) % 0x09))" *
            "to $((t2.data ÷ 0x1b, (t2.data ÷ 0x03) % 0x09))")
    end
end

function diff(s1::DynamicState, s2::DynamicState)
    println("Team 1: ")
    diff(s1[0x01], s2[0x01])
    println("Team 2: ")
    diff(s1[0x02], s2[0x02])
    if get_active(s1) != get_active(s2)
        println("active changed from $(get_active(s1)) to $(get_active(s2))")
    end
    if get_fast_moves_pending(s1) != get_fast_moves_pending(s2)
        println("pending fast moves changed from " *
        "$(get_fast_moves_pending(s1)) to $(get_fast_moves_pending(s2))")
    end
    if get_cmp(s1) != get_cmp(s2)
        println("cmp changed from $(get_cmp(s1)) to $(get_cmp(s2))")
    end
    if get_chance(s1) != get_chance(s2)
        println("chance changed from $(get_chance(s1)) to $(get_chance(s2))")
    end
    if get_fm_damage(s1) != get_fm_damage(s2)
        println("fast move damage changed from $(get_fm_damage(s1)) to " *
        "$(get_fm_damage(s2))")
    end
end

function reflect(s::DynamicState)
    active = get_active(s)
    new_active = active[2], active[1]
    fm_pending = get_fast_moves_pending(s)
    new_fm_pending = new_fm_pending[2], new_fm_pending[1]
    cmp = get_cmp(s)
    new_cmp = isodd(cmp) ? cmp + 0x01 : iszero(cmp) ? 0x00 : cmp - 0x01
    chance = get_chance(s)
    new_chance = chance
    if chance == 0x01 || chance == 0x02
        new_chance += 0x02
    elseif chance == 0x03 || chance == 0x04
        new_chance -= 0x02
    end
    fm_damage = get_fm_damage(s)
    new_fm_damage = fm_damage[2], fm_damage[1]

    new_data = new_active[1] + UInt32(4) * new_active[2] +
        UInt32(16) * new_fm_pending[1] + UInt32(112) * new_fm_pending[2] +
        UInt32(784) * new_cmp + UInt32(3920) * new_chance +
        UInt32(23520) * new_fm_damage[1] + UInt32(9996000) * new_fm_damage[2]

    return DynamicState(s[0x02], s[0x01], new_data)
end

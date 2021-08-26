# Types and effectiveness adapted from Silph Arena graphic
# https://storage.googleapis.com/silphroad-publishing/silph-wp/3d94d185-type-chart_v4.png
function get_eff(a::UInt8, d1::UInt8, d2::UInt8)
    𛲜 = 1       # weakness
    Θ = -1      # resistance
    ✗ = -2      # "immunity"

    eff = 0
    if a == 1
        eff = (d1 == 6 || d1 == 9 ? Θ : d1 == 8 ? ✗ : 0) +
            (d2 == 6 || d2 == 9 ? Θ : d2 == 8 ? ✗ : 0)
    elseif a == 2
        eff = (d1 == 1 || d1 == 6 || d1 == 9 || d1 == 15 || d1 == 17 ? 𛲜 :
            d1 == 3 || d1 == 4 || d1 == 7 || d1 == 14 || d1 == 18 ? Θ :
            d1 == 8 ? ✗ : 0) +
            (d2 == 1 || d2 == 6 || d2 == 9 || d2 == 15 || d2 == 17 ? 𛲜 :
            d2 == 3 || d2 == 4 || d2 == 7 || d2 == 14 || d2 == 18 ? Θ :
            d2 == 8 ? ✗ : 0)
    elseif a == 3
        eff = (d1 == 2 || d1 == 7 || d1 == 12 ? 𛲜 :
            d1 == 6 || d1 == 9 || d1 == 13 ? Θ : 0) +
            (d2 == 2 || d2 == 7 || d2 == 12 ? 𛲜 :
            d2 == 6 || d2 == 9 || d2 == 13 ? Θ : 0)
    elseif a == 4
        eff = (3 < d1 < 7 || d1 == 8 ? Θ : d1 == 12 || d1 == 18 ? 𛲜 :
            d1 == 9 ? ✗ : 0) + (3 < d2 < 7 || d2 == 8 ? Θ : d2 == 12 ||
            d2 == 18 ? 𛲜 : d2 == 9 ? ✗ : 0)
    elseif a == 5
        eff = (d1 == 4 || d1 == 6 || d1 == 9 || d1 == 10 || d1 == 13 ? 𛲜 :
            d1 == 7 || d1 == 12 ? Θ : d1 == 3 ? ✗ : 0) +
            (d2 == 4 || d2 == 6 || d2 == 9 || d2 == 10 || d2 == 13 ? 𛲜 :
            d2 == 7 || d2 == 12 ? Θ : d2 == 3 ? ✗ : 0)
    elseif a == 6
        eff = (d1 == 3 || d1 == 7 || d1 == 10 || d1 == 15 ? 𛲜 :
            d1 == 2 || d1 == 5 || d1 == 9 ? Θ : 0) +
            (d2 == 3 || d2 == 7 || d2 == 10 || d2 == 15 ? 𛲜 :
            d2 == 2 || d2 == 5 || d2 == 9 ? Θ : 0)
    elseif a == 7
        eff = (d1 == 12 || d1 == 14 || d1 == 17 ? 𛲜 :
            1 < d1 < 5 || 7 < d1 < 11 || d1 == 18 ? Θ : 0) +
            (d2 == 12 || d2 == 14 || d2 == 17 ? 𛲜 :
            1 < d2 < 5 || 7 < d2 < 11 || d2 == 18 ? Θ : 0)
    elseif a == 8
        eff = (d1 == 8 || d1 == 14 ? 𛲜 : d1 == 17 ? Θ : d1 == 1 ? ✗ : 0) +
            (d2 == 8 || d2 == 14 ? 𛲜 : d2 == 17 ? Θ : d2 == 1 ? ✗ : 0)
    elseif a == 9
        eff = (d1 == 6 || d1 == 15 || d1 == 18 ? 𛲜 : 8 < d1 < 12 ||
            d1 == 13 ? Θ : 0) + (d2 == 6 || d2 == 15 || d2 == 18 ? 𛲜 :
            8 < d2 < 12 || d2 == 13 ? Θ : 0)
    elseif a == 10
        eff = (d1 == 7 || d1 == 9 || d1 == 12 || d1 == 15 ? 𛲜 :
            d1 == 6 || d1 == 10 || d1 == 11 || d1 == 16 ? Θ : 0) +
            (d2 == 7 || d2 == 9 || d2 == 12 || d2 == 15 ? 𛲜 :
            d2 == 6 || d2 == 10 || d2 == 11 || d2 == 16 ? Θ : 0)
    elseif a == 11
        eff = (4 < d1 < 7 || d1 == 10 ? 𛲜 : 10 < d1 < 13 || d1 == 16 ? Θ : 0) +
            (4 < d2 < 7 || d2 == 10 ? 𛲜 : 10 < d2 < 13 || d2 == 16 ? Θ : 0)
    elseif a == 12
        eff = (d1 == 5 || d1 == 6 || d1 == 11 ? 𛲜 :
            2 < d1 < 5 || d1 == 7 || 8 < d1 < 11 || d1 == 12 || d1 == 16 ? Θ :
            0) + (d2 == 5 || d2 == 6 || d2 == 11 ? 𛲜 :
            2 < d2 < 5 || d2 == 7 || 8 < d2 < 11 || d2 == 12 || d2 == 16 ? Θ :
            0)
    elseif a == 13
        eff = (d1 == 3 || d1 == 11 ? 𛲜 : d1 == 12 || d1 == 13 || d1 == 16 ? Θ :
            d1 == 5 ? ✗ : 0) +
            (d2 == 3 || d2 == 11 ? 𛲜 : d2 == 12 || d2 == 13 || d2 == 16 ? Θ :
                d2 == 5 ? ✗ : 0)
    elseif a == 14
        eff = (d1 == 2 || d1 == 4 ? 𛲜 : d1 == 9 || d1 == 14 ? Θ :
            d1 == 17 ? ✗ : 0) +
            (d2 == 2 || d2 == 4 ? 𛲜 : d2 == 9 || d2 == 14 ? Θ :
            d2 == 17 ? ✗ : 0)
    elseif a == 15
        eff = (d1 == 3 || d1 == 5 || d1 == 12 || d1 == 16 ? 𛲜 :
            8 < d1 < 12 || d1 == 15 ? Θ : 0) +
            (d2 == 3 || d2 == 5 || d2 == 12 || d2 == 16 ? 𛲜 :
            8 < d2 < 12 || d2 == 15 ? Θ : 0)
    elseif a == 16
        eff = (d1 == 16 ? 𛲜 : d1 == 9 ? Θ : d1 == 18 ? ✗ : 0) +
            (d2 == 16 ? 𛲜 : d2 == 9 ? Θ : d2 == 18 ? ✗ : 0)
    elseif a == 17
        eff = (d1 == 8 || d1 == 14 ? 𛲜 : d1 == 2 || 16 < d1 < 19 ? Θ : 0) +
            (d2 == 8 || d2 == 14 ? 𛲜 : d2 == 2 || 16 < d2 < 19 ? Θ : 0)
    else
        eff = (d1 == 2 || 15 < d1 < 18 ? 𛲜 : d1 == 4 || d1 == 9 ||
            d1 == 10 ? Θ : 0) +
            (d2 == 2 || 15 < d2 < 18 ? 𛲜 : d2 == 4 || d2 == 9 ||
            d2 == 10 ? Θ : 0)
    end
    if eff == 0
        return 40000
    elseif eff == 1
        return 25000
    elseif eff == -1
        return 64000
    elseif eff == 2
        return 15625
    elseif eff == -2
        return 102400
    else
        return 163840
    end
end

"""
    calculate_damage(
        attacker::StaticPokemon,
        atkBuff::Int8,
        defender::StaticPokemon,
        defBuff::Int8,
        move::Move;
        charge::Int8,
    )

Calculate the damage a particular pokemon does against another using a charged move

"""
function calculate_damage(
    attack::UInt16,
    defense::UInt16,
    mon_typings::Tuple{UInt8, UInt8},
    buff_atk::UInt8,
    buff_def::UInt8,
    move::Move;
    charge::UInt8 = 0x64,
)
    buff_num, buff_denom = get_buff_modifier(buff_atk, buff_def)
    return UInt16((26 * attack * get_power(move) * get_STAB(move) * buff_num * 
        charge) ÷ (get_eff(move.move_type, mon_typings[1], mon_typings[2]) * 
        defense * buff_denom) + 1)
end
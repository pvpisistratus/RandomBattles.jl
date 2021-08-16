abstract type Move end

"""
    FastMove(moveType, stab, power, energy, cooldown)

Struct for holding fast moves that holds all information that determines
mechanics: type, STAB (same type attack bonus), power, energy, and cooldown.
Note that this is agnostic to the identity of the actual move itself.
"""
struct FastMove <: Move
    move_type::UInt8
    data::UInt16
end

"""
    FastMove(gm_move, types)

Generate a fast move from the gamemaster entry of the move, and the types of
the mon using it (to determing STAB, same type attack bonus). This should only
be used internally, as generating the move from the name is a lot cleaner.
"""
function FastMove(gm_move::Dict{String,Any}, types::Tuple{UInt8, UInt8})
    move_type = UInt8(findfirst(x -> typings[x] == gm_move["type"], 1:19))
    STAB = move_type in types ? 0x0001 : 0x0000
    power = UInt16(gm_move["power"])
    energy = UInt16(gm_move["energyGain"])
    cooldown = UInt16(gm_move["cooldown"] ÷ 500)
    return FastMove(
        move_type,
        cooldown + energy << 3 + power << 8 + STAB << 13
    )
end

"""
    FastMove(move_name, types)

Generate a fast move from the name of the move, and the types of the mon using
it (to determing STAB, same type attack bonus)
"""
function FastMove(move_name::String, types::Tuple{UInt8, UInt8})
    move_index = findfirst(isequal(move_name), map(x ->
        gamemaster["moves"][x]["moveId"], 1:length(gamemaster["moves"])))
    gm_move = gamemaster["moves"][move_index]
    return FastMove(gm_move, types)
end

get_STAB(fm::FastMove) = iszero(fm.data >> 13) ? 10 : 12
get_power(fm::FastMove) = (fm.data >> 8) & 0x001f
get_energy(fm::FastMove) = (fm.data >> 3) & 0x001f
get_cooldown(fm::FastMove) = fm.data & 0x0007

"""
    ChargedMove(moveType, stab, power, energy, buffChance, opp_buffs, self_buffs)

Struct for holding charged moves that holds all information that determines
mechanics: type, STAB (same type attack bonus), power, energy, and buff
information (chance, which buffs are applied and to whom). Note that this is
agnostic to the identity of the actual move itself.
"""
struct ChargedMove <: Move
    move_type::UInt8
    buff::StatBuffs
    data::UInt16
end

"""
    ChargedMove(gm_move, types)

Generate a charged move from the gamemaster entry of the move, and the types of
the mon using it (to determing STAB, same type attack bonus). This should only
be used internally, as generating the move from the name is a lot cleaner.
"""
function ChargedMove(gm_move::Dict{String,Any}, types::Tuple{UInt8, UInt8})
    move_type = UInt8(findfirst(x -> typings[x] == gm_move["type"], 1:19))
    STAB = move_type in types ? 0x0001 : 0x0000
    buff_target = (haskey(gm_move, "buffs") && 
        gm_move["buffTarget"] == "opponent") ? 0x0001 : 0x0000
    power = UInt16(gm_move["power"] ÷ 5)
    energy = UInt16(gm_move["energy"] ÷ 5)
    buff = !haskey(gm_move, "buffs") ? defaultBuff :
        StatBuffs(Int8(gm_move["buffs"][1]), Int8(gm_move["buffs"][2]))
    buff_chance = !haskey(gm_move, "buffs")  ? 0x0000 :
        gm_move["buffApplyChance"] == ".1"   ? 0x0001 :
        gm_move["buffApplyChance"] == ".125" ? 0x0002 :
        gm_move["buffApplyChance"] == ".2"   ? 0x0003 :
        gm_move["buffApplyChance"] == ".3"   ? 0x0004 :
        gm_move["buffApplyChance"] == ".5"   ? 0x0005 : 0x0006

    return ChargedMove(
        move_type,
        buff,
        power + energy << 6 + buff_chance << 10 + buff_target << 11 + STAB << 12
    )
end

"""
    ChargedMove(move_name, types)

Generate a charged move from the name of the move, and the types of the mon
using it (to determing STAB, same type attack bonus)
"""
function ChargedMove(move_name::String, types)
    #if move_name == "NONE"
    #    return ChargedMove(Int8(0), Int8(0), UInt8(0), Int8(0), Int8(0),
    #        defaultBuff, defaultBuff)
    #end
    move_index = findfirst(isequal(move_name), map(x ->
        gamemaster["moves"][x]["moveId"], 1:length(gamemaster["moves"])))
    gm_move = gamemaster["moves"][move_index]
    return ChargedMove(gm_move, types)
end

get_power(cm::ChargedMove) = 0x0005 * (cm.data & 0x003f)
get_energy(cm::ChargedMove) = 0x0005 * ((cm.data >> 6) & 0x000f)
get_buff_target(cm::ChargedMove) = (cm.data >> 11) & 0x0001
get_STAB(cm::ChargedMove) = iszero(cm.data >> 12) ? 10 : 12

function get_buff_chance(cm::ChargedMove)
    buff_chance = (cm.data >> 10) & 0x03ff
    return buff_chance == 0x0000 ? 0.0   :
           buff_chance == 0x0006 ? 1.0   :
           buff_chance == 0x0001 ? 0.1   :
           buff_chance == 0x0002 ? 0.125 :
           buff_chance == 0x0003 ? 0.2   :
           buff_chance == 0x0004 ? 0.3   : 0.5
end 

function buff_applies(cm::ChargedMove)
    buff_chance = (cm.data >> 10) & 0x03ff
    return buff_chance == 0x0000 ? false                                                                 :
           buff_chance == 0x0006 ? true                                                                  :
           buff_chance == 0x0001 ? rand(rb_rng, 1:10) == 1                                               :
           buff_chance == 0x0002 ? rand(rb_rng, (true, false, false, false, false, false, false, false)) :
           buff_chance == 0x0003 ? rand(rb_rng, 1:5) == 1                                                :
           buff_chance == 0x0004 ? rand(rb_rng, 1:10) < 4                                                : rand(rb_rng, (true, false))
end

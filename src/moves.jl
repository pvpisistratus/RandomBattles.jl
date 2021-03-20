"""
    FastMove(moveType, stab, power, energy, cooldown)

Struct for holding fast moves that holds all information that determines
mechanics: type, STAB (same type attack bonus), power, energy, and cooldown.
Note that this is agnostic to the identity of the actual move itself.
"""
struct FastMove
    moveType::Int8
    stab::Int8
    power::UInt8
    energy::Int8
    cooldown::Int8
end

"""
    FastMove(gm_move, types)

Generate a fast move from the gamemaster entry of the move, and the types of
the mon using it (to determing STAB, same type attack bonus). This should only
be used internally, as generating the move from the name is a lot cleaner.
"""
function FastMove(gm_move::Dict{String,Any}, types)
    return FastMove(
            typings[gm_move["type"]],
            (typings[gm_move["type"]] in types) ? Int8(12) : Int8(1),
            UInt8(gm_move["power"]),
            Int8(gm_move["energyGain"]),
            Int8(gm_move["cooldown"] ÷ 500)
        )
end

"""
    FastMove(move_name, types)

Generate a fast move from the name of the move, and the types of the mon using
it (to determing STAB, same type attack bonus)
"""
function FastMove(move_name::String, types)
    move_index = findfirst(isequal(move_name), map(x ->
        gamemaster["moves"][x]["moveId"], 1:length(gamemaster["moves"])))
    gm_move = gamemaster["moves"][move_index]
    return FastMove(gm_move, types)
end

"""
    ChargedMove(moveType, stab, power, energy, buffChance, opp_buffs, self_buffs)

Struct for holding charged moves that holds all information that determines
mechanics: type, STAB (same type attack bonus), power, energy, and buff
information (chance, which buffs are applied and to whom). Note that this is
agnostic to the identity of the actual move itself.
"""
struct ChargedMove
    moveType::Int8
    stab::Int8
    power::UInt8
    energy::Int8
    buffChance::Int8
    opp_buffs::StatBuffs
    self_buffs::StatBuffs
end

"""
    ChargedMove(gm_move, types)

Generate a charged move from the gamemaster entry of the move, and the types of
the mon using it (to determing STAB, same type attack bonus). This should only
be used internally, as generating the move from the name is a lot cleaner.
"""
function ChargedMove(gm_move::Dict{String,Any}, types)
    return ChargedMove(
        typings[gm_move["type"]],
        (typings[gm_move["type"]] in types) ? Int8(12) : Int8(10),
        UInt8(gm_move["power"]),
        Int8(gm_move["energy"]),
        haskey(gm_move, "buffs") ? floor(Int8, parse(Float64, gm_move["buffApplyChance"]) * 100) : Int8(0),
        StatBuffs(haskey(gm_move, "buffs") && gm_move["buffTarget"] == "opponent" ? Int8(gm_move["buffs"][1]) : Int8(0), haskey(gm_move, "buffs") && gm_move["buffTarget"] == "opponent" ? Int8(gm_move["buffs"][2]) : Int8(0)),
        StatBuffs(haskey(gm_move, "buffs") && gm_move["buffTarget"] == "self" ? Int8(gm_move["buffs"][1]) : Int8(0), haskey(gm_move, "buffs") && gm_move["buffTarget"] == "self" ? Int8(gm_move["buffs"][2]) : Int8(0))
    )
end

"""
    ChargedMove(move_name, types)

Generate a charged move from the name of the move, and the types of the mon
using it (to determing STAB, same type attack bonus)
"""
function ChargedMove(move_name::String, types)
    if move_name == "NONE"
        return ChargedMove(Int8(0), Int8(0), UInt8(0), Int8(0), Int8(0), defaultBuff, defaultBuff)
    end
    move_index = findfirst(isequal(move_name), map(x ->
        gamemaster["moves"][x]["moveId"], 1:length(gamemaster["moves"])))
    gm_move = gamemaster["moves"][move_index]
    return ChargedMove(gm_move, types)
end

using StaticArrays

struct Individual
    #These values are initialized, but change throughout the battle
    mon::Pokemon
    buffs::StatBuffs         #Initially 0, 0
    shields::Int8            #Initially 2
    shielding::Bool          #Initially random
end

function vectorize(ind::Individual)
    return vcat(vectorize(ind.mon), [ind.buffs.atk, ind.buffs.def, ind.shields])
end

Individual(
    mon::Int64;
    league::String = "great",
    cup::String = "open",
    shields = Int8(2),
) = Individual(Pokemon(mon, league = league, cup = cup), defaultBuff, shields, rand(Bool))

Individual(mon::String; league::String = "great", cup::String = "open", shields = Int8(2)) =
    Individual(Pokemon(mon, league = league, cup = cup), defaultBuff, shields, rand(Bool))

Individual(mon::Pokemon, shields = Int8(2)) =
    Individual(mon, defaultBuff, shields, rand(Bool))

function Setfield.:setindex(arr::StaticArrays.SVector{2, Individual}, t::Individual, i::Int8)
    return setindex(arr, t, Int64(i))
end

using StaticArrays

struct Individual
    #These values are initialized, but change throughout the battle
    mons::SVector{1,Pokemon}
    buffs::StatBuffs         #Initially 0, 0
    switchCooldown::Int64    #Initially 0
    shields::Int8            #Initially 2
    active::Int64            #Initially 1 (the lead)
    shielding::Bool          #Initially random
end

Individual(
    mons::Array{Int64};
    league::String = "great",
    cup::String = "open",
) = Individual(Pokemon.(mons, league = league, cup = cup), StatBuffs(0, 0), 0, 2, 1, rand(Bool))

Individual(mons::Array{String}; league::String = "great", cup::String = "open") =
    Individual(Pokemon.(mons, league = league, cup = cup), StatBuffs(0, 0), 0, 2, 1, rand(Bool))

Individual(mons::Array{Pokemon}) =
    Individual(mons, StatBuffs(0, 0), 0, 2, 1, rand(Bool))

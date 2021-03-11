using StaticArrays

struct StaticIndividual
    mon::StaticPokemon
end

struct DynamicIndividual
    #These values are initialized, but change throughout the battle
    mon::DynamicPokemon
    buffs::StatBuffs         #Initially 0, 0
    shields::Int8            #Initially 2
end

StaticIndividual(mon::String; league::String = "great", cup::String = "open") =
    StaticIndividual(StaticPokemon(mon, league = league, cup = cup))

StaticIndividual(mon::Int64; league::String = "great", cup::String = "open") =
    StaticIndividual(StaticPokemon(mon, league = league, cup = cup))

DynamicIndividual(ind::StaticIndividual; shields::Int8 = Int8(2)) = DynamicIndividual(DynamicPokemon(ind.mon),
    defaultBuff, shields)

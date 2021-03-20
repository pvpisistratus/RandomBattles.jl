using StaticArrays

struct StaticTeam
    mons::SVector{3,StaticPokemon}
end

struct DynamicTeam
    #These values are initialized, but change throughout the battle
    mons::SVector{3,DynamicPokemon}
    buffs::StatBuffs         #Initially StatBuffs(0, 0)
    switchCooldown::Int8     #Initially 0
    shields::Int8            #Initially 2
    active::Int8             #Initially 1 (the lead)
end

StaticTeam(mons::Array{Int64}; league::String = "great", cup::String = "open") =
    StaticTeam(StaticPokemon.(mons, league = league, cup = cup))

StaticTeam(mons::Array{String}; league::String = "great", cup::String = "open") =
    StaticTeam(StaticPokemon.(mons, league = league, cup = cup))

DynamicTeam(team::StaticTeam) = DynamicTeam(DynamicPokemon.(team.mons), defaultBuff, Int8(0), Int8(2), Int8(1))

get_other_agent(agent::Int8) = agent == Int8(1) ? Int8(2) : Int8(1)

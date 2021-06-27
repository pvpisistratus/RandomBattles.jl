using StaticArrays

struct StaticTeam
    mons::SVector{3,StaticPokemon}
end

struct DynamicTeam
    #These values are initialized, but change throughout the battle
    mons::SVector{3,DynamicPokemon}
    switchCooldown::Int8     # Initially 0
    data::UInt8              # StatBuff info and shields
end

StaticTeam(mons::Array{String}; league::String = "great", cup::String = "open") =
    StaticTeam(StaticPokemon.(mons, league = league, cup = cup))

StaticTeam(mons::Array{Int64}; league::String = "great", cup::String = "open") =
    StaticTeam(StaticPokemon.(mons, league = league, cup = cup))

has_shield(team::DynamicTeam) = !iszero(team.data % 0x03)

DynamicTeam(team::StaticTeam) = DynamicTeam(DynamicPokemon.(team.mons), Int8(0), UInt8(122))

# returns 2 if 1, 1 if 2. Note: tested some bit twiddling code that was roughly
# equivalent speed, but this is more readable.
get_other_agent(agent::Int8) = agent == Int8(1) ? Int8(2) : Int8(1)
get_other_agent(agent::UInt16) = agent == 0x0001 ? 0x0002 : 0x0001

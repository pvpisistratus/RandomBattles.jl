struct StaticTeam <: AbstractArray{StaticPokemon, 1}
    mon1::StaticPokemon
    mon2::StaticPokemon
    mon3::StaticPokemon
end

Base.size(s::StaticTeam) = (3,)
Base.IndexStyle(::Type{<:StaticTeam}) = IndexLinear()
Base.getindex(s::StaticTeam, i::UInt8) =
    i == 0x01 ? s.mon1 : i == 0x02 ? s.mon2 : s.mon3

StaticTeam(mons::NTuple{3, Union{String, Int}}; league::String = "great", cup::String = "all") =
    StaticTeam(StaticPokemon(mons[1], league = league, cup = cup),
               StaticPokemon(mons[2], league = league, cup = cup),
               StaticPokemon(mons[3], league = league, cup = cup))

struct DynamicTeam <: AbstractArray{DynamicPokemon, 1}
    #These values are initialized, but change throughout the battle
    mon1::DynamicPokemon
    mon2::DynamicPokemon
    mon3::DynamicPokemon
    switch_cooldown::UInt8     # Initially 0
    data::UInt8              # StatBuff info and shields
end

Base.size(d::DynamicTeam) = (3,)
Base.IndexStyle(::Type{<:DynamicTeam}) = IndexLinear()
Base.getindex(d::DynamicTeam, i::UInt8) =
    i == 0x01 ? d.mon1 : i == 0x02 ? d.mon2 : d.mon3

get_buffs(team::DynamicTeam) = team.data ÷ 0x1b, (team.data ÷ 0x03) % 0x09
get_shields(team::DynamicTeam) = team.data % 0x03
has_shield(team::DynamicTeam) = !iszero(team.data % 0x03)
# returns 2 if 1, 1 if 2. Note: tested some bit twiddling code that was roughly
# equivalent speed, but this is more readable.
get_other_agent(agent::UInt8) = agent == 0x01 ? 0x02 : 0x01

DynamicTeam(team::StaticTeam) = DynamicTeam(
    DynamicPokemon(team[0x01]),
    DynamicPokemon(team[0x02]),
    DynamicPokemon(team[0x03]),
    Int8(0),
    0x7a
)
DynamicTeam(mon1::DynamicPokemon, mon2::DynamicPokemon, mon3::DynamicPokemon, 
    switch_cooldown::Int8, a::UInt8, d::UInt8, shields::UInt8) = 
    DynamicTeam(mon1, mon2, mon3, switch_cooldown, a * 0x1b + d * 0x03 + shields)
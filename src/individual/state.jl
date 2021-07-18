struct StaticIndividualState <: AbstractArray{StaticPokemon, 1}
    mon1::StaticPokemon
    mon2::StaticPokemon
end

Base.size(s::StaticIndividualState) = (2,)
Base.IndexStyle(::Type{<:StaticIndividualState}) = IndexLinear()
Base.getindex(s::StaticIndividualState, i::UInt8) = i == 0x01 ? s.mon1 : s.mon2

StaticIndividualState(teams::Array{Int64}; league = "great", cup = "all") =
    StaticIndividualState(
        StaticPokemon(teams[1], league = league, cup = cup),
        StaticPokemon(teams[2], league = league, cup = cup)
    )

StaticIndividualState(teams::Array{String}; league = "great", cup = "all") =
    StaticIndividualState(
        StaticPokemon(teams[1], league = league, cup = cup),
        StaticPokemon(teams[2], league = league, cup = cup)
    )

struct DynamicIndividualState <: AbstractArray{DynamicPokemon, 1}
    mon1::DynamicPokemon
    mon2::DynamicPokemon
    data::UInt32
end

Base.size(d::DynamicIndividualState) = (2,)
Base.IndexStyle(::Type{<:DynamicIndividualState}) = IndexLinear()
Base.getindex(d::DynamicIndividualState, i::UInt8) = i == 0x01 ? d.mon1 : d.mon2

has_shield(state::DynamicIndividualState, agent::UInt8) = agent == 0x01 ?
  !iszero(state.data % UInt32(3)) :
  !iszero((state.data ÷ UInt32(3)) % UInt32(3))

get_fast_moves_pending(state::DynamicIndividualState) =
    (state.data ÷ UInt32(9)) % UInt32(7), (state.data ÷ UInt32(63)) % UInt32(7)

get_cmp(state::DynamicIndividualState) = (state.data ÷ UInt32(441)) % UInt32(5)

get_chance(state::DynamicIndividualState) = (state.data ÷ UInt32(2205)) %
    UInt32(6)

get_buffs(data::UInt32, attacker::Int64) = attacker == 1 ?
    ((data ÷ UInt32(13230))   % 9, (data ÷ UInt32(119070))  % 9) :
    ((data ÷ UInt32(1071630)) % 9, (data ÷ UInt32(9644670)) % 9)

DynamicIndividualState(state::StaticIndividualState; shields::Int8 = Int8(2)) =
    DynamicIndividualState(
        DynamicPokemon(state[0x01]),
        DynamicPokemon(state[0x02]),
        0x04*shields + UInt32(43394400)
    )

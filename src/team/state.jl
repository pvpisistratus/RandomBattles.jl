struct StaticState <: AbstractArray{StaticTeam, 1}
    team1::StaticTeam
    team2::StaticTeam
end

Base.size(s::StaticState) = (2,)
Base.IndexStyle(::Type{<:StaticState}) = IndexLinear()
Base.getindex(s::StaticState, i::UInt8) = i == 0x01 ? s.team1 : s.team2

StaticState(teams::Array{Int64}; league = "great", cup = "all") =
    StaticState(StaticTeam(teams[1:3], league = league, cup = cup),
        StaticTeam(teams[4:6], league = league, cup = cup))

StaticState(teams::Array{String}; league = "great", cup = "all") =
    StaticState(StaticTeam(teams[1:3], league = league, cup = cup),
        StaticTeam(teams[4:6], league = league, cup = cup))

struct DynamicState <: AbstractArray{DynamicTeam, 1}
    team1::DynamicTeam
    team2::DynamicTeam
    data::UInt16                    # active, fastMovesPending, cmp, chance
end

Base.size(d::DynamicState) = (2,)
Base.IndexStyle(::Type{<:DynamicState}) = IndexLinear()
Base.getindex(d::DynamicState, i::UInt8) = i == 0x01 ? d.team1 : d.team2

DynamicState(state::StaticState) = DynamicState(
    DynamicTeam(state[0x01]), DynamicTeam(state[0x02]), 0x0085)

get_active(state::DynamicState) = state.data & 0x0003,
    (state.data >> 0x0002) & 0x0003
get_fast_moves_pending(state::DynamicState) = (state.data >> 4) % 0x0007,
    (state.data ÷ 0x0070) % 0x0007
get_cmp(state::DynamicState) = (state.data ÷ 0x0310) % 0x0005
get_chance(state::DynamicState) = state.data ÷ 0x0f50

using StaticArrays

struct DynamicIndividualState
    teams::SVector{2,Individual}
    fastMovesPending::SVector{2,Int8}
end

struct StaticIndividualState
    teams::SVector{2,StaticIndividual}
end

StaticIndividualState(teams::Array{Int64}; league = "great", cup = "open") =
    StaticIndividualState(StaticIndividual(teams[1:3]), StaticIndividual(teams[4:6]))

StaticState(teams::Array{String}; league = "great", cup = "open") = StaticIndividualState(
    [StaticIndividual(teams[1:3], league = league, cup = cup), StaticIndividual(teams[4:6], league = league, cup = cup)]
)

DynamicIndividualState(state::StaticIndividualState) = DynamicIndividualState(
    DynamicIndividual.(state.teams),
    [Int8(-1), Int8(-1)],
)

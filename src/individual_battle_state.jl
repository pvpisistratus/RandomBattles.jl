using StaticArrays

struct DynamicIndividualState
    teams::SVector{2,DynamicIndividual}
    fastMovesPending::SVector{2,Int8}
end

struct StaticIndividualState
    teams::SVector{2,StaticIndividual}
end

StaticIndividualState(teams::Array{Int64}; league = "great", cup = "open") =
    StaticIndividualState(StaticIndividual(teams[1]), StaticIndividual(teams[2]))

StaticIndividualState(teams::Array{String}; league = "great", cup = "open") = StaticIndividualState(
    [StaticIndividual(teams[1], league = league, cup = cup), StaticIndividual(teams[2], league = league, cup = cup)]
)

DynamicIndividualState(state::StaticIndividualState) = DynamicIndividualState(
    DynamicIndividual.(state.teams),
    [Int8(-1), Int8(-1)],
)

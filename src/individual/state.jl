using StaticArrays

struct StaticIndividualState
    teams::SVector{2,StaticIndividual}
end

function StaticIndividualState(teams::Array{Union{Int64, String}}; league = "great", cup = "open")
    opp1 = StaticIndividualPokemon(teams[2], league = league, cup = cup)
    opp2 = StaticIndividualPokemon(teams[1], league = league, cup = cup)
    return StaticIndividualState([StaticIndividual(teams[1], league = league, cup = cup, opponent = opp1), StaticIndividual(teams[2], league = league, cup = cup, opponent = opp2)])
end

struct DynamicIndividualState
    teams::SVector{2,DynamicIndividual}
    fastMovesPending::SVector{2,Int8}
end

DynamicIndividualState(state::StaticIndividualState; shields::Int8 = Int8(2)) = DynamicIndividualState(
    DynamicIndividual.(state.teams, shields = shields),
    [Int8(-1), Int8(-1)],
)

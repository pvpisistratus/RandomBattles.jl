using StaticArrays

struct StaticIndividualState
    teams::SVector{2,StaticIndividual}
end

function StaticIndividualState(teams::Array{Int64}; league = "great", cup = "open")
    opp1 = StaticIndividualPokemon(teams[2], league = league, cup = cup)
    opp2 = StaticIndividualPokemon(teams[1], league = league, cup = cup)
    team1 = StaticIndividual(teams[1], league = league, cup = cup, opponent = opp1)
    team2 = StaticIndividual(teams[2], league = league, cup = cup, opponent = opp2)
    return StaticIndividualState([team1, team2])
end

function StaticIndividualState(teams::Array{String}; league = "great", cup = "open")
    opp1 = StaticIndividualPokemon(teams[2], league = league, cup = cup)
    opp2 = StaticIndividualPokemon(teams[1], league = league, cup = cup)
    team1 = StaticIndividual(teams[1], league = league, cup = cup, opponent = opp1)
    team2 = StaticIndividual(teams[2], league = league, cup = cup, opponent = opp2)
    return StaticIndividualState([team1, team2])
end

struct DynamicIndividualState
    teams::SVector{2,DynamicIndividual}
    fastMovesPending::SVector{2,Int8}
end

DynamicIndividualState(state::StaticIndividualState; shields::Int8 = Int8(2)) = DynamicIndividualState(
    DynamicIndividual.(state.teams, shields = shields),
    [Int8(-1), Int8(-1)],
)

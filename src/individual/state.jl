using StaticArrays

struct StaticIndividualState
    teams::SVector{2,StaticIndividualPokemon}
end

function StaticIndividualState(teams::Array{Int64}; league = "great", cup = "open")
    opp1 = StaticIndividualPokemon(teams[2], league = league, cup = cup)
    opp2 = StaticIndividualPokemon(teams[1], league = league, cup = cup)
    return StaticIndividualState([StaticIndividualPokemon(teams[1], league = league, cup = cup, opponent = opp1), 
        StaticIndividualPokemon(teams[2], league = league, cup = cup, opponent = opp2)])
end

function StaticIndividualState(teams::Array{String}; league = "great", cup = "open")
    opp1 = StaticIndividualPokemon(teams[2], league = league, cup = cup)
    opp2 = StaticIndividualPokemon(teams[1], league = league, cup = cup)
    return StaticIndividualState([StaticIndividualPokemon(teams[1], league = league, cup = cup, opponent = opp1), 
        StaticIndividualPokemon(teams[2], league = league, cup = cup, opponent = opp2)])
end

struct DynamicIndividualState
    teams::SVector{2,DynamicIndividualPokemon}
    fastMovesPending::SVector{2,Int8}
end

DynamicIndividualState(state::StaticIndividualState; shields::Int8 = Int8(2)) = DynamicIndividualState(
    DynamicIndividualPokemon.(state.teams, shields = shields),
    [Int8(-1), Int8(-1)],
)

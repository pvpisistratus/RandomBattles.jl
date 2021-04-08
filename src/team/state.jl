using StaticArrays

struct StaticState
    teams::SVector{2,StaticTeam}
end

struct DynamicState
    teams::SVector{2,DynamicTeam}
    fastMovesPending::SVector{2,Int8}
end

function StaticState(teams::Array{String}; league = "great", cup = "open")
    teams_copy = teams
    opps1 = @SVector[i for i in StaticPokemon.(teams_copy[4:6], league = league, cup = cup)]
    opps2 = @SVector[i for i in StaticPokemon.(teams_copy[1:3], league = league, cup = cup)]
    team1 = StaticTeam(teams_copy[1:3], league = league, cup = cup, opponents = opps1)
    team2 = StaticTeam(teams_copy[4:6], league = league, cup = cup, opponents = opps2)
    return StaticState([team1, team2])
end

StaticState(team1::StaticTeam, team2::StaticTeam) = StaticState([team1, team2])

DynamicState(state::StaticState) = DynamicState(DynamicTeam.(state.teams), [Int8(-1), Int8(-1)])

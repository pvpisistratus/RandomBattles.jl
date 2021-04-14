using StaticArrays

struct StaticState
    teams::SVector{2,StaticTeam}
end

struct DynamicState
    teams::SVector{2,DynamicTeam}
    fastMovesPending::SVector{2,Int8}
end

function StaticState(teams::Array{Union{Int64, String}}; league = "great", cup = "open")
    opps1 = SVector(
        StaticPokemon(teams[4], league = league, cup = cup),
        StaticPokemon(teams[5], league = league, cup = cup),
        StaticPokemon(teams[6], league = league, cup = cup))
    opps2 = SVector(
        StaticPokemon(teams[1], league = league, cup = cup),
        StaticPokemon(teams[2], league = league, cup = cup),
        StaticPokemon(teams[3], league = league, cup = cup))
    team1 = StaticTeam(teams[1:3], league = league, cup = cup, opponents = opps1)
    team2 = StaticTeam(teams[4:6], league = league, cup = cup, opponents = opps2)
    return StaticState([team1, team2])
end

StaticState(team1::StaticTeam, team2::StaticTeam) = StaticState([team1, team2])

DynamicState(state::StaticState) = DynamicState(DynamicTeam.(state.teams), [Int8(-1), Int8(-1)])

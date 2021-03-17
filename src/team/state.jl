using StaticArrays

struct StaticState
    teams::SVector{2,StaticTeam}
end

struct DynamicState
    teams::SVector{2,DynamicTeam}
    fastMovesPending::SVector{2,Int8}
end

StaticState(teams::Array{Int64}; league = "great", cup = "open") =
    StaticState(Team(teams[1:(length(teams)÷2)]), Team(teams[(length(teams)÷2+1):length(teams)]))

StaticState(teams::Array{String}; league = "great", cup = "open") =
    StaticState([StaticTeam(teams[1:3], league = league, cup = cup), StaticTeam(teams[4:6], league = league, cup = cup)])

StaticState(team1::Team, team2::Team) = StaticState([team1, team2])

DynamicState(state::StaticState) = DynamicState(DynamicTeam.(state.teams), [Int8(-1), Int8(-1)])

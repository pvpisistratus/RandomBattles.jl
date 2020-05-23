using StaticArrays

struct ChargedAction
    move::Move
    charge::Float64
end

struct SwitchAction
    pokemon::Int8
    time::Int16
end

struct State
    teams::SVector{2,Team}
    agent::Int64
    chargedMovesPending::SVector{2,ChargedAction}
    switchesPending::SVector{2,SwitchAction}
end

State(team1::Team, team2::Team) = State(
    [team1, team2],
    1,
    [
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ],
    [SwitchAction(0, 0), SwitchAction(0, 0)],
)

State(teams::Array{Int64}; league = "great") = State(
    [
     Team(
         Pokemon.(teams[1:(length(teams)÷2)], league = league),
         StatBuffs(0, 0),
         0,
         2,
         1,
         rand(Bool),
     ),
     Team(
         Pokemon.(
             teams[(length(teams)÷2+1):length(teams)],
             league = league,
         ),
         StatBuffs(0, 0),
         0,
         2,
         1,
         rand(Bool),
     ),
    ],
    1,
    [
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ],
    [SwitchAction(0, 0), SwitchAction(0, 0)],
)

State(teams::Array{String}; league = "great") =
    State(convert_indices.(teams, league = league), league = league)

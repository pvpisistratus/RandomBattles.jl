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
    fastMovesPending::SVector{2,Bool}
    chargedMovesPending::SVector{2,ChargedAction}
    switchesPending::SVector{2,SwitchAction}
end

State(team1::Team, team2::Team) = State(
    [team1, team2],
    1,
    [false, false],
    [
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ],
    [SwitchAction(0, 0), SwitchAction(0, 0)],
)

State(teams::Array{Int64}; league = "great", cup = "open") = State(
    [
     Team(
         Pokemon.(
            teams[1:(length(teams)÷2)],
            league = league,
            cup = cup,
         ),
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
             cup = cup,
         ),
         StatBuffs(0, 0),
         0,
         2,
         1,
         rand(Bool),
     ),
    ],
    1,
    [false, false],
    [
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ],
    [SwitchAction(0, 0), SwitchAction(0, 0)],
)

State(teams::Array{String}; league = "great", cup = "open") = State(
    [Team(teams[1:3], league = league, cup = cup), Team(teams[4:6], league = league, cup = cup)],
    1,
    [false, false],
    [
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ],
    [SwitchAction(0, 0), SwitchAction(0, 0)],
)

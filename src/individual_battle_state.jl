using StaticArrays

struct IndividualBattleState <: BattleState
    teams::SVector{2,Individual}
    agent::Int64
    fastMovesPending::SVector{2,Bool}
    chargedMovesPending::SVector{2,ChargedAction}
    switchesPending::SVector{2,SwitchAction}
end

function vectorize(state::IndividualBattleState)
    return vcat(vcat(vectorize(state.teams[1]), vectorize(state.teams[2])),
        [state.agent])
end

IndividualBattleState(team1::Individual, team2::Individual) = IndividualBattleState(
    [team1, team2],
    1,
    [false, false],
    [
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ],
    [SwitchAction(0, 0), SwitchAction(0, 0)],
)

IndividualBattleState(teams::Array{Int64}; league = "great", cup = "open", shields = 2) = IndividualBattleState(
    [
     Individual(
         [Pokemon(
            teams[1],
            league = league,
            cup = cup,
         )],
         StatBuffs(0, 0),
         0,
         shields,
         1,
         rand(Bool),
     ),
     Individual(
         [Pokemon(
             teams[2],
             league = league,
             cup = cup,
         )],
         StatBuffs(0, 0),
         0,
         shields,
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

IndividualBattleState(teams::Array{String}; league = "great", cup = "open", shields = 2) = IndividualBattleState(
    [Individual([teams[1]], league = league, cup = cup, shields = shields), Individual([teams[2]], league = league, cup = cup, sheilds = shields)],
    1,
    [false, false],
    [
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
     ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ],
    [SwitchAction(0, 0), SwitchAction(0, 0)],
)

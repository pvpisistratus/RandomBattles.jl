using StaticArrays

struct IndividualBattleState
    teams::SVector{2,Individual}
    agent::Int8
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
    Int8(1),
    [false, false],
    [defaultCharge, defaultCharge],
    [defaultSwitch, defaultSwitch],
)

IndividualBattleState(teams::Array{Int64}; league = "great", cup = "open", shields = 2) = IndividualBattleState(
    [
     Individual(
        Pokemon(teams[1], league = league, cup = cup),
        defaultBuff,
        shields,
        rand(Bool),
     ),
     Individual(
        Pokemon(teams[2], league = league, cup = cup),
        defaultBuff,
        shields,
        rand(Bool),
     ),
    ],
    Int8(1),
    [false, false],
    [defaultCharge, defaultCharge],
    [defaultSwitch, defaultSwitch],
)

IndividualBattleState(teams::Array{String}; league = "great", cup = "open", shields = 2) = IndividualBattleState(
    [Individual(teams[1], league = league, cup = cup, shields = shields), Individual(teams[2], league = league, cup = cup, shields = shields)],
    Int8(1),
    [false, false],
    [defaultCharge, defaultCharge],
    [defaultSwitch, defaultSwitch],
)

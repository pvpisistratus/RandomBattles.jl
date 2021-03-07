using StaticArrays

struct ChargedAction
    move::UInt8
    charge::Int8
end

function Setfield.:setindex(arr::StaticArrays.SVector{2, ChargedAction}, c::ChargedAction, i::Int8)
    return setindex(arr, c, Int64(i))
end

const defaultCharge = ChargedAction(UInt8(0), Int8(0))

struct SwitchAction
    pokemon::Int8
    time::Int8
end

function Setfield.:setindex(arr::StaticArrays.SVector{2, SwitchAction}, s::SwitchAction, i::Int8)
    return setindex(arr, s, Int64(i))
end

const defaultSwitch = SwitchAction(Int8(0), Int8(0))

function Setfield.:setindex(arr::StaticArrays.SVector{2, Int8}, n::Int8, i::Int8)
    return setindex(arr, n, Int64(i))
end

struct State
    teams::SVector{2,Team}
    agent::Int8
    fastMovesPending::SVector{2,Int8}
    chargedMovesPending::SVector{2,ChargedAction}
    switchesPending::SVector{2,SwitchAction}
end

function vectorize(state::State)
    return vcat(vectorize(state.teams[1]), vcat(vectorize(state.teams[2]),
        [Int8(1) == state.agent, Int8(2) == state.agent]))
end

State(team1::Team, team2::Team) = State(
    [team1, team2],
    Int8(1),
    [Int8(-1), Int8(-1)],
    [defaultCharge, defaultCharge],
    [defaultSwitch, defaultSwitch]
)

State(teams::Array{Int64}; league = "great", cup = "open") = State(
    [
     Team(
         Pokemon.(
            teams[1:(length(teams)÷2)],
            league = league,
            cup = cup,
         ),
         defaultBuff,
         Int8(0),
         Int8(2),
         Int8(1),
         rand(Bool),
     ),
     Team(
         Pokemon.(
             teams[(length(teams)÷2+1):length(teams)],
             league = league,
             cup = cup,
         ),
         defaultBuff,
         Int8(0),
         Int8(2),
         Int8(1),
         rand(Bool),
     ),
    ],
    Int8(1),
    [Int8(-1), Int8(-1)],
    [defaultCharge, defaultCharge],
    [defaultSwitch, defaultSwitch]
)

State(teams::Array{String}; league = "great", cup = "open") = State(
    [Team(teams[1:3], league = league, cup = cup), Team(teams[4:6], league = league, cup = cup)],
    Int8(1),
    [Int8(-1), Int8(-1)],
    [defaultCharge, defaultCharge],
    [defaultSwitch, defaultSwitch]
)

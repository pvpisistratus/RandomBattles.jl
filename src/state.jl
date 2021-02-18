using StaticArrays

struct ChargedAction
    move::Int8
    charge::Int8
end

function Setfield.:setindex(arr::StaticArrays.SVector{2, ChargedAction}, c::ChargedAction, i::Int8)
    return setindex(arr, c, Int64(i))
end

const defaultCharge = ChargedAction(Int8(0), Int8(0))

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

struct StaticState
    teams::SVector{2,StaticTeam}
end

struct DynamicState
    teams::SVector{2,DynamicTeam}
    agent::Int8
    fastMovesPending::SVector{2,Int8}
end

struct Decision
    chargedMovesPending::SVector{2,ChargedAction}
    shielding::SVector{2, Bool}
    switchesPending::SVector{2,SwitchAction}
end

const defaultDecision = Decision([defaultCharge, defaultCharge], [false, false], [defaultSwitch, defaultSwitch])

function Setfield.:setindex(arr::StaticArrays.SVector{2, Bool}, n::Bool, i::Int8)
    return setindex(arr, n, Int64(i))
end

#function vectorize(state::State)
#    return vcat(vectorize(state.teams[1]), vcat(vectorize(state.teams[2]),
#        [Int8(1) == state.agent, Int8(2) == state.agent]))
#end

StaticState(teams::Array{Int64}; league = "great", cup = "open") =
    StaticState(Team(teams[1:(length(teams)÷2)]), Team(teams[(length(teams)÷2+1):length(teams)]))

StaticState(teams::Array{String}; league = "great", cup = "open") = StaticState(
    [StaticTeam(teams[1:3], league = league, cup = cup), StaticTeam(teams[4:6], league = league, cup = cup)]
)

DynamicState(state::StaticState) = DynamicState(
    DynamicTeam.(state.teams),
    Int8(1),
    [Int8(-1), Int8(-1)],
)

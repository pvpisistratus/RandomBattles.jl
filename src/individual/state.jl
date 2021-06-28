using StaticArrays

struct StaticIndividualState
    teams::SVector{2, StaticPokemon}
end

function StaticIndividualState(teams::Array{Int64}; league = "great", cup = "open")
    return StaticIndividualState([
        StaticPokemon(teams[1], league = league, cup = cup),
        StaticPokemon(teams[2], league = league, cup = cup)])
end

function StaticIndividualState(teams::Array{String}; league = "great", cup = "open")
    return StaticIndividualState([
        StaticPokemon(teams[1], league = league, cup = cup),
        StaticPokemon(teams[2], league = league, cup = cup)])
end

struct DynamicIndividualState
    teams::SVector{2,DynamicPokemon}
    data::UInt32
end

has_shield(state::DynamicIndividualState, agent::Int64) = agent == 1 ?
  !iszero(state.data % UInt32(3)) : !iszero((state.data ÷ UInt32(3)) % UInt32(3))

get_fast_moves_pending(state::DynamicIndividualState) =
    (state.data ÷ UInt32(9)) % UInt32(7), (state.data ÷ UInt32(63)) % UInt32(7)

get_cmp(state::DynamicIndividualState) = (state.data ÷ UInt32(441)) % UInt32(5)

get_chance(state::DynamicIndividualState) = (state.data ÷ UInt32(2205)) % UInt32(6)

get_buffs(state::DynamicIndividualState, attacker::Int64) = attacker == 1 ?
    ((state.data ÷ UInt32(13230))   % 9, (state.data ÷ UInt32(119070))  % 9) :
    ((state.data ÷ UInt32(1071630)) % 9, (state.data ÷ UInt32(9644670)) % 9)

DynamicIndividualState(state::StaticIndividualState; shields::Int8 = Int8(2)) = DynamicIndividualState(
    DynamicPokemon.(state.teams),
    0x04*shields + UInt32(43394400)
)

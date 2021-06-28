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

has_shields(state::DynamicIndividualState, agent::Int64) = agent == 1 ?
    iszero(state.data % 3) : iszero((state.data ÷ 3) % 3)

get_fast_moves_pending(state::DynamicIndividualState) =
    (state.data ÷ 9) % 7, (state.data ÷ 63) % 7

get_cmp(state::DynamicIndividualState) = (state.data ÷ 441) % 5

get_chance(state::DynamicIndividualState) = (state.data ÷ 2205) % 6

get_buffs(state::DynamicIndividualState, attacker::Int64) = attacker == 1 ?
    ((state.data ÷ 13230)   % 9, (state.data ÷ 119070)  % 9) :
    ((state.data ÷ 1071630) % 9, (state.data ÷ 9644670) % 9)
end

DynamicIndividualState(state::StaticIndividualState; shields::Int8 = Int8(2)) = DynamicIndividualState(
    DynamicPokemon.(state.teams, shields = shields),
    ,
)

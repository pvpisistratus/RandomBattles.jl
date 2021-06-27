using StaticArrays

struct StaticState
    teams::SVector{2,StaticTeam}
end

struct DynamicState
    teams::SVector{2,DynamicTeam}
    data::UInt16                    # active, fastMovesPending, cmp, chance
end

function StaticState(teams::Array{Int64}; league = "great", cup = "open")
    opps1 = SVector(
        StaticPokemon(teams[4], league = league, cup = cup),
        StaticPokemon(teams[5], league = league, cup = cup),
        StaticPokemon(teams[6], league = league, cup = cup))
    opps2 = SVector(
        StaticPokemon(teams[1], league = league, cup = cup),
        StaticPokemon(teams[2], league = league, cup = cup),
        StaticPokemon(teams[3], league = league, cup = cup))
    team1 = StaticTeam(teams[1:3], league = league, cup = cup)
    team2 = StaticTeam(teams[4:6], league = league, cup = cup)
    return StaticState([team1, team2])
end

function StaticState(teams::Array{String}; league = "great", cup = "open")
    opps1 = SVector(
        StaticPokemon(teams[4], league = league, cup = cup),
        StaticPokemon(teams[5], league = league, cup = cup),
        StaticPokemon(teams[6], league = league, cup = cup))
    opps2 = SVector(
        StaticPokemon(teams[1], league = league, cup = cup),
        StaticPokemon(teams[2], league = league, cup = cup),
        StaticPokemon(teams[3], league = league, cup = cup))
    team1 = StaticTeam(teams[1:3], league = league, cup = cup)
    team2 = StaticTeam(teams[4:6], league = league, cup = cup)
    return StaticState([team1, team2])
end

StaticState(team1::StaticTeam, team2::StaticTeam) = StaticState([team1, team2])

get_active(state::DynamicState) = state.data & 0x0003,
    (state.data >> 0x0002) & 0x0003

get_fast_moves_pending(state::DynamicState) = state.data % 0x0070,
    (state.data ÷ 0x0070) % 0x0007

get_cmp(state::DynamicState) = (state.data ÷ 0x0310) % 0x0005

get_chance(state::DynamicState) = state.data ÷ 0x0f50

DynamicState(state::StaticState) = DynamicState(DynamicTeam.(state.teams), [Int8(-1), Int8(-1)])

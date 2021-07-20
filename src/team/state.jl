struct StaticState <: AbstractArray{StaticTeam, 1}
    team1::StaticTeam
    team2::StaticTeam
end

Base.size(s::StaticState) = (2,)
Base.IndexStyle(::Type{<:StaticState}) = IndexLinear()
Base.getindex(s::StaticState, i::UInt8) = i == 0x01 ? s.team1 : s.team2

StaticState(teams::Array{Int64}; league = "great", cup = "all") =
    StaticState(StaticTeam(teams[1:3], league = league, cup = cup),
        StaticTeam(teams[4:6], league = league, cup = cup))

StaticState(teams::Array{String}; league = "great", cup = "all") =
    StaticState(StaticTeam(teams[1:3], league = league, cup = cup),
        StaticTeam(teams[4:6], league = league, cup = cup))

struct DynamicState <: AbstractArray{DynamicTeam, 1}
    team1::DynamicTeam
    team2::DynamicTeam
    data::UInt32              # active, fastMovesPending, cmp, chance, fm_damage
end

Base.size(d::DynamicState) = (2,)
Base.IndexStyle(::Type{<:DynamicState}) = IndexLinear()
Base.getindex(d::DynamicState, i::UInt8) = i == 0x01 ? d.team1 : d.team2

get_active(state::DynamicState) = UInt16(state.data & UInt32(3)),
    UInt16((state.data >> UInt32(2)) & UInt32(3))
get_fast_moves_pending(state::DynamicState) =
    UInt16((state.data >> UInt32(4)) % UInt32(7)),
    UInt16((state.data ÷ UInt32(112)) % UInt32(7))
get_cmp(state::DynamicState) = UInt16((state.data ÷ UInt32(784)) % UInt32(5))
get_chance(state::DynamicState) =
    UInt16((state.data ÷ UInt32(3920)) % UInt32(6))
get_fm_damage(state::DynamicState) =
    UInt16((state.data ÷ UInt32(23520)) % UInt32(425)),
    UInt16(state.data ÷ UInt32(9996000))

function get_fast_move_damages(state::DynamicState, static_state::StaticState,
    active1::UInt16, active2::UInt16)
    static_mon_1 = static_state[0x01][active1]
    static_mon_2 = static_state[0x02][active2]
    return calculate_damage(
        static_mon_2.stats.attack,
        state[0x02].data,
        static_mon_1,
        static_mon_2.fastMove,
    ), calculate_damage(
        static_mon_1.stats.attack,
        state[0x01].data,
        static_mon_2,
        static_mon_1.fastMove,
    )
end

function update_fm_damage(state::DynamicState,
    fm_damages::Tuple{UInt16, UInt16})
    fm_dmg1, fm_dmg2 = get_fm_damage(state)
    data = state.data
    if fm_damages[1] > fm_dmg1
        data += UInt32(fm_damages[1] - fm_dmg1) * UInt32(23520)
    else
        data -= UInt32(fm_dmg1 - fm_damages[1]) * UInt32(23520)
    end
    if fm_damages[2] > fm_dmg2
        data += UInt32(fm_damages[2] - fm_dmg2) * UInt32(9996000)
    else
        data -= UInt32(fm_dmg2 - fm_damages[2]) * UInt32(9996000)
    end
    return DynamicState(state[0x01], state[0x02], data)
end

function DynamicState(state::StaticState)
    d_state = DynamicState(DynamicTeam(state[0x01]), DynamicTeam(state[0x02]),
        0x0085)
    return update_fm_damage(d_state, get_fast_move_damages(d_state, state,
        0x0001, 0x0001))
end

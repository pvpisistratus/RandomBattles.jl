struct StaticState <: AbstractArray{StaticTeam, 1}
    team1::StaticTeam
    team2::StaticTeam
end

Base.size(s::StaticState) = (2,)
Base.IndexStyle(::Type{<:StaticState}) = IndexLinear()
Base.getindex(s::StaticState, i::UInt8) = i == 0x01 ? s.team1 : s.team2

StaticState(teams::NTuple{6, Union{String, Int}}; league = "great", cup = "all") =
    StaticState(StaticTeam((teams[1], teams[2], teams[3]), league = league, cup = cup),
        StaticTeam((teams[4], teams[5], teams[6]), league = league, cup = cup))

struct DynamicState <: AbstractArray{DynamicTeam, 1}
    team1::DynamicTeam
    team2::DynamicTeam
    data::UInt32 # active, pending fast moves, cmp, chance, fast move damage
end

Base.size(d::DynamicState) = (2,)
Base.IndexStyle(::Type{<:DynamicState}) = IndexLinear()
Base.getindex(d::DynamicState, i::UInt8) = i == 0x01 ? d.team1 : d.team2

get_active(state::DynamicState) = UInt8(state.data & UInt32(3)),
    UInt8((state.data >> UInt32(2)) & UInt32(3))
get_fast_moves_pending(state::DynamicState) =
    UInt8((state.data >> UInt32(4)) % UInt32(7)),
    UInt8((state.data ÷ UInt32(112)) % UInt32(7))
get_cmp(state::DynamicState) = UInt8((state.data ÷ UInt32(784)) % UInt32(5))
get_chance(state::DynamicState) = UInt8((state.data ÷ UInt32(3920)) % UInt32(6))
get_fm_damage(state::DynamicState) =
    UInt16((state.data ÷ UInt32(23520)) % UInt32(425)),
    UInt16(state.data ÷ UInt32(9996000))

function update_fm_damage(state::DynamicState, static_state::StaticState)
    active1, active2 = get_active(state)

    new_fm_dmg1, new_fm_dmg2 = get_fast_move_damages(
        state, static_state, active1, active2)
    fm_dmg1, fm_dmg2 = get_fm_damage(state)
    data = state.data
    if new_fm_dmg1 > fm_dmg1
        data += UInt32(new_fm_dmg1 - fm_dmg1) * UInt32(23520)
    else
        data -= UInt32(fm_dmg1 - new_fm_dmg1) * UInt32(23520)
    end
    if new_fm_dmg2 > fm_dmg2
        data += UInt32(new_fm_dmg2 - fm_dmg2) * UInt32(9996000)
    else
        data -= UInt32(fm_dmg2 - new_fm_dmg2) * UInt32(9996000)
    end
    return DynamicState(state[0x01], state[0x02], data)
end

function DynamicState(s::StaticState)
    d = DynamicState(DynamicTeam(s[0x01]), DynamicTeam(s[0x02]), UInt32(133))
    return update_fm_damage(d, s)
end

DynamicState(team1::DynamicTeam, team2::DynamicTeam, active_1::UInt8, active_2::UInt8, 
    fm_pending_1::UInt8, fm_pending_2::UInt8, cmp::UInt8, chance::UInt8, 
    fm_dmg_1::UInt16, fm_dmg_2::UInt16) = 
    DynamicState(team1, team2, UInt32(active_1) + UInt32(active_2) << UInt32(2) + 
        UInt32(fm_pending_1) << UInt32(4) + UInt32(112) * UInt32(fm_pending_2) + 
        UInt32(cmp) * UInt32(784) + UInt32(chance) * UInt32(3920) + 
        UInt32(fm_dmg_1) * UInt32(23520) + UInt32(fm_dmg_2) * UInt32(9996000))
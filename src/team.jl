using StaticArrays

struct Team
    #These values are initialized, but change throughout the battle
    mons::SVector{3,Pokemon}
    buffs::StatBuffs         #Initially 0, 0
    switchCooldown::Int8    #Initially 0
    shields::Int8            #Initially 2
    active::Int8            #Initially 1 (the lead)
    shielding::Bool          #Initially random
end

function vectorize(team::Team)
    @inbounds return vcat(vectorize(team.mons[1]), vcat(vectorize(team.mons[2]),
        vcat(vectorize(team.mons[3]), [team.buffs.atk, team.buffs.def,
        team.switchCooldown, team.shields, Int8(1) == team.active,
        Int8(2) == team.active, Int8(3) == team.active])))
end

Team(
    mons::Array{Int64};
    league::String = "great",
    cup::String = "open",
) = Team(Pokemon.(mons, league = league, cup = cup), defaultBuff, Int8(0), Int8(2), Int8(1), rand(Bool))

Team(mons::Array{String}; league::String = "great", cup::String = "open") =
    Team(Pokemon.(mons, league = league, cup = cup), defaultBuff, Int8(0), Int8(2), Int8(1), rand(Bool))

Team(mons::Array{Pokemon}) =
    Team(mons, defaultBuff, Int8(0), Int8(2), Int8(1), rand(Bool))

setindex(arr::StaticArrays.SVector{2, Team}, t::Team, i::Int8) = i == Int8(1) ? arr[1] : arr[2]

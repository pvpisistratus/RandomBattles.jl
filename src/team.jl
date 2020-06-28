using StaticArrays

struct Team
    #These values are initialized, but change throughout the battle
    mons::SVector{3,Pokemon}
    buffs::StatBuffs         #Initially 0, 0
    switchCooldown::Int64    #Initially 0
    shields::Int8            #Initially 2
    active::Int64            #Initially 1 (the lead)
    shielding::Bool          #Initially random
end

function vectorize(team::Team)
    return vcat(vectorize(team.mons[1]), vcat(vectorize(team.mons[2]),
        vcat(vectorize(team.mons[3]), [team.buffs.atk, team.buffs.def,
        team.switchCooldown, team.shields, team.active])))
end

Team(
    mons::Array{Int64};
    league::String = "great",
    cup::String = "open",
) = Team(Pokemon.(mons, league = league, cup = cup), StatBuffs(0, 0), 0, 2, 1, rand(Bool))

Team(mons::Array{String}; league::String = "great", cup::String = "open") =
    Team(Pokemon.(mons, league = league, cup = cup), StatBuffs(0, 0), 0, 2, 1, rand(Bool))

Team(mons::Array{Pokemon}) =
    Team(mons, StatBuffs(0, 0), 0, 2, 1, rand(Bool))

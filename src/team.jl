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

Team(mons::Array{Int64}; league::String = "great") =
    Team(Pokemon.(mons, league = league), StatBuffs(0, 0), 0, 2, 1, rand(Bool))

Team(mons::Array{String}; league::String = "great") =
    Team(convert_indices.(mons, league = league), league = league)

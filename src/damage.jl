const double_super_effective = 15625
const super_effective = 25000
const neutral = 40000
const resisted = 64000
const double_resisted = 102400
const triple_resisted = 163840

get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Normal], T₂ <: resistivities[Normal]}    = triple_resisted
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Normal], T₂ <: immunities[Normal]}    = triple_resisted
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Normal], T₂ <: resistivities[Normal]} = double_resisted
get_eff(move::Move{Normal}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Normal]}                          = resisted
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Normal]}                          = resisted
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Normal], T₂ <: effectivities[Normal]}    = resisted
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Normal], T₂ <: immunities[Normal]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Normal], T₂ <: effectivities[Normal]} = neutral
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Normal], T₂ <: resistivities[Normal]} = neutral
get_eff(move::Move{Normal}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Normal]}                          = super_effective
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Normal]}                          = super_effective
get_eff(move::Move{Normal}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Normal], T₂ <: effectivities[Normal]} = double_super_effective

get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Fighting], T₂ <: resistivities[Fighting]}    = triple_resisted
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fighting], T₂ <: immunities[Fighting]}    = triple_resisted
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fighting], T₂ <: resistivities[Fighting]} = double_resisted
get_eff(move::Move{Fighting}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Fighting]}                          = resisted
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Fighting]}                          = resisted
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Fighting], T₂ <: effectivities[Fighting]}    = resisted
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fighting], T₂ <: immunities[Fighting]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fighting], T₂ <: effectivities[Fighting]} = neutral
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fighting], T₂ <: resistivities[Fighting]} = neutral
get_eff(move::Move{Fighting}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Fighting]}                          = super_effective
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Fighting]}                          = super_effective
get_eff(move::Move{Fighting}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fighting], T₂ <: effectivities[Fighting]} = double_super_effective

get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Flying], T₂ <: resistivities[Flying]}    = triple_resisted
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Flying], T₂ <: immunities[Flying]}    = triple_resisted
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Flying], T₂ <: resistivities[Flying]} = double_resisted
get_eff(move::Move{Flying}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Flying]}                          = resisted
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Flying]}                          = resisted
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Flying], T₂ <: effectivities[Flying]}    = resisted
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Flying], T₂ <: immunities[Flying]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Flying], T₂ <: effectivities[Flying]} = neutral
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Flying], T₂ <: resistivities[Flying]} = neutral
get_eff(move::Move{Flying}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Flying]}                          = super_effective
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Flying]}                          = super_effective
get_eff(move::Move{Flying}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Flying], T₂ <: effectivities[Flying]} = double_super_effective

get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Poison], T₂ <: resistivities[Poison]}    = triple_resisted
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Poison], T₂ <: immunities[Poison]}    = triple_resisted
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Poison], T₂ <: resistivities[Poison]} = double_resisted
get_eff(move::Move{Poison}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Poison]}                          = resisted
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Poison]}                          = resisted
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Poison], T₂ <: effectivities[Poison]}    = resisted
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Poison], T₂ <: immunities[Poison]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Poison], T₂ <: effectivities[Poison]} = neutral
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Poison], T₂ <: resistivities[Poison]} = neutral
get_eff(move::Move{Poison}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Poison]}                          = super_effective
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Poison]}                          = super_effective
get_eff(move::Move{Poison}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Poison], T₂ <: effectivities[Poison]} = double_super_effective

get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Ground], T₂ <: resistivities[Ground]}    = triple_resisted
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ground], T₂ <: immunities[Ground]}    = triple_resisted
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ground], T₂ <: resistivities[Ground]} = double_resisted
get_eff(move::Move{Ground}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Ground]}                          = resisted
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Ground]}                          = resisted
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Ground], T₂ <: effectivities[Ground]}    = resisted
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ground], T₂ <: immunities[Ground]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ground], T₂ <: effectivities[Ground]} = neutral
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ground], T₂ <: resistivities[Ground]} = neutral
get_eff(move::Move{Ground}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Ground]}                          = super_effective
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Ground]}                          = super_effective
get_eff(move::Move{Ground}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ground], T₂ <: effectivities[Ground]} = double_super_effective

get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Rock], T₂ <: resistivities[Rock]}    = triple_resisted
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Rock], T₂ <: immunities[Rock]}    = triple_resisted
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Rock], T₂ <: resistivities[Rock]} = double_resisted
get_eff(move::Move{Rock}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Rock]}                          = resisted
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Rock]}                          = resisted
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Rock], T₂ <: effectivities[Rock]}    = resisted
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Rock], T₂ <: immunities[Rock]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Rock], T₂ <: effectivities[Rock]} = neutral
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Rock], T₂ <: resistivities[Rock]} = neutral
get_eff(move::Move{Rock}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Rock]}                          = super_effective
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Rock]}                          = super_effective
get_eff(move::Move{Rock}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Rock], T₂ <: effectivities[Rock]} = double_super_effective

get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Bug], T₂ <: resistivities[Bug]}    = triple_resisted
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Bug], T₂ <: immunities[Bug]}    = triple_resisted
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Bug], T₂ <: resistivities[Bug]} = double_resisted
get_eff(move::Move{Bug}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Bug]}                          = resisted
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Bug]}                          = resisted
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Bug], T₂ <: effectivities[Bug]}    = resisted
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Bug], T₂ <: immunities[Bug]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Bug], T₂ <: effectivities[Bug]} = neutral
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Bug], T₂ <: resistivities[Bug]} = neutral
get_eff(move::Move{Bug}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Bug]}                          = super_effective
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Bug]}                          = super_effective
get_eff(move::Move{Bug}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Bug], T₂ <: effectivities[Bug]} = double_super_effective

get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Ghost], T₂ <: resistivities[Ghost]}    = triple_resisted
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ghost], T₂ <: immunities[Ghost]}    = triple_resisted
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ghost], T₂ <: resistivities[Ghost]} = double_resisted
get_eff(move::Move{Ghost}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Ghost]}                          = resisted
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Ghost]}                          = resisted
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Ghost], T₂ <: effectivities[Ghost]}    = resisted
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ghost], T₂ <: immunities[Ghost]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ghost], T₂ <: effectivities[Ghost]} = neutral
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ghost], T₂ <: resistivities[Ghost]} = neutral
get_eff(move::Move{Ghost}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Ghost]}                          = super_effective
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Ghost]}                          = super_effective
get_eff(move::Move{Ghost}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ghost], T₂ <: effectivities[Ghost]} = double_super_effective

get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Steel], T₂ <: resistivities[Steel]}    = triple_resisted
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Steel], T₂ <: immunities[Steel]}    = triple_resisted
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Steel], T₂ <: resistivities[Steel]} = double_resisted
get_eff(move::Move{Steel}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Steel]}                          = resisted
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Steel]}                          = resisted
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Steel], T₂ <: effectivities[Steel]}    = resisted
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Steel], T₂ <: immunities[Steel]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Steel], T₂ <: effectivities[Steel]} = neutral
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Steel], T₂ <: resistivities[Steel]} = neutral
get_eff(move::Move{Steel}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Steel]}                          = super_effective
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Steel]}                          = super_effective
get_eff(move::Move{Steel}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Steel], T₂ <: effectivities[Steel]} = double_super_effective

get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Fire], T₂ <: resistivities[Fire]}    = triple_resisted
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fire], T₂ <: immunities[Fire]}    = triple_resisted
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fire], T₂ <: resistivities[Fire]} = double_resisted
get_eff(move::Move{Fire}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Fire]}                          = resisted
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Fire]}                          = resisted
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Fire], T₂ <: effectivities[Fire]}    = resisted
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fire], T₂ <: immunities[Fire]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fire], T₂ <: effectivities[Fire]} = neutral
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fire], T₂ <: resistivities[Fire]} = neutral
get_eff(move::Move{Fire}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Fire]}                          = super_effective
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Fire]}                          = super_effective
get_eff(move::Move{Fire}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fire], T₂ <: effectivities[Fire]} = double_super_effective

get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Water], T₂ <: resistivities[Water]}    = triple_resisted
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Water], T₂ <: immunities[Water]}    = triple_resisted
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Water], T₂ <: resistivities[Water]} = double_resisted
get_eff(move::Move{Water}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Water]}                          = resisted
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Water]}                          = resisted
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Water], T₂ <: effectivities[Water]}    = resisted
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Water], T₂ <: immunities[Water]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Water], T₂ <: effectivities[Water]} = neutral
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Water], T₂ <: resistivities[Water]} = neutral
get_eff(move::Move{Water}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Water]}                          = super_effective
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Water]}                          = super_effective
get_eff(move::Move{Water}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Water], T₂ <: effectivities[Water]} = double_super_effective

get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Grass], T₂ <: resistivities[Grass]}    = triple_resisted
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Grass], T₂ <: immunities[Grass]}    = triple_resisted
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Grass], T₂ <: resistivities[Grass]} = double_resisted
get_eff(move::Move{Grass}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Grass]}                          = resisted
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Grass]}                          = resisted
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Grass], T₂ <: effectivities[Grass]}    = resisted
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Grass], T₂ <: immunities[Grass]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Grass], T₂ <: effectivities[Grass]} = neutral
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Grass], T₂ <: resistivities[Grass]} = neutral
get_eff(move::Move{Grass}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Grass]}                          = super_effective
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Grass]}                          = super_effective
get_eff(move::Move{Grass}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Grass], T₂ <: effectivities[Grass]} = double_super_effective

get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Electric], T₂ <: resistivities[Electric]}    = triple_resisted
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Electric], T₂ <: immunities[Electric]}    = triple_resisted
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Electric], T₂ <: resistivities[Electric]} = double_resisted
get_eff(move::Move{Electric}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Electric]}                          = resisted
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Electric]}                          = resisted
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Electric], T₂ <: effectivities[Electric]}    = resisted
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Electric], T₂ <: immunities[Electric]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Electric], T₂ <: effectivities[Electric]} = neutral
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Electric], T₂ <: resistivities[Electric]} = neutral
get_eff(move::Move{Electric}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Electric]}                          = super_effective
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Electric]}                          = super_effective
get_eff(move::Move{Electric}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Electric], T₂ <: effectivities[Electric]} = double_super_effective

get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Psychic], T₂ <: resistivities[Psychic]}    = triple_resisted
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Psychic], T₂ <: immunities[Psychic]}    = triple_resisted
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Psychic], T₂ <: resistivities[Psychic]} = double_resisted
get_eff(move::Move{Psychic}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Psychic]}                          = resisted
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Psychic]}                          = resisted
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Psychic], T₂ <: effectivities[Psychic]}    = resisted
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Psychic], T₂ <: immunities[Psychic]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Psychic], T₂ <: effectivities[Psychic]} = neutral
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Psychic], T₂ <: resistivities[Psychic]} = neutral
get_eff(move::Move{Psychic}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Psychic]}                          = super_effective
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Psychic]}                          = super_effective
get_eff(move::Move{Psychic}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Psychic], T₂ <: effectivities[Psychic]} = double_super_effective

get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Ice], T₂ <: resistivities[Ice]}    = triple_resisted
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ice], T₂ <: immunities[Ice]}    = triple_resisted
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ice], T₂ <: resistivities[Ice]} = double_resisted
get_eff(move::Move{Ice}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Ice]}                          = resisted
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Ice]}                          = resisted
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Ice], T₂ <: effectivities[Ice]}    = resisted
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ice], T₂ <: immunities[Ice]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Ice], T₂ <: effectivities[Ice]} = neutral
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ice], T₂ <: resistivities[Ice]} = neutral
get_eff(move::Move{Ice}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Ice]}                          = super_effective
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Ice]}                          = super_effective
get_eff(move::Move{Ice}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Ice], T₂ <: effectivities[Ice]} = double_super_effective

get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Dragon], T₂ <: resistivities[Dragon]}    = triple_resisted
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Dragon], T₂ <: immunities[Dragon]}    = triple_resisted
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Dragon], T₂ <: resistivities[Dragon]} = double_resisted
get_eff(move::Move{Dragon}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Dragon]}                          = resisted
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Dragon]}                          = resisted
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Dragon], T₂ <: effectivities[Dragon]}    = resisted
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Dragon], T₂ <: immunities[Dragon]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Dragon], T₂ <: effectivities[Dragon]} = neutral
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Dragon], T₂ <: resistivities[Dragon]} = neutral
get_eff(move::Move{Dragon}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Dragon]}                          = super_effective
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Dragon]}                          = super_effective
get_eff(move::Move{Dragon}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Dragon], T₂ <: effectivities[Dragon]} = double_super_effective

get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Dark], T₂ <: resistivities[Dark]}    = triple_resisted
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Dark], T₂ <: immunities[Dark]}    = triple_resisted
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Dark], T₂ <: resistivities[Dark]} = double_resisted
get_eff(move::Move{Dark}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Dark]}                          = resisted
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Dark]}                          = resisted
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Dark], T₂ <: effectivities[Dark]}    = resisted
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Dark], T₂ <: immunities[Dark]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Dark], T₂ <: effectivities[Dark]} = neutral
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Dark], T₂ <: resistivities[Dark]} = neutral
get_eff(move::Move{Dark}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Dark]}                          = super_effective
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Dark]}                          = super_effective
get_eff(move::Move{Dark}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Dark], T₂ <: effectivities[Dark]} = double_super_effective

get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Fairy], T₂ <: resistivities[Fairy]}    = triple_resisted
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fairy], T₂ <: immunities[Fairy]}    = triple_resisted
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fairy], T₂ <: resistivities[Fairy]} = double_resisted
get_eff(move::Move{Fairy}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: resistivities[Fairy]}                          = resisted
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: resistivities[Fairy]}                          = resisted
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: immunities[Fairy], T₂ <: effectivities[Fairy]}    = resisted
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fairy], T₂ <: immunities[Fairy]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: resistivities[Fairy], T₂ <: effectivities[Fairy]} = neutral
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fairy], T₂ <: resistivities[Fairy]} = neutral
get_eff(move::Move{Fairy}, defender::StaticPokemon{PokemonType, T₂}) where 
    {T₂ <: effectivities[Fairy]}                          = super_effective
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, PokemonType}) where 
    {T₁ <: effectivities[Fairy]}                          = super_effective
get_eff(move::Move{Fairy}, defender::StaticPokemon{T₁, T₂}) where 
    {T₁ <: effectivities[Fairy], T₂ <: effectivities[Fairy]} = double_super_effective

"""
    calculate_damage(
        attacker::StaticPokemon,
        atkBuff::Int8,
        defender::StaticPokemon,
        defBuff::Int8,
        move::Move;
        charge::Int8,
    )

Calculate the damage a particular pokemon does against another using a charged move

"""
function calculate_damage(
    attack::UInt16,
    buff_data::UInt8,
    defender::StaticPokemon,
    move::Move;
    charge::Int8 = Int8(100),
)
    a, d = get_buff_modifier(buff_data)
    return UInt16((26 * attack * get_power(move) * get_STAB(move) * a * charge) ÷ 
        (get_eff(move, defender) * defender.stats.defense * d) + 1)
end
const double_super_effective = 15625
const super_effective = 25000
const neutral = 40000
const resisted = 64000
const double_resisted = 102400
const triple_resisted = 163840

get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: immunities[Tₐ], T₂ <: resistivities[Tₐ]}    = triple_resisted
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: resistivities[Tₐ], T₂ <: immunities[Tₐ]}    = triple_resisted
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: resistivities[Tₐ], T₂ <: resistivities[Tₐ]} = double_resisted
get_eff(move::Move{Tₐ}, defender::StaticPokemon{PokemonType, T₂}) where 
    {Tₐ <: PokemonType, T₂ <: resistivities[Tₐ]}                          = resisted
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, PokemonType}) where 
    {Tₐ <: PokemonType, T₁ <: resistivities[Tₐ]}                          = resisted
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: immunities[Tₐ], T₂ <: effectivities[Tₐ]}    = resisted
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: effectivities[Tₐ], T₂ <: immunities[Tₐ]}    = resisted
get_eff(move::Move, defender::StaticPokemon)                              = neutral
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: resistivities[Tₐ], T₂ <: effectivities[Tₐ]} = neutral
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: effectivities[Tₐ], T₂ <: resistivities[Tₐ]} = neutral
get_eff(move::Move{Tₐ}, defender::StaticPokemon{PokemonType, T₂}) where 
    {Tₐ <: PokemonType, T₂ <: effectivities[Tₐ]}                          = super_effective
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, PokemonType}) where 
    {Tₐ <: PokemonType, T₁ <: effectivities[Tₐ]}                          = super_effective
get_eff(move::Move{Tₐ}, defender::StaticPokemon{T₁, T₂}) where 
    {Tₐ <: PokemonType, T₁ <: effectivities[Tₐ], T₂ <: effectivities[Tₐ]} = double_super_effective

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
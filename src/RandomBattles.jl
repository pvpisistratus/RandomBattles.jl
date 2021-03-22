module RandomBattles

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
      @eval Base.Experimental.@optlevel 3
end

# grab data and Pokemon structs so that it can be used
include("data.jl")
include("stats.jl")
include("moves.jl")
include("pokemon.jl")

# team battles
include("team/team.jl")
include("team/state.jl")
include("team/mechanics.jl")
include("team/battle_logic.jl")
include("team/diff.jl")

# individual battles
include("individual/individual.jl")
include("individual/state.jl")
include("individual/mechanics.jl")
include("individual/battle_logic.jl")
include("individual/diff.jl")

# higher level abstractions
include("strategy.jl")
include("pokemon_meta.jl")
include("rankings.jl")
include("nash.jl")

# export useful variables and functions
export DynamicState, StaticState, DynamicTeam, StaticTeam, DynamicPokemon, StaticPokemon,
      DynamicIndividualState, StaticIndividualState, DynamicIndividual, StaticIndividual,
      get_possible_decisions, get_battle_score, get_battle_scores, play_turn, play_battle,
      gamemaster, greatRankings, ultraRankings, masterRankings, diff, Strategy, plot_strategy,
      rank, PokemonMeta, SM, solve_battle

end # module

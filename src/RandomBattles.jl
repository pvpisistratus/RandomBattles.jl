module RandomBattles

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
      @eval Base.Experimental.@optlevel 3
end

# grab data and Pokemon structs so that it can be used
include("data.jl")
include("stats.jl")
include("moves.jl")

# team battles
include("team/pokemon.jl")
include("team/team.jl")
include("team/state.jl")
include("team/mechanics.jl")
include("team/decisions.jl")
include("team/battle_logic.jl")
include("team/diff.jl")
include("team/strategy.jl")
include("team/nash.jl")
#include("team/alpha_beta_pruning.jl")

# individual battles
include("individual/pokemon.jl")
include("individual/state.jl")
include("individual/mechanics.jl")
include("individual/decisions.jl")
include("individual/battle_logic.jl")
include("individual/diff.jl")
include("individual/nash.jl")

# higher level abstractions
include("pokemon_meta.jl")
include("rankings.jl")

# export useful variables and functions
export DynamicState, StaticState, DynamicTeam, StaticTeam, DynamicPokemon, StaticPokemon,
      DynamicIndividualState, StaticIndividualState, DynamicIndividual, StaticIndividual,
      get_possible_decisions, get_battle_score, get_battle_scores, play_turn, play_battle,
      gamemaster, greatRankings, ultraRankings, masterRankings, diff, Strategy, plot_strategy,
      rank, PokemonMeta, SM, solve_battle

end # module

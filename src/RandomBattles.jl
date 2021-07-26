module RandomBattles

if isdefined(Base, :Experimental) && isdefined(Base.Experimental,
      Symbol("@optlevel"))
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
include("team/mcts.jl")
#include("team/alpha_beta_pruning.jl")

# individual battles
include("individual/state.jl")
include("individual/mechanics.jl")
include("individual/decisions.jl")
include("individual/battle_logic.jl")
#include("individual/diff.jl")
include("individual/strategy.jl")
include("individual/nash.jl")

# higher level abstractions
include("pokemon_meta.jl")
include("rankings.jl")

# export useful variables and functions
export DynamicState, StaticState, DynamicTeam, StaticTeam, DynamicPokemon,
      StaticPokemon, DynamicIndividualState, StaticIndividualState,
      get_possible_decisions, battle_score, battle_scores, play_turn,
      play_battle, gamemaster,
      diff, reflect,
      Strategy, IndividualStrategy, plot_strategy, rank,
      PokemonMeta,
      SM, solve_battle,
      MCTSNode, update_tree_MCTS!, select_decisions_MCTS

end # module

module RandomBattles

include("data.jl")
include("pokemon.jl")
include("decision.jl")

include("team/team.jl")
include("team/state.jl")
include("team/mechanics.jl")
include("team/battle_logic.jl")
include("team/diff.jl")

include("individual/individual.jl")
include("individual/state.jl")
include("individual/mechanics.jl")
include("individual/battle_logic.jl")
include("individual/diff.jl")

#include("pokemon_meta.jl")
include("strategy.jl")
#include("rankings.jl")
#include("learning.jl")

export DynamicState, StaticState, DynamicIndividualState, StaticIndividualState
       DynamicTeam, StaticTeam, DynamicIndividual, StaticIndividual,
       DynamicPokemon, StaticPokemon,
       Strategy, plot_strategy,
       get_possible_decisions,
       get_battle_score, get_battle_scores,
       gamemaster, greatRankings, ultraRankings, masterRankings,
       play_turn, play_battle, diff
       #rank, PokemonMeta, vectorize,
       #crossover_and_mutate, play_nn_battle, play_nn_random_battle, testing_best

end # module

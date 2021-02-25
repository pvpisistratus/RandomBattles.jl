module RandomBattles

include("data.jl")
include("pokemon.jl")
include("team.jl")
include("individual.jl")
include("state.jl")
include("individual_battle_state.jl")
include("utility_functions.jl")
include("diff.jl")
include("mechanics.jl")
include("battle_logic.jl")
include("battle_logic_individual.jl")
#include("pokemon_meta.jl")
#include("strategy.jl")
#include("rankings.jl")
#include("learning.jl")

export DynamicState, StaticState, IndividualBattleState,
       DynamicTeam, StaticTeam, Individual,
       DynamicPokemon, StaticPokemon,
       #Strategy, plot_strategy,
       get_possible_decisions,
       get_battle_score, get_battle_scores,
       gamemaster, greatRankings, ultraRankings, masterRankings,
       play_turn, play_battle, diff
       #rank, PokemonMeta, vectorize,
       #crossover_and_mutate, play_nn_battle, play_nn_random_battle, testing_best

end # module

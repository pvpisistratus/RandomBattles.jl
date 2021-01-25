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
include("pokemon_meta.jl")
include("strategy.jl")
include("rankings.jl")
include("learning.jl")

export State,
       IndividualBattleState,
       Team,
       Individual,
       Pokemon,
       Strategy,
       get_possible_decisions,
       get_battle_score,
       get_battle_scores,
       gamemaster,
       greatRankings,
       ultraRankings,
       masterRankings,
       play_turn,
       play_battle,
       rank,
       diff,
       PokemonMeta,
       plot_strategy,
       vectorize,
       crossover_and_mutate,
       play_nn_battle,
       play_nn_random_battle,
       testing_best

end # module

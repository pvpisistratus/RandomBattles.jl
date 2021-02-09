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

export State, IndividualBattleState, Team, Individual, Pokemon, Strategy,
      plot_strategy, get_possible_decisions, play_turn, play_battle,
      get_battle_score, get_battle_scores, rank, PokemonMeta, diff, vectorize,
      gamemaster, greatRankings, ultraRankings, masterRankings

end # module

module RandomBattles

include("data.jl")
include("pokemon.jl")

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

include("strategy.jl")
include("pokemon_meta.jl")
include("rankings.jl")

export DynamicState, StaticState, DynamicTeam, StaticTeam, DynamicPokemon, StaticPokemon,
      DynamicIndividualState, StaticIndividualState, DynamicIndividual, StaticIndividual,
      get_possible_decisions, get_battle_score, get_battle_scores, play_turn, play_battle,
      gamemaster, greatRankings, ultraRankings, masterRankings, diff, Strategy, plot_strategy
      rank, PokemonMeta

end # module

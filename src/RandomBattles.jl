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

export State,
       IndividualBattleState,
       Team,
       Individual,
       Pokemon,
       Strategy,
       get_battle_scores,
       gamemaster,
       greatRankings,
       ultraRankings,
       masterRankings,
       play_battle,
       rank,
       diff,
       PokemonMeta,
       plot_strategy

end # module

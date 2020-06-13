module RandomBattles

include("data.jl")
include("pokemon.jl")
include("team.jl")
include("state.jl")
include("utility_functions.jl")
include("diff.jl")
include("mechanics.jl")
include("battle_logic.jl")
include("strategy.jl")
include("rankings.jl")

export State,
       Team,
       Strategy,
       get_battle_scores,
       gamemaster,
       greatRankings,
       ultraRankings,
       masterRankings,
       play_battle,
       rank,
       diff,
       Meta

end # module

module RandomBattles

include("types.jl")
include("cpm.jl")
include("state.jl")
include("utility_functions.jl")
include("decisions.jl")
include("battle_logic.jl")
include("strategy.jl")
include("rankings.jl")

export State,
       Team,
       Strategy,
       get_battle_scores,
       gamemaster,
       rankings,
       play_battle,
       rank

end # module

module RandomBattles

include("types.jl")
include("cpm.jl")
include("state.jl")
include("utility_functions.jl")
include("decisions.jl")
include("battle_logic.jl")
include("strategy.jl")

export State, Strategy, get_battle_scores, gamemaster, rankings

end # module

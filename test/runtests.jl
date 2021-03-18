using RandomBattles
using Pkg; Pkg.add(PackageSpec(url="https://github.com/aviatesk/JET.jl", rev="master"))
using JET
using Test, BenchmarkTools

@testset "RandomBattles.jl" begin
    static_state1 = StaticState(["lanturn" "dragonair" "froslass" "azumarill" "sableye" "marowak_alolan"])
    dynamic_state1 = DynamicState(static_state1)
    static_state2 = StaticState(["azumarill" "sableye" "marowak_alolan" "lanturn" "dragonair" "froslass"])
    dynamic_state2 = DynamicState(static_state2)
    @test sizeof(static_state1) == 168
    @test isbits(static_state1)
    @test sizeof(dynamic_state1) == 34
    @test isbits(dynamic_state1)
    res = @benchmark play_battle($dynamic_state1, $static_state1)
    @test res.allocs == 0
    N = 10000
    @test sum(get_battle_scores(dynamic_state1, static_state1, N)) +
        sum(get_battle_scores(dynamic_state2, static_state2, N)) ≈ N atol=0.01*N

    report_and_watch_file("data.jl"; annotate_types = true)
    report_and_watch_file("stats.jl"; annotate_types = true)
    report_and_watch_file("moves.jl"; annotate_types = true)
    report_and_watch_file("pokemon.jl"; annotate_types = true)

    # team battles
    report_and_watch_file("team/team.jl"; annotate_types = true)
    report_and_watch_file("team/state.jl"; annotate_types = true)
    report_and_watch_file("team/mechanics.jl"; annotate_types = true)
    report_and_watch_file("team/battle_logic.jl"; annotate_types = true)
    report_and_watch_file("team/diff.jl"; annotate_types = true)

    # individual battles
    report_and_watch_file("individual/individual.jl"; annotate_types = true)
    report_and_watch_file("individual/state.jl"; annotate_types = true)
    report_and_watch_file("individual/mechanics.jl"; annotate_types = true)
    report_and_watch_file("individual/battle_logic.jl"; annotate_types = true)
    report_and_watch_file("individual/diff.jl"; annotate_types = true)

    # higher level abstractions
    report_and_watch_file("strategy.jl"; annotate_types = true)
    report_and_watch_file("pokemon_meta.jl"; annotate_types = true)
    report_and_watch_file("rankings.jl"; annotate_types = true)
end

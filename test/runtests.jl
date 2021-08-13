using RandomBattles
using Test, BenchmarkTools

@testset "RandomBattles.jl" begin
    static_state1 = StaticState(("lanturn", "dragonair", "froslass", "azumarill", "sableye", "marowak_alolan"))
    dynamic_state1 = DynamicState(static_state1)
    static_state2 = StaticState(("azumarill", "sableye", "marowak_alolan", "lanturn", "dragonair", "froslass"))
    dynamic_state2 = DynamicState(static_state2)
    @test sizeof(static_state1) == 168
    @test isbits(static_state1)
    @test sizeof(dynamic_state1) == 20
    @test isbits(dynamic_state1)
    res = @benchmark play_battle($dynamic_state1, $static_state1)
    @test res.allocs == 0
    N = 100000
    @test sum(battle_scores(dynamic_state1, static_state1, N)) +
        sum(battle_scores(dynamic_state2, static_state2, N)) ≈ N atol=0.02*N
end

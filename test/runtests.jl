using RandomBattles
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
    to_benchmark() = play_battle(dynamic_state1, static_state1)
    res = @benchmark to_benchmark()
    @test res.allocs == 0
    N = 10000
    @test sum(get_battle_scores(dynamic_state1, static_state1, N)) +
        sum(get_battle_scores(dynamic_state2, static_state2, N)) ≈ N atol=0.01*N
end

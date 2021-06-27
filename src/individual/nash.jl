using JuMP, GLPK

function SM(state::DynamicIndividualState, static_state::StaticIndividualState, depth::Int64; allow_waiting::Bool = false,
    allow_overfarming::Bool = false, max_depth = 15::Int64, sim_to_end::Bool = false)
    A, B = get_simultaneous_decisions(state, static_state, allow_waiting = allow_waiting, allow_overfarming = allow_overfarming)
    (length(A) == 0 || depth == 0) &&
        return sim_to_end ? NashResult(sum(get_battle_scores(state, static_state, 100) / 100) - 0.5,
        no_strat, no_strat) : NashResult(get_battle_score(state, static_state) - 0.5,
        no_strat, no_strat)
    payoffs = zeros(Float64, length(A), length(B))
    for i in 1:length(A), j in 1:length(B)
        if (5 in B || 7 in B) && !(5 <= B[j] <= 8) && iseven(A[i]) &&
          (5 in A || 7 in A) && !(5 <= A[i] <= 8) && iseven(B[j])
            payoffs[i, j] = payoffs[i - 1, j - 1]
        elseif (5 in B || 7 in B) && !(5 <= B[j] <= 8) && iseven(A[i])
            payoffs[i, j] = payoffs[i - 1, j]
        elseif (5 in A || 7 in A) && !(5 <= A[i] <= 8) && iseven(B[j])
            payoffs[i, j] = payoffs[i, j - 1]
        else
            @inbounds payoffs[i, j] = SM(play_turn(state, static_state, (A[i], B[j])),
                static_state, depth - 1, allow_waiting = allow_waiting, sim_to_end = sim_to_end,
                max_depth = max_depth).payoff
        end
    end
    return nash(payoffs)
end

function solve_battle(s::DynamicIndividualState, static_s::StaticIndividualState, depth::Int64;
  sim_to_end = false)
    value = 0.0
    decision = 0, 0
    #strat = Strategy([], [], [], [])
    while true
        A, B = get_simultaneous_decisions(s, static_s)
        (length(A) == 0 || length(B) == 0) && return value
        if length(A) == 1 && length(B) == 1
            decision = A[1], B[1]
        else
            value, strategy1, strategy2 = SM(s, static_s, depth, max_depth = depth, sim_to_end = sim_to_end)
            d1, d2 = rand(), rand()
            decision1, decision2 = length(strategy1), length(strategy2)
            j = 0.0
            for i = 1:length(strategy1)-1
                @inbounds j += strategy1[i]
                if d1 < j
                    decision1 = i
                    break
                end
            end
            j = 0.0
            for i = 1:length(strategy2)-1
                @inbounds j += strategy2[i]
                if d2 < j
                    decision2 = i
                    break
                end
            end
            decision = A[decision1], B[decision2]
        end
        println("$(value): $(decision)")
        s = play_turn(s, static_s, decision)
        #push!(strat.decisions, decision)
        #push!(strat.scores, value + 0.5)
        #push!(strat.energies, (s.teams[1].mons[s.teams[1].active].energy,
        #    s.teams[2].mons[s.teams[2].active].energy))
        #push!(strat.activeMons, (s.teams[1].active, s.teams[2].active))
    end
end

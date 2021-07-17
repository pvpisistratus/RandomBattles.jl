using JuMP, GLPK

function get_α(P::Matrix{Float64}, e::Vector{Float64}, f::Vector{Float64})
    # Set up model and payoff
    model = direct_model(GLPK.Optimizer())
    @variable(model, z)
    @objective(model, Max, 1.0 * z)

    @variable(model, x[1:length(e)], lower_bound = 0.0)
    @constraint(model, sum(x) == 1.0)
    @constraint(model, x' * P .>= f)
    @constraint(model, x' * e .>= z)

    optimize!(model)
    return JuMP.value(z)
end

function get_β(O::Matrix{Float64}, e::Vector{Float64}, f::Vector{Float64})
    # Set up model and payoff
    model = direct_model(GLPK.Optimizer())
    @variable(model, z)
    @objective(model, Min, 1.0 * z)

    @variable(model, x[1:length(e)], lower_bound = 0.0)
    @constraint(model, sum(x) == 1.0)
    @constraint(model, O * x .<= f)
    @constraint(model, e * x' .<= z)

    optimize!(model)
    return JuMP.objective_value(model)
end

function SMAB(state::DynamicState, static_state::StaticState, α₀::Float64,
  β₀::Float64, depth::Int64; allow_waiting::Bool = false, sim_to_end::Bool = false, ϵ = 0.001)
    A, B = get_simultaneous_decisions(state, static_state, allow_waiting = allow_waiting)
    (length(A) == 0 || depth == 0) &&
        return sim_to_end ? NashResult(sum(battle_scores(state, static_state, 100) / 100) - 0.5,
        no_strat, no_strat) : NashResult(get_battle_score(state, static_state) - 0.5,
        no_strat, no_strat)

    Q = [play_turn(state, static_state, (a, b)) for a in A, b in B]
    P = vcat(map(q -> get_min_score(q, static_state), Q), repeat([α₀], 1, length(B)))
    O = hcat(map(q -> get_max_score(q, static_state), Q), repeat([β₀], length(A), 1))
    non_dominated_rows = trues(length(A) + 1)
    non_dominated_columns = trues(length(B))
    non_dominated_rows[end] = false

    for i in 1:length(A), j in 1:length(B)
        if non_dominated_rows[i] && non_dominated_columns[j]
            @inbounds if (5 in B || 7 in B) && !(5 <= B[j] <= 8) && iseven(A[i]) &&
              (5 in A || 7 in A) && !(5 <= A[i] <= 8) && iseven(B[j])
                @inbounds P[i, j] = P[i - 1, j - 1]
                @inbounds O[i, j] = O[i - 1, j - 1]
            elseif @inbounds (5 in B || 7 in B) && !(5 <= B[j] <= 8) && iseven(A[i])
                @inbounds P[i, j] = P[i - 1, j]
                @inbounds O[i, j] = O[i - 1, j]
            elseif @inbounds (5 in A || 7 in A) && !(5 <= A[i] <= 8) && iseven(B[j])
                @inbounds P[i, j] = P[i, j - 1]
                @inbounds O[i, j] = O[i, j - 1]
            else
                α = get_α(P[1:end .!= i, 1:end .!= j], P[1:end .!= i, j], O[i, 1:end-1 .!= j])
                β = get_β(O[1:end .!= i, 1:end .!= j], O[i, 1:end .!= j], P[1:end-1 .!= i, j])
                if α < β
                    @inbounds v = SMAB(Q[i, j], static_state, α, β, depth - 1,
                        allow_waiting = allow_waiting, sim_to_end = sim_to_end).payoff
                    if v <= α
                        @inbounds non_dominated_rows[i] = false
                    elseif v >= β
                        @inbounds non_dominated_columns[j] = false
                    else
                        P[i, j] = O[i, j] = v
                    end
                else
                    @inbounds v = SMAB(Q[i, j], static_state, α, α + ϵ, depth - 1,
                        allow_waiting = allow_waiting, sim_to_end = sim_to_end).payoff
                    if v <= α
                        @inbounds non_dominated_rows[i] = false
                    else
                        @inbounds non_dominated_columns[j] = false
                    end
                end
            end
        end
    end
    return nash(P[non_dominated_rows, non_dominated_columns])
end

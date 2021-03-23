using JuMP, GLPK

function get_simultaneous_decisions(state::DynamicState, static_state::StaticState;
  allow_waiting::Bool = false)
    decisions1 = findall(x -> x != 0.0, get_possible_decisions(state, static_state, 1,
        allow_nothing = allow_waiting))
    length(decisions1) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    decisions2 = findall(x -> x != 0.0, get_possible_decisions(state, static_state, 2,
        allow_nothing = allow_waiting))
    length(decisions2) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    !(5 in decisions1 || 7 in decisions1) && filter!(isodd, decisions2)
    !(5 in decisions2 || 7 in decisions2) && filter!(isodd, decisions1)
    return decisions1, decisions2
end

function get_simultaneous_decisions(state::DynamicIndividualState, static_state::StaticIndividualState;
        allow_waiting::Bool = false, allow_overfarming::Bool = false)
    decisions1 = findall(x -> x > 0, RandomBattles.get_possible_decisions(state, static_state, 1,
        allow_nothing = allow_waiting, allow_overfarming = allow_overfarming))
    length(decisions1) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    decisions2 = findall(x -> x > 0, RandomBattles.get_possible_decisions(state, static_state, 2,
        allow_nothing = allow_waiting))
    length(decisions2) == 0 && return Array{Int64}(undef, 0), Array{Int64}(undef, 0)
    !(5 in decisions1 || 7 in decisions1) && filter!(isodd, decisions2)
    !(5 in decisions2 || 7 in decisions2) && filter!(isodd, decisions1)
    return decisions1, decisions2
end

function strat_vec(l::Int64, i::Int64)
    vec_to_return = vec(zeros(l))
    @inbounds vec_to_return[i] = 1.0
    return vec_to_return
end

minmax(R::Array{Float64, 2}, m::Int64) = @inbounds mapreduce(x -> maximum(R[:, x]), min, 1:m)
maxmin(R::Array{Float64, 2}, n::Int64) = @inbounds mapreduce(x -> minimum(R[x, :]), max, 1:n)
findminmax(R::Array{Float64, 2}, n::Int64) = @inbounds strat_vec(n, argmax(map(x -> minimum(R[x, :]), 1:n)))
findmaxmin(R::Array{Float64, 2}, m::Int64) = @inbounds strat_vec(m, argmin(map(x -> maximum(R[:, x]), 1:m)))

function nash(R::Matrix{Float64})
    n, m = size(R)

    # Check if we have to do linear programming
    n == 1 && return minimum(R), vec([1.0]), strat_vec(m, argmin(vec(R)))
    m == 1 && return maximum(R), strat_vec(n, argmin(vec(R))), vec([1.0])
    minmax(R, m) == maxmin(R, n) && return minmax(R, m), findminmax(R, n), findmaxmin(R, m)
    @inbounds n == 2 && m == 2 && return ((P[1,1] * P[2,2] - P[1,2] * P[2,1]) / (P[1,1] + P[2,2] - P[1,2] - P[2,1])),
        [(P[2, 2] - P[2, 1])/(P[1, 1] + P[2, 2] - P[1, 2] - P[2, 1]),
        ((P[1, 1] + P[2, 2]) - P[1, 2] - P[2, 1] - P[2, 2] + P[2, 1])/((P[1, 1] + P[2, 2]) - P[1, 2] - P[2, 1])],
        [(P[2, 2] - P[1, 2])/(P[1, 1] + P[2, 2] - P[1, 2] - P[2, 1]),
        ((P[1, 1] + P[2, 2]) - P[1, 2] - P[2, 1] - P[2, 2] + P[1, 2])/((P[1, 1] + P[2, 2]) - P[1, 2] - P[2, 1])]

    # Set up model and payoff
    model = direct_model(GLPK.Optimizer())
    @variable(model, z)
    @objective(model, Max, 1.0 * z)

    # Solve for row player
    @variable(model, x[1:n], lower_bound = 0.0)
    @constraint(model, c1, x' * R .>= z)
    @constraint(model, sum(x) == 1.0)

    optimize!(model)

    return JuMP.value(z), JuMP.value.(x), shadow_price.(c1)
end

function SM(state::DynamicState, static_state::StaticState, depth::Int64; allow_waiting = false,
  max_depth = 15, sim_to_end = false)
    A, B = get_simultaneous_decisions(state, static_state, allow_waiting = allow_waiting)
    (length(A) == 0 || depth == 0) &&
        return sim_to_end ? (sum(get_battle_scores(state, static_state, 100) / 100) - 0.5,
        vec([1.0]), vec([1.0])) : (get_battle_score(state, static_state) - 0.5,
        vec([1.0]), vec([1.0]))
    payoffs = zeros(Float64, length(A), length(B))
    for i in 1:length(A), j in 1:length(B)
        @inbounds if (5 in B || 7 in B) && !(5 <= B[j] <= 8) && iseven(A[i]) &&
          (5 in A || 7 in A) && !(5 <= A[i] <= 8) && iseven(B[j])
            @inbounds payoffs[i, j] = payoffs[i - 1, j - 1]
        elseif @inbounds (5 in B || 7 in B) && !(5 <= B[j] <= 8) && iseven(A[i])
            @inbounds payoffs[i, j] = payoffs[i - 1, j]
        elseif @inbounds (5 in A || 7 in A) && !(5 <= A[i] <= 8) && iseven(B[j])
            @inbounds payoffs[i, j] = payoffs[i, j - 1]
        else
            @inbounds payoffs[i, j] = SM(play_turn(state, static_state, (A[i], B[j])),
                static_state, depth - 1, allow_waiting = allow_waiting, sim_to_end = sim_to_end,
                max_depth = max_depth)[1]
        end
    end
    return nash(payoffs)
end

function SM(state::DynamicIndividualState, static_state::StaticIndividualState, depth::Int64; allow_waiting = false,
    allow_overfarming = false, max_depth = 15, sim_to_end = false)
    A, B = get_simultaneous_decisions(state, static_state, allow_waiting = allow_waiting, allow_overfarming = allow_overfarming)
    (length(A) == 0 || depth == 0) &&
        return sim_to_end ? (sum(get_battle_scores(state, static_state, 100) / 100) - 0.5,
        vec([1.0]), vec([1.0])) : (get_battle_score(state, static_state) - 0.5,
        vec([1.0]), vec([1.0]))
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
                max_depth = max_depth)[1]
        end
    end
    return nash(payoffs)
end

function solve_battle(s::DynamicState, static_s::StaticState, depth::Int64; sim_to_end = false)
    value = 0.0
    decision = 0, 0
    strat = Strategy([], [], [], [])
    while true
        A, B = get_simultaneous_decisions(s, static_s)
        (length(A) == 0 || length(B) == 0) && return value, strat
        if length(A) == 1 && length(B) == 1
            decision = A[1], B[1]
        else
            value, strategy1, strategy2 = SM(s, static_s, depth, max_depth = depth, sim_to_end = sim_to_end)
            d1, d2 = rand(), rand()
            decision1, decision2 = 0, 0
            j = 0.0
            for i = 1:length(strategy1)
                @inbounds j += strategy1[i]
                if d1 < j
                    decision1 = i
                    break
                end
            end
            j = 0.0
            for i = 1:length(strategy2)
                @inbounds j += strategy2[i]
                if d2 < j
                    decision2 = i
                    break
                end
            end
            decision = A[decision1], B[decision2]
        end
        s = play_turn(s, static_s, decision)
        push!(strat.decisions, decision)
        push!(strat.scores, value + 0.5)
        push!(strat.energies, (s.teams[1].mons[s.teams[1].active].energy,
            s.teams[2].mons[s.teams[2].active].energy))
        push!(strat.activeMons, (s.teams[1].active, s.teams[2].active))
    end
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
            decision1, decision2 = 0, 0
            j = 0.0
            for i = 1:length(strategy1)
                @inbounds j += strategy1[i]
                if d1 < j
                    decision1 = i
                    break
                end
            end
            j = 0.0
            for i = 1:length(strategy2)
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

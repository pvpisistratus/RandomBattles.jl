mutable struct DecisionMatrix
    decision_matrix::Array{Tuple{Float64, Float64}, 2}
end

DecisionMatrix() = DecisionMatrix([
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
    (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0) (
        0.0,
        0.0,
    ) (0.0, 0.0) (0.0, 0.0) (0.0, 0.0)
])

function DecisionMatrix(state)
    finished = false
    d_matrix = decision_matrix()
    decisions1 = get_possible_decisions(state)
    if decisions1 == []
        finished = true
    else
        for decision1 in decisions1
            next_state = play_decision(state, decision1)
            decisions2 = get_possible_decisions(next_state)
            if decisions2 == []
                finished = true
                score = get_battle_score(next_state)
                d_matrix.decision_matrix[decision1, :] .= (score, score)
            else
                for decision2 in decisions2
                    next_next_state = play_decision(next_state, decision2)
                    scores = get_battle_scores(next_next_state, 1000)
                    d_matrix.decision_matrix[
                        decision1,
                        decision2,
                    ] = minimum(scores)
                    d_matrix.decision_matrix[
                        decision1,
                        decision2,
                    ] = maximum(scores)
                end
            end
        end
    end
    return d_matrix, finished
end

function minimax(dmat::DecisionMatrix)
    mins = ones(20)
    for i = 1:20, j = 1:20
        if dmat.decision_matrix[i, j].first < mins[i]
            mins[i] = dmat.decision_matrix[i, j].first
        end
    end
    minimax = argmax(mins)
    maxes = zeros(20)
    for i = 1:20, j = 1:20
        if dmat.decision_matrix[i, j].second > maxes[j]
            maxes[j] = dmat.decision_matrix[i, j].second
        end
    end
    replace!(maxes, 0.0=>1.0)
    maximin = argmin(maxes)
    return (minimax, maximin)
end

function is_empty(dmat::DecisionMatrix)
    return dmat.decision_matrix == DecisionMatrix().decision_matrix
end

mutable struct Strategy
    decisions::Array{Tuple{Int64, Int64}}
    minimaxes::Array{Tuple{Float64, Float64}}
    history::Array{State}
end

Strategy() = Strategy([], [], [])

function Strategy(state)
    strategy = Strategy()
    finished = false
    current_state = state
    while !finished
        d_matrix, finished = DecisionMatrix(current_state)
        if !is_empty(d_matrix)
            decision = minimax(d_matrix)
            push!(strategy.decisions, decision)
            push!(
                strategy.minimaxes,
                d_matrix.decision_matrix[decision.first.decision.second],
            )
            current_state = play_decision(current_state, decision.first)
            current_state = play_decision(current_state, decision.second)
        end
        push!(strategy.history, current_state)
    end
    return strategy
end

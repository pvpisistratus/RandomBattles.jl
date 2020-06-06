mutable struct DecisionMatrix
    decision_matrix::Array{Tuple{Float64,Float64},2}
end

function DecisionMatrix()
    dmat = Array{Tuple{Float64,Float64}}(
        undef,
        possible_decisions,
        possible_decisions,
    )
    for i = 1:possible_decisions, j = 1:possible_decisions
        dmat[i, j] = (1.0, 0.0)
    end
    return DecisionMatrix(dmat)
end

function get_decision_matrix(state)
    finished = false
    d_matrix = DecisionMatrix()
    decisions1 = get_possible_decisions(state)
    if sum(decisions1) == 0
        finished = true
    else
        for decision1 in findall(isone, decisions1)
            next_state = play_decision(state, decision1)
            next_state = @set next_state.agent = get_other_agent(next_state.agent)
            decisions2 = get_possible_decisions(next_state)
            if sum(decisions2) == 0
                finished = true
                score = get_battle_score(next_state)
                d_row = Array{Tuple{Float64,Float64}}(undef, possible_decisions)
                for i = 1:possible_decisions
                    d_row[i] = (score, score)
                end
                d_matrix.decision_matrix[decision1, :] = d_row
            else
                for decision2 in findall(isone, decisions2)
                    next_next_state = play_decision(next_state, decision1)
                    next_next_state = @set next_next_state.agent = get_other_agent(next_next_state.agent)
                    next_next_state = evaluate_charged_moves(next_next_state)
                    next_next_state = reset_charged_moves_pending(next_next_state)
                    next_next_state = evaluate_switches(next_next_state)
                    next_next_state = reset_switches_pending(next_next_state)
                    next_next_state = step_timers(next_next_state)
                    scores = get_battle_scores(next_next_state, 1000)
                    d_matrix.decision_matrix[decision1, decision2] = (
                        minimum(scores),
                        maximum(scores),
                    )
                end
            end
        end
    end
    return d_matrix, finished
end

function minimax(dmat::DecisionMatrix)
    mins = ones(possible_decisions)
    for i = 1:possible_decisions, j = 1:possible_decisions
        if first(dmat.decision_matrix[i, j]) < mins[i]
            mins[i] = first(dmat.decision_matrix[i, j])
        end
    end
    minimax = argmax(mins)
    maxes = zeros(possible_decisions)
    for i = 1:possible_decisions, j = 1:possible_decisions
        if last(dmat.decision_matrix[i, j]) > maxes[j]
            maxes[j] = last(dmat.decision_matrix[i, j])
        end
    end
    replace!(maxes, 0.0 => 1.0)
    maximin = argmin(maxes)
    return (minimax, maximin)
end

function is_empty(dmat::DecisionMatrix)
    return dmat.decision_matrix == DecisionMatrix().decision_matrix
end

mutable struct Strategy
    decisions::Array{Tuple{Int64,Int64}}
    minimaxes::Array{Tuple{Float64,Float64}}
    history::Array{State}
end

Strategy() = Strategy([], [], [])

function Strategy(state)
    strategy = Strategy()
    finished = false
    current_state = state
    while !finished
        print(" ")
        d_matrix, finished = get_decision_matrix(current_state)
        if !is_empty(d_matrix)
            decision = minimax(d_matrix)
            push!(strategy.decisions, decision)
            print(decision)
            push!(
                strategy.minimaxes,
                d_matrix.decision_matrix[first(decision), last(decision)],
            )
            current_state = play_decision(current_state, first(decision))
            current_state = play_decision(current_state, last(decision))
        end
        push!(strategy.history, current_state)
    end
    return strategy
end

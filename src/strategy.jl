using Distributions

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

function get_decision_matrix(
    state;
    battles_per_turn = 1000,
    perfect_information = true,
    active_mons::Array{Tuple{Int64, Int64}} = Array{Tuple{Int64, Int64}}(undef, 0),
    meta::Array{Pokemon, 1} = Array{Pokemon}(undef, 0),
    weights::Array{Int64, 1} = Array{Int64}(undef, 0)
)
    d_matrix = DecisionMatrix()
    weights1 = get_possible_decisions(state)
    weights2 = get_possible_decisions(switch_agent(state))
    if perfect_information
        if !iszero(sum(weights1)) && !iszero(sum(weights2))
            for d1 in findall(isone, weights1), d2 in findall(isone, weights2)
                next_state = play_turn(state, (d1, d2))
                scores = get_battle_scores(next_state, battles_per_turn)
                d_matrix.decision_matrix[d1, d2] = (mean(scores) - 3 * std(scores), mean(scores) + 3 * std(scores))
            end
        end
    else
        if !iszero(sum(weights1)) && !iszero(sum(weights2))
            for d1 in findall(isone, weights1), d2 in findall(isone, weights2)
                next_state = play_turn(state, (d1, d2))
                scores1::Array{Float64} = []
                scores2::Array{Float64} = []
                for i = 1:battles_per_turn
                    modified_state1 = next_state
                    modified_state2 = next_state

                    if !(2 in first.(active_mons))
                        modified_state2 = @set modified_state2.teams[1].mons[2] = meta[rand(Categorical(weights ./ sum(weights)))]
                    end
                    if !(3 in first.(active_mons))
                        modified_state2 = @set modified_state2.teams[1].mons[3] = meta[rand(Categorical(weights ./ sum(weights)))]
                    end
                    push!(scores2, play_battle(modified_state2))

                    if !(2 in last.(active_mons))
                        modified_state1 = @set modified_state1.teams[2].mons[2] = meta[rand(Categorical(weights ./ sum(weights)))]
                    end
                    if !(3 in last.(active_mons))
                        modified_state1 = @set modified_state1.teams[2].mons[3] = meta[rand(Categorical(weights ./ sum(weights)))]
                    end
                    push!(scores1, play_battle(modified_state1))
                end
                d_matrix.decision_matrix[d1, d2] = (mean(scores1) - 3 * std(scores1), mean(scores2) + 3 * std(scores2))
            end
        end
    end
    return d_matrix
end

function minimax(dmat::DecisionMatrix)
    mins = ones(possible_decisions)
    for i = 1:possible_decisions, j = 1:possible_decisions
        if first(dmat.decision_matrix[i, j]) < mins[i]
            mins[i] = first(dmat.decision_matrix[i, j])
        end
    end
    replace!(mins, 1.0 => 0.0)
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
    energies::Array{Tuple{Int8, Int8}}
    activeMons::Array{Tuple{Int64, Int64}}
end

function Strategy(
    state::State;
    battles_per_turn::Int64 = 1000,
    perfect_information::Bool = true,
    meta::Array{Pokemon, 1} = Array{Pokemon}(undef, 0),
    weights::Array{Int64, 1} = Array{Int64}(undef, 0),
)
    strategy = Strategy(
        Array{Tuple{Int64,Int64}}(undef, 0),
        Array{Tuple{Float64,Float64}}(undef, 0),
        Array{Tuple{Int8, Int8}}(undef, 0),
        Array{Tuple{Int64, Int64}}(undef, 0)
    )
    current_state = state
    while true
        if perfect_information
            d_matrix = get_decision_matrix(current_state, battles_per_turn = battles_per_turn)
        else
            d_matrix = get_decision_matrix(current_state, perfect_information = perfect_information, battles_per_turn = battles_per_turn, active_mons = strategy.activeMons, meta = meta, weights = weights)
        end
        is_empty(d_matrix) && return strategy
        decision = minimax(d_matrix)
        push!(strategy.decisions, decision)
        push!(
            strategy.minimaxes,
            d_matrix.decision_matrix[decision[1], decision[2]],
        )
        current_state = play_turn(current_state, decision)
        push!(
            strategy.energies,
            (current_state.teams[1].mons[current_state.teams[1].active].energy,
            current_state.teams[2].mons[current_state.teams[2].active].energy)
        )
        push!(
            strategy.activeMons,
            (current_state.teams[1].active, current_state.teams[2].active)
        )
    end
end

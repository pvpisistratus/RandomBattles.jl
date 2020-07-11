using Distributions, Plots, Match

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
    meta::PokemonMeta = PokemonMeta()
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
                        modified_state2 = @set modified_state2.teams[1].mons[2] = meta.pokemon[rand(meta.weights)]
                    end
                    if !(3 in first.(active_mons))
                        modified_state2 = @set modified_state2.teams[1].mons[3] = meta.pokemon[rand(meta.weights)]
                    end
                    push!(scores2, play_battle(modified_state2))

                    if !(2 in last.(active_mons))
                        modified_state1 = @set modified_state1.teams[2].mons[2] = meta.pokemon[rand(meta.weights)]
                    end
                    if !(3 in last.(active_mons))
                        modified_state1 = @set modified_state1.teams[2].mons[3] = meta.pokemon[rand(meta.weights)]
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
    state::BattleState;
    battles_per_turn::Int64 = 1000,
    perfect_information::Bool = true,
    meta::PokemonMeta = PokemonMeta(),
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
            d_matrix = get_decision_matrix(current_state, perfect_information = perfect_information, battles_per_turn = battles_per_turn, active_mons = strategy.activeMons, meta = meta)
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

function plot_strategy(strat::Strategy, s::BattleState)
    gr()
    plt1 = plot(1:length(strat.minimaxes), mean.(strat.minimaxes), width = 2, label = "possible battle scores", fillalpha = 0.2, ribbon = (mean.(strat.minimaxes) .- first.(strat.minimaxes), last.(strat.minimaxes) .- mean.(strat.minimaxes)), ylims = [0, 1], ylabel = "Battle Score", xlabel = "Decisions", size = (950, 400))
    hline!(plt1, [0.5], label = "win/loss")
    plt2 = plot(xlims = [0, length(strat.decisions)], ylims = [-3, 0], legend = false, size = (950, 200), axis = nothing)
    shields = [s.teams[1].shields, s.teams[2].shields]
    for i = 1:length(strat.decisions), j = 1:2
        @match strat.decisions[i][j] begin
            3  || 4  => begin
                color = RandomBattles.colors[s.teams[j].mons[strat.activeMons[i][j]].fastMove.moveType]
                scatter!(plt2, [i], [-j], markershape = :square, alpha = 0.5, color = color)
            end
            5  || 6  => begin
                color = RandomBattles.colors[s.teams[j].mons[strat.activeMons[i][j]].chargedMoves[1].moveType]
                if strat.energies[i][j] < strat.energies[i - 1][j]
                    scatter!(plt2, [i], [-j], markershape = :circle, markersize = 10, alpha = 0.5, color = color)
                    other_agent = RandomBattles.get_other_agent(j)
                    if shields[other_agent] > 0 && iseven(strat.decisions[i][other_agent])
                        scatter!(plt2, [i], [-other_agent], markershape = :hexagon, markersize = 12, alpha = 0.5, color = RandomBattles.shieldColor)
                        shields[other_agent] -= 1
                    end
                end
            end
            7  || 8  => begin
                color = RandomBattles.colors[s.teams[j].mons[strat.activeMons[i][j]].chargedMoves[2].moveType]
                if strat.energies[i][j] < strat.energies[i - 1][j]
                    scatter!(plt2, [i], [-j], markershape = :circle, markersize = 10, alpha = 0.5, color = color)
                    other_agent = RandomBattles.get_other_agent(j)
                    if shields[other_agent] > 0 && iseven(strat.decisions[i][other_agent])
                        scatter!(plt2, [i], [-other_agent], markershape = :hexagon, markersize = 12, alpha = 0.5, color = RandomBattles.shieldColor)
                        shields[other_agent] -= 1
                    end
                end
            end
            9:20     => begin
                if strat.decisions[i][j] >= 15
                    scatter!(plt2, [i - .5], [-j], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
                end
                color = RandomBattles.colors[s.teams[j].mons[strat.activeMons[i][j]].types[1]]
                scatter!(plt2, [i - .25], [-j + .25], markershape = :utriangle, alpha = 0.5, color = color)
                if 1 <= s.teams[j].mons[strat.activeMons[i][j]].types[2] <= 18
                    color = RandomBattles.colors[s.teams[j].mons[strat.activeMons[i][j]].types[2]]
                end
                scatter!(plt2, [i + .25], [-j - .25], markershape = :dtriangle, alpha = 0.5, color = color)
            end
        end
    end
    if mean(strat.minimaxes[length(strat.decisions)]) > 0.5
        scatter!(plt2, [length(strat.decisions)], [-2], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
    elseif mean(strat.minimaxes[length(strat.decisions)]) < 0.5
        scatter!(plt2, [length(strat.decisions)], [-1], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
    else
        scatter!(plt2, [length(strat.decisions)], [-2], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
        scatter!(plt2, [length(strat.decisions)], [-1], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
    end

    l = @layout [a; b{0.2h}]
    plot(plt1, plt2, layout = l, size = (950, 600))
end

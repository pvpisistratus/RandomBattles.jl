using Distributions, Plots

mutable struct Strategy
    decisions::Array{Tuple{Int64,Int64}}
    scores::Array{Float64}
    energies::Array{Tuple{Int8, Int8}}
    activeMons::Array{Tuple{Int8, Int8}}
end

function plot_strategy(strat::Strategy, static_s::StaticState)
    gr()
    plt1 = plot(1:length(strat.scores), strat.scores, width = 2, label = "possible battle scores",
        ylims = [0, 1], ylabel = "Battle Score", xlabel = "Decisions", size = (950, 400))
    hline!(plt1, [0.5], label = "win/loss")
    plt2 = plot(xlims = [0, length(strat.scores)], ylims = [-3, 0], legend = false, size = (950, 200), axis = nothing)
    shields = [Int8(2), Int8(2)]
    for i = 1:length(strat.scores), j = Int8(1):Int8(2)
        if 3 <= strat.decisions[i][j] <= 4
            color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].fastMove.moveType]
            scatter!(plt2, [i], [-j], markershape = :square, alpha = 0.5, color = color)
        elseif 5 <= strat.decisions[i][j] <= 6
            color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].chargedMoves[1].moveType]
            if strat.energies[i][j] < strat.energies[i - 1][j]
                scatter!(plt2, [i], [-j], markershape = :circle, markersize = 10, alpha = 0.5, color = color)
                other_agent = get_other_agent(j)
                if shields[other_agent] > 0 && iseven(strat.decisions[i][other_agent])
                    scatter!(plt2, [i], [-other_agent], markershape = :hexagon, markersize = 12, alpha = 0.5, color = shieldColor)
                    shields[other_agent] -= 1
                end
            end
        elseif 7 <= strat.decisions[i][j] <= 8
            color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].chargedMoves[2].moveType]
            if strat.energies[i][j] < strat.energies[i - 1][j]
                scatter!(plt2, [i], [-j], markershape = :circle, markersize = 10, alpha = 0.5, color = color)
                other_agent = get_other_agent(j)
                if shields[other_agent] > 0 && iseven(strat.decisions[i][other_agent])
                    scatter!(plt2, [i], [-other_agent], markershape = :hexagon, markersize = 12, alpha = 0.5, color = shieldColor)
                    shields[other_agent] -= 1
                end
            end
        elseif 9 <= strat.decisions[i][j] <= 20
            if strat.decisions[i][j] >= 15
                scatter!(plt2, [i - .5], [-j], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
            end
            color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].types[1]]
            scatter!(plt2, [i - .25], [-j + .25], markershape = :utriangle, alpha = 0.5, color = color)
            if 1 <= static_s.teams[j].mons[strat.activeMons[i][j]].types[2] <= 18
                color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].types[2]]
            end
            scatter!(plt2, [i + .25], [-j - .25], markershape = :dtriangle, alpha = 0.5, color = color)
        end
    end
    if strat.scores[end] > 0.5
        scatter!(plt2, [length(strat.scores)], [-2], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
    elseif strat.scores[end] < 0.5
        scatter!(plt2, [length(strat.scores)], [-1], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
    else
        scatter!(plt2, [length(strat.scores)], [-2], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
        scatter!(plt2, [length(strat.scores)], [-1], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
    end

    l = @layout [a; b{0.2h}]
    plot(plt1, plt2, layout = l, size = (950, 600))
end

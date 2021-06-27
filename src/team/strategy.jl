using Plots

"""
    Strategy(decisions, scores, energies, activeMons)

Struct for information about an entire match and the strategy used throughout.
This includes the decisions made, the scores at each point along the battle,
the energies of the mons (to determine fast and charged move applications), and
the active mons used by each team.
"""
mutable struct Strategy
    decisions::Array{Tuple{UInt8,UInt8}}
    scores::Array{Float64}
    hps::Array{Tuple{Tuple{UInt16, UInt16, UInt16}, Tuple{UInt16, UInt16, UInt16}}}
    activeMons::Array{Tuple{UInt16, UInt16}}
end

"""
    plot_strategy(strat, static_s)

Given the Strategy and the StaticState, plot the battle using a PvPoke-like
notation.
"""
function plot_strategy(strat::Strategy, static_s::StaticState)
    gr()
    plt1 = plot(1:length(strat.scores), strat.scores, width = 2, label = "possible battle scores",
        ylims = [0, 1], ylabel = "Battle Score", xlabel = "Decisions", size = (950, 400))
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][1][1], 1:length(strat.scores)) ./
        static_s.teams[1].mons[1].stats.hitpoints, color = :green, label = "")
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][1][2], 1:length(strat.scores)) ./
        static_s.teams[1].mons[2].stats.hitpoints, color = :green, label = "")
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][1][3], 1:length(strat.scores)) ./
        static_s.teams[1].mons[3].stats.hitpoints, color = :green, label = "")
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][2][1], 1:length(strat.scores)) ./
        static_s.teams[2].mons[1].stats.hitpoints, color = :purple, label = "")
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][2][2], 1:length(strat.scores)) ./
        static_s.teams[2].mons[2].stats.hitpoints, color = :purple, label = "")
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][2][3], 1:length(strat.scores)) ./
        static_s.teams[2].mons[3].stats.hitpoints, color = :purple, label = "")
    hline!(plt1, [0.5], label = "win/loss")
    plt2 = plot(xlims = [0, length(strat.scores)], ylims = [-3, 0], legend = false, size = (950, 200), axis = nothing)
    for i = 1:length(strat.scores), j = Int8(1):Int8(2)
        if strat.decisions[i][j] == 0x01
            scatter!(plt2, [i], [-j], markershape = :hexagon, markersize = 12, alpha = 0.5, color = shieldColor)
        elseif strat.decisions[i][j] == 0x05 || strat.decisions[i][j] == 0x06
            color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].types[1]]
            scatter!(plt2, [i - .25], [-j + .25], markershape = :utriangle, alpha = 0.5, color = color)
            if 1 <= static_s.teams[j].mons[strat.activeMons[i][j]].types[2] <= 18
                color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].types[2]]
            end
            scatter!(plt2, [i + .25], [-j - .25], markershape = :dtriangle, alpha = 0.5, color = color)
        elseif strat.decisions[i][j] == 0x07 || strat.decisions[i][j] == 0x08
            color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].chargedMoves[strat.decisions[i][j] - 0x06].moveType]
            scatter!(plt2, [i], [-j], markershape = :circle, markersize = 10, alpha = 0.5, color = color)
        elseif i > 1 && sum(strat.hps[i][get_other_agent(j)]) < sum(strat.hps[i - 1][get_other_agent(j)])
            color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].fastMove.moveType]
            scatter!(plt2, [i], [-j], markershape = :square, alpha = 0.5, color = color)
        end
        if i > 1
            if strat.decisions[i][j] != 0x07 && strat.decisions[i][j] != 0x08 &&
                sum(strat.hps[i][get_other_agent(j)]) <
                sum(strat.hps[i - 1][get_other_agent(j)])
                color = colors[static_s.teams[j].mons[strat.activeMons[i][j]].fastMove.moveType]
                scatter!(plt2, [i], [-j], markershape = :square, alpha = 0.5, color = color)
            end
            if count(isequal(0x0000), strat.hps[i][get_other_agent(j)]) <
                count(isequal(0x0000), strat.hps[i - 1][get_other_agent(j)])
                scatter!(plt2, [i], [-j], markershape = :xcross, alpha = 0.5, markersize = 10, color = :red)
            end
        end
    end

    l = @layout [a; b{0.2h}]
    plot(plt1, plt2, layout = l, size = (950, 600))
end

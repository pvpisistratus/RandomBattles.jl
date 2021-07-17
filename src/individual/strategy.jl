using Plots

"""
    Strategy(decisions, scores, energies, activeMons)

Struct for information about an entire match and the strategy used throughout.
This includes the decisions made, the scores at each point along the battle,
the energies of the mons (to determine fast and charged move applications), and
the active mons used by each team.
"""
mutable struct IndividualStrategy
    decisions::Array{Tuple{UInt8,UInt8}}
    scores::Array{Float64}
    hps::Array{Tuple{UInt16, UInt16}}
end

"""
    plot_strategy(strat, static_s)

Given the Strategy and the StaticState, plot the battle using a PvPoke-like
notation.
"""
function plot_strategy(strat::IndividualStrategy,
    static_s::StaticIndividualState)
    gr()
    plt1 = plot(1:length(strat.scores), strat.scores, width = 2,
        label = "possible battle scores", ylims = [0, 1],
        ylabel = "Battle Score", xlabel = "Decisions", size = (950, 400))
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][1],
        1:length(strat.scores)) ./ static_s[0x01].stats.hitpoints,
        color = :green, label = "")
    plot!(plt1, 1:length(strat.scores), map(i -> strat.hps[i][2],
        1:length(strat.scores)) ./ static_s[0x02].stats.hitpoints,
        color = :purple, label = "")
    hline!(plt1, [0.5], label = "win/loss")
    plt2 = plot(xlims = [0, length(strat.scores)], ylims = [-3, 0],
        legend = false, size = (950, 200), axis = nothing)
    for i = 1:length(strat.scores), j = 0x01:0x02
        if strat.decisions[i][j] == 0x01
            scatter!(plt2, [i], [-Int64(j)], markershape = :hexagon,
                markersize = 12, alpha = 0.5, color = shieldColor)
        elseif strat.decisions[i][j] == 0x05 || strat.decisions[i][j] == 0x06
            color = colors[static_s[j].chargedMoves[
                strat.decisions[i][j] - 0x04].moveType]
            scatter!(plt2, [i], [-Int64(j)], markershape = :circle,
                markersize = 10, alpha = 0.5, color = color)
        end
        if i > 1
            if strat.decisions[i][j] != 0x05 &&
                strat.decisions[i][j] != 0x06 &&
                strat.hps[i][get_other_agent(j)] <
                strat.hps[i - 1][get_other_agent(j)]
                color = colors[static_s[j].fastMove.moveType]
                scatter!(plt2, [i], [-Int64(j)], markershape = :square,
                    alpha = 0.5, color = color)
            end
            if strat.hps[i][j] == 0x0000
                scatter!(plt2, [i], [-Int64(j)], markershape = :xcross,
                    alpha = 0.5, markersize = 10, color = :red)
            end
        end
    end

    l = @layout [a; b{0.2h}]
    plot(plt1, plt2, layout = l, size = (950, 600))
end

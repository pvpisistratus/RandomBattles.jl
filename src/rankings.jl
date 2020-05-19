using OnlineStats, CSV, ProgressMeter, IterTools, DataFrames

function get_empirical_teams(filename::String; league = "great")
    data = CSV.read(filename)
    numEmpiricalTeams = nrow(data)
    data = hcat(team_count_to_pvpoke.(data[:, 1:3]), data[:, 4])
    rankings = get_rankings(league)
    empiricalTeams = Array{Team}(undef, numEmpiricalTeams)
    for i = 1:numEmpiricalTeams
        if convert_indices(data[i, 1], league = league) != 0 &&
           convert_indices(data[i, 2], league = league) != 0 &&
           convert_indices(data[i, 3], league = league) != 0
            empiricalTeams[i] = Team(
                [data[i, 1] data[i, 2] data[i, 3]],
                league = league,
            )
        else
            @warn "Ignoring team $(data[i, 1]), $(data[i, 2]), $(data[i, 3])"
        end
    end
    weights = data[:, 4]
    i = 1
    while true
        if i > length(empiricalTeams)
            break
        end
        if !isassigned(empiricalTeams, i)
            deleteat!(empiricalTeams, i)
            deleteat!(weights, i)
            i -= 1
        end
        i += 1
    end
    return empiricalTeams, weights
end;

function get_theoretical_teams(numMons::Int64; league = "great")
    theoreticalMons = Array{String}(undef, numMons)
    rankings = get_rankings(league)
    for i = 1:numMons
        theoreticalMons[i] = rankings[i]["speciesId"]
    end
    dexDict = Dict{Int16,Array{Int64,1}}()
    for i = 1:numMons
        @inbounds dex = gamemaster["pokemon"][get_gamemaster_mon_id(theoreticalMons[i],)]["dex"]
        if haskey(dexDict, dex)
            push!(dexDict[dex], i)
        else
            dexDict[dex] = [i]
        end
    end
    dexKeys = collect(keys(dexDict))
    index = 0
    for i = 1:length(dexKeys)
        for j in Iterators.flatten((1:(i-1), (i+1):length(dexKeys)))
            for k = (j+1):length(dexKeys)
                if i != k
                    @inbounds @fastmath toAdd = length(dexDict[dexKeys[i]]) *
                                                length(dexDict[dexKeys[j]]) *
                                                length(dexDict[dexKeys[k]])
                    index += toAdd
                end
            end
        end
    end
    numTheoreticalTeams = index
    theoreticalTeams = Array{Team}(undef, numTheoreticalTeams)
    index = 1
    dexes(x) = dexDict[dexKeys[x]]
    for i = 1:length(dexKeys)
        for j in Iterators.flatten((1:(i-1), (i+1):length(dexKeys)))
            for k = (j+1):length(dexKeys)
                if i != k
                    @inbounds @fastmath toAdd = length(dexDict[dexKeys[i]]) *
                                                length(dexDict[dexKeys[j]]) *
                                                length(dexDict[dexKeys[k]])
                    @inbounds @fastmath theoreticalTeams[index:(index+toAdd-1)] = [Team(
                        [l, m, n],
                        league = league,
                    ) for l in dexes(i), m in dexes(j), n in dexes(k)]
                    index += toAdd
                end
            end
        end
    end
    return theoreticalTeams
end;

function run_empirical_teams(
    theoreticalTeam::Team,
    empiricalTeams::Array{Team},
    weights::Array{Int64},
)
    histogram = Hist(0.0:0.025:1.0)
    @simd for i = 1:length(empiricalTeams)
        @simd for j = 1:weights[i]
            fit!(
                histogram,
                play_battle(State(theoreticalTeam, empiricalTeams[i])),
            )
        end
    end
    return histogram
end;

function run_theoretical_teams(
    theoreticalTeams::Array{Team},
    empiricalTeams::Array{Team},
    weights,
)
    histograms = Array{Hist}(undef, length(theoreticalTeams))
    @showprogress for i = 1:length(theoreticalTeams)
        @inbounds histograms[i] = run_empirical_teams(
            theoreticalTeams[i],
            empiricalTeams,
            weights,
        )
    end
    expected_wins = get_expected_win.(histograms, sum(weights))
    expected_battle_score = mean.(histograms)
    return (histograms, expected_wins, expected_battle_score)
end;

function get_expected_win(histogram::Hist, numEmpiricalTeams::Int64)
    sum(histogram.counts[21:40]) / (numEmpiricalTeams / 5)
end;

function get_summary_stats(
    histograms,
    expected_wins,
    expected_battle_score,
    theoreticalTeams,
)
    summaryStats = Array{Any}(undef, length(theoreticalTeams), 5)
    for i = 1:length(theoreticalTeams)
        @inbounds summaryStats[
            i,
            :,
        ] = [expected_wins[i] expected_battle_score[i] theoreticalTeams[i].mons[1].toString theoreticalTeams[i].mons[2].toString theoreticalTeams[i].mons[3].toString]
    end
    return summaryStats
end;

function rank(numMons, indigo_file, outfile; league = "great")
    println("Constructing Empirical Teams...")
    empiricalTeams, weights = get_empirical_teams(indigo_file, league = league)
    println("Constructing Theoretical Teams...")
    theoreticalTeams = get_theoretical_teams(numMons, league = league)
    println("Running Battles...")
    histograms, expected_wins, expected_battle_score = run_theoretical_teams(
        theoreticalTeams,
        empiricalTeams,
        weights,
    )
    println("Sorting and Saving...")
    summaryStats = get_summary_stats(
        histograms,
        expected_wins,
        expected_battle_score,
        theoreticalTeams,
    )
    summaryStats = sortslices(
        summaryStats,
        by = x -> x[1],
        dims = 1,
        rev = true,
    )
    df = DataFrame(summaryStats)
    CSV.write(outfile, df)
    println("Done.")
    return df
end;

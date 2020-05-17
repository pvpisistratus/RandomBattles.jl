using OnlineStats, CSV, ProgressMeter, IterTools, DataFrames

function get_empirical_teams(filename::String)
    data = CSV.read(filename)
    numEmpiricalTeams = nrow(data)
    data = hcat(team_count_to_pvpoke.(data[:, 1:3]), data[:, 4])
    empiricalTeams = Array{Team}(undef, numEmpiricalTeams)
    for i = 1:numEmpiricalTeams
        if convert_indices(data[i, 1], rankings) != 0 &&
           convert_indices(data[i, 2], rankings) != 0 &&
           convert_indices(data[i, 3], rankings) != 0
            empiricalTeams[i] = Team([data[i, 1] data[i, 2] data[i, 3]])
        else
            @warn "Ignoring team $(data[i, 1]), $(data[i, 2]), $(data[i, 3])"
    end
    return empiricalTeams, data[:, 4]
end;

function get_theoretical_teams(numMons::Int64)
    theoreticalMons = Array{String}(undef, numMons)
    for i = 1:numMons
        theoreticalMons = rankings[i]["speciesId"]
    end
    dexDict = Dict{Int16,Array{Int64,1}}()
    for i = 1:numMons
        @inbounds dex = gamemaster["pokemon"][get_gamemaster_mon_id(theoreticalMons[i])]["dex"]
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
    for i = 1:length(dexKeys)
        for j in Iterators.flatten((1:(i-1), (i+1):length(dexKeys)))
            for k = (j+1):length(dexKeys)
                if i != k
                    @inbounds @fastmath toAdd = length(dexDict[dexKeys[i]]) *
                                                length(dexDict[dexKeys[j]]) *
                                                length(dexDict[dexKeys[k]])
                    @inbounds @fastmath theoreticalTeams[index:(index+toAdd-1)] = [Team([
                        l,
                        m,
                        n,
                    ]) for l in dexDict[dexKeys[i]], m in dexDict[dexKeys[j]], n in dexDict[dexKeys[k]]]
                    index += toAdd
                end
            end
        end
    end
    return theoreticalTeams
end;

function run_empirical_teams(
    homeTeam::Team,
    awayTeams::Array{Team},
    weights::Array{Int64},
)
    histogram = Hist(0.0:0.025:1.0)
    @simd for i = 1:length(awayTeams)
        @simd for j = 1:weights[i]
            @inbounds fit!(
                histogram,
                play_battle(State(homeTeam, awayTeams[i]), 1),
            )
        end
    end
    return histogram
end;

function run_theoretical_teams(
    homeTeams::Array{Team},
    awayTeams::Array{Team},
    weights,
)
    histograms = Array{Hist}(undef, length(homeTeams))
    @showprogress for i = 1:length(homeTeams)
        @inbounds histograms[i] = run_empirical_teams(
            homeTeams[i],
            awayTeams,
            weights,
        )
    end
    expected_wins = get_expected_win.(histograms, sum(weights))
    expected_battle_score = mean.(histograms)
    return (histograms, expected_wins, expected_battle_score)
end;

function get_expected_win(histogram::Hist, numOpponentTeams::Int64)
    sum(histogram.counts[21:40]) / (numOpponentTeams / 5)
end;

function get_summary_stats(
    histograms,
    expected_wins,
    expected_battle_score,
    homeTeams,
)
    summaryStats = Array{Any}(undef, numHomeTeams, 5)
    for i = 1:numHomeTeams
        @inbounds summaryStats[
            i,
            :,
        ] = [expected_wins[i] expected_battle_score[i] homeTeams[i].mons[1].toString homeTeams[i].mons[2].toString homeTeams[i].mons[3].toString]
    end
    return summaryStats
end;

function rank(numMons, indigo_file, outfile)
    println("Constructing Empirical Teams...")
    empiricalTeams, weights = get_empirical_teams(indigo_file)
    println("Constructing Theoretical Teams...")
    theoreticalTeams = get_theoretical_teams(numMons)
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
        homeTeams,
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
    return df, histograms, expected_wins, expected_battle_score
end;

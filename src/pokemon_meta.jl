using JSON, HTTP, Distributions

struct PokemonMeta
    pokemon::Array{Pokemon}
    weights::Distribution
end

function PokemonMeta(
    cup::String;
    data_key::String = "all",
    source::String = "silph",
    league::String = "great",
)
    if source == "silph"
        resp = HTTP.get("https://silph.gg/api/cup/" * cup * "/stats/.json")
        data = JSON.parse(String(resp.body))
        silph_keys = collect(keys(data[data_key]))
        mons = silph_to_pvpoke.(silph_keys)
        meta_weights = map(x -> data[data_key][x]["percent"], silph_keys)
        return PokemonMeta(Pokemon.(mons, cup = cup),
            Categorical(meta_weights ./ sum(meta_weights)))
    elseif source == "pvpoke"
        overrides = get_rankings("$(cup)_rankingoverrides")
        rankings = get_rankings(cup, league = league)
        #cup_id = findfirst(
        #    x -> x["cup"] == cup && x["league"] == get_cp_limit(league),
        #    overrides
        #)
        mons = Pokemon.(map(x -> x["speciesId"],
            rankings), cup = cup, league = league)
        weights = ones(length(mons))
        for i = 1:length(overrides[cup_id]["pokemon"])
            if haskey(overrides[cup_id]["pokemon"][i], "weight")
                weight = overrides[cup_id]["pokemon"][i]["weight"]
                speciesId = overrides[cup_id]["pokemon"][i]["speciesId"]
                species_index = findfirst(x -> speciesId == x,
                    map(x -> x["speciesId"], rankings))
                if !isnothing(species_index)
                    weights[species_index] = weight
                end
            end
        end
        return PokemonMeta(mons, Categorical(weights ./ sum(weights)))
    end
end

PokemonMeta() = PokemonMeta([], Categorical([1.0]))

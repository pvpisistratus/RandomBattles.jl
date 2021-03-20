using JSON, HTTP, Distributions, Memoize

"""
    PokemonMeta(pokemon, weights)

Struct for holding an array of StaticPokemon, and a Distribution
(usually Categorical) associated with either weights or frequency of the mons.
"""
struct PokemonMeta
    pokemon::Array{StaticPokemon}
    weights::Distribution
end

"""
    PokemonMeta(cup; data_key = "all", source = "silph", league = "great")

Construct a PokemonMeta for a particular meta using either Silph Arena
frequency data, or PvPoke weights as the distribution. This function is
memoized to avoid downloading multiple times and approaching Silph Arena API
limits.
"""
@memoize function PokemonMeta(
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
        return PokemonMeta(StaticPokemon.(mons, cup = cup),
            Categorical(meta_weights ./ sum(meta_weights)))
    elseif source == "pvpoke"
        overrides = get_overrides(cup, league = league)
        rankings = get_rankings(cup, league = league)
        mons = Pokemon.(map(x -> x["speciesId"],
            rankings), cup = cup, league = league)
        weights = ones(length(mons))
        for i = 1:length(overrides)
            if haskey(overrides[i], "weight")
                weight = overrides[i]["weight"]
                speciesId = overrides[i]["speciesId"]
                species_index = findfirst(x -> speciesId == x,
                    map(x -> x["speciesId"], rankings))
                if !isnothing(species_index)
                    weights[species_index] = weight
                end
            end
        end
        return PokemonMeta(mons, Categorical(weights ./ sum(weights)))
    else
        rankings = get_rankings(cup, league = league)
        mons = map(x -> StaticPokemon(x["speciesId"], cup = cup, league = league),
            rankings)
        PokemonMeta(mons, Categorical(ones(length(mons)) ./ length(mons)))
    end
end

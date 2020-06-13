using JSON, HTTP, Distributions

struct PokemonMeta
    pokemon::Array{Pokemon}
    weights::Distribution
end

function PokemonMeta(cup::String; data_key = "all")
    resp = HTTP.get("https://silph.gg/api/cup/" * cup * "/stats/.json")
    data = JSON.parse(String(resp.body))
    silph_keys = collect(keys(data[data_key]))
    mons = silph_to_pvpoke.(silph_keys)
    meta_weights = map(x -> data[data_key][x]["percent"], silph_keys)
    return PokemonMeta(Pokemon.(mons, cup = cup), Categorical(meta_weights ./ sum(meta_weights)))
end

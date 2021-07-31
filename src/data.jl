using JSON, Colors, Memoize

# Grabbing the open league rankings from PvPoke. These are common enough that
# automatically downloading these and making them constant makes sense.
const gamemaster =     JSON.parsefile(download(
    "https://raw.githubusercontent.com/pvpoke/pvpoke/master/src/data/" *
    "gamemaster.json"))

"""
    get_cp_limit(league)

Given a league ("great", "ultra", "master") return its cp limit
(1500, 2500, 10000). Masters has no cp limit but is signified in PvPoke with the
arbitrarily large 10000.

# Examples
```jldoctest
julia> get_cp_limit("great")
1500
"""
get_cp_limit(league::String) = league == "master" ? 10_000 :
    league == "ultra" ? 2_500 : 1_500

"""
    get_rankings(cup; league = "great")

Download the PvPoke rankings for a particular meta, optionally within a league
that is not great league. This function is memoized to avoid downloading the
same file multiple times.
"""
@memoize function get_rankings(cup::String; league = "great")
    return JSON.parsefile(download(
        "https://raw.githubusercontent.com/pvpoke/pvpoke/master/src/" *
        "data/rankings/$(cup)/overall/rankings-$(get_cp_limit(league)).json"))
end

"""
    get_overrides(cup; league = "great")

Download the PvPoke overrides used to generate rankings for a particular meta,
optionally within a league that is not great league. This function is memoized
to avoid downloading the same file multiple times.
"""
@memoize function get_overrides(cup::String; league = "great")
    cup == "great" && return get_overrides("overall", league = "great")
    cup == "ultra" && return get_overrides("overall", league = "ultra")
    cup == "master" && return get_overrides("overall", league = "master")
    return JSON.parsefile(download(
        "https://raw.githubusercontent.com/pvpoke/pvpoke/master/src/data/" *
        "overrides/$(cup)/overall/$(get_cp_limit(league)).json"))
end

@memoize get_silph_usage(cup::String) =
    JSON.parsefile(download("https://silph.gg/api/cup/" * cup * "/stats/.json"))

"""
    get_gamemaster_mon_id(name)

Given a mon's PvPoke id, get its location within the gamemaster JSON file.
"""
function get_gamemaster_mon_id(name::String)
    for i = 1:length(gamemaster["pokemon"])
        gamemaster["pokemon"][i]["speciesId"] == name && return i
    end
end

"""
    get_gamemaster_move_id(name)

Given a move's PvPoke id, get its location within the gamemaster JSON file.
"""
function get_gamemaster_move_id(name::String)
    for i = 1:length(gamemaster["moves"])
        gamemaster["moves"][i]["moveId"] == name && return i
    end
end

"""
    get_rankings_mon_id(name; league = "great", cup = "all")

Given a mon's PvPoke id, find its location within a particular meta's rankings
"""
function get_rankings_mon_id(name::String;
    league::String = "great", cup::String = "all")
    rankings = get_rankings(cup, league = league)
    for i = 1:length(rankings)
        rankings[i]["speciesId"] == name && return i
    end
    return 0
end

# Types and effectiveness adapted from Silph Arena graphic
# https://storage.googleapis.com/silphroad-publishing/silph-wp/
# 3d94d185-type-chart_v4.png
const typings = Dict{String, Int8}(
    "normal"   => Int8(1),  "fighting" => Int8(2),  "flying"   => Int8(3),
    "poison"   => Int8(4),  "ground"   => Int8(5),  "rock"     => Int8(6),
    "bug"      => Int8(7),  "ghost"    => Int8(8),  "steel"    => Int8(9),
    "fire"     => Int8(10), "water"    => Int8(11), "grass"    => Int8(12),
    "electric" => Int8(13), "psychic"  => Int8(14), "ice"      => Int8(15),
    "dragon"   => Int8(16), "dark"     => Int8(17), "fairy"    => Int8(18),
    "none"     => Int8(19))

function get_effectiveness(a::Int8, d1::Int8, d2::Int8)
    𛲜 = 1      # weakness
    Θ = -1    # resistance
    ✗ = -2      # "immunity"

    if a == 1
        eff = (d1 == 6 || d1 == 9 ? Θ : d1 == 8 ? ✗ : 0) +
            (d2 == 6 || d2 == 9 ? Θ : d2 == 8 ? ✗ : 0)
    elseif a == 2
        eff = (d1 == 1 || d1 == 6 || d1 == 9 || d1 == 15 || d1 == 17 ? 𛲜 :
            d1 == 3 || d1 == 4 || d1 == 7 || d1 == 14 || d1 == 18 ? Θ :
            d1 == 8 ? ✗ : 0) +
            (d2 == 1 || d2 == 6 || d2 == 9 || d2 == 15 || d2 == 17 ? 𛲜 :
            d2 == 3 || d2 == 4 || d2 == 7 || d2 == 14 || d2 == 18 ? Θ :
            d2 == 8 ? ✗ : 0)
    elseif a == 3
        eff = (d1 == 2 || d1 == 7 || d1 == 12 ? 𛲜 :
            d1 == 6 || d1 == 9 || d1 == 13 ? Θ : 0) +
            (d2 == 2 || d2 == 7 || d2 == 12 ? 𛲜 :
            d2 == 6 || d2 == 9 || d2 == 13 ? Θ : 0)
    elseif a == 4
        eff = (3 < d1 < 7 || d1 == 8 ? Θ : d1 == 12 || d1 == 18 ? 𛲜 :
            d1 == 9 ? ✗ : 0) + (3 < d2 < 7 || d2 == 8 ? Θ : d2 == 12 ||
            d2 == 18 ? 𛲜 : d2 == 9 ? ✗ : 0)
    elseif a == 5
        eff = (d1 == 4 || d1 == 6 || d1 == 9 || d1 == 10 || d1 == 13 ? 𛲜 :
            d1 == 7 || d1 == 12 ? Θ : d1 == 3 ? ✗ : 0) +
            (d2 == 4 || d2 == 6 || d2 == 9 || d2 == 10 || d2 == 13 ? 𛲜 :
            d2 == 7 || d2 == 12 ? Θ : d2 == 3 ? ✗ : 0)
    elseif a == 6
        eff = (d1 == 3 || d1 == 7 || d1 == 10 || d1 == 15 ? 𛲜 :
            d1 == 2 || d1 == 5 || d1 == 9 ? Θ : 0) +
            (d2 == 3 || d2 == 7 || d2 == 10 || d2 == 15 ? 𛲜 :
            d2 == 2 || d2 == 5 || d2 == 9 ? Θ : 0)
    elseif a == 7
        eff = (d1 == 12 || d1 == 14 || d1 == 17 ? 𛲜 :
            1 < d1 < 5 || 7 < d1 < 11 || d1 == 18 ? Θ : 0) +
            (d2 == 12 || d2 == 14 || d2 == 17 ? 𛲜 :
            1 < d2 < 5 || 7 < d2 < 11 || d2 == 18 ? Θ : 0)
    elseif a == 8
        eff = (d1 == 8 || d1 == 14 ? 𛲜 : d1 == 17 ? Θ : d1 == 1 ? ✗ : 0) +
            (d2 == 8 || d2 == 14 ? 𛲜 : d2 == 17 ? Θ : d2 == 1 ? ✗ : 0)
    elseif a == 9
        eff = (d1 == 6 || d1 == 15 || d1 == 18 ? 𛲜 : 8 < d1 < 12 ||
            d1 == 13 ? Θ : 0) + (d2 == 6 || d2 == 15 || d2 == 18 ? 𛲜 :
            8 < d2 < 12 || d2 == 13 ? Θ : 0)
    elseif a == 10
        eff = (d1 == 7 || d1 == 9 || d1 == 12 || d1 == 15 ? 𛲜 :
            d1 == 6 || d1 == 10 || d1 == 11 || d1 == 16 ? Θ : 0) +
            (d2 == 7 || d2 == 9 || d2 == 12 || d2 == 15 ? 𛲜 :
            d2 == 6 || d2 == 10 || d2 == 11 || d2 == 16 ? Θ : 0)
    elseif a == 11
        eff = (4 < d1 < 7 || d1 == 10 ? 𛲜 : 10 < d1 < 13 || d1 == 16 ? Θ : 0) +
            (4 < d2 < 7 || d2 == 10 ? 𛲜 : 10 < d2 < 13 || d2 == 16 ? Θ : 0)
    elseif a == 12
        eff = (d1 == 5 || d1 == 6 || d1 == 11 ? 𛲜 :
            2 < d1 < 5 || d1 == 7 || 8 < d1 < 11 || d1 == 12 || d1 == 16 ? Θ :
            0) + (d2 == 5 || d2 == 6 || d2 == 11 ? 𛲜 :
            2 < d2 < 5 || d2 == 7 || 8 < d2 < 11 || d2 == 12 || d2 == 16 ? Θ :
            0)
    elseif a == 13
        eff = (d1 == 3 || d1 == 11 ? 𛲜 : d1 == 12 || d1 == 13 || d1 == 16 ? Θ :
            d1 == 5 ? ✗ : 0) +
            (d2 == 3 || d2 == 11 ? 𛲜 : d2 == 12 || d2 == 13 || d2 == 16 ? Θ :
                d2 == 5 ? ✗ : 0)
    elseif a == 14
        eff = (d1 == 2 || d1 == 4 ? 𛲜 : d1 == 9 || d1 == 14 ? Θ :
            d1 == 17 ? ✗ : 0) +
            (d2 == 2 || d2 == 4 ? 𛲜 : d2 == 9 || d2 == 14 ? Θ :
            d2 == 17 ? ✗ : 0)
    elseif a == 15
        eff = (d1 == 3 || d1 == 5 || d1 == 12 || d1 == 16 ? 𛲜 :
            8 < d1 < 12 || d1 == 15 ? Θ : 0) +
            (d2 == 3 || d2 == 5 || d2 == 12 || d2 == 16 ? 𛲜 :
            8 < d2 < 12 || d2 == 15 ? Θ : 0)
    elseif a == 16
        eff = (d1 == 16 ? 𛲜 : d1 == 9 ? Θ : d1 == 18 ? ✗ : 0) +
            (d2 == 16 ? 𛲜 : d2 == 9 ? Θ : d2 == 18 ? ✗ : 0)
    elseif a == 17
        eff = (d1 == 8 || d1 == 14 ? 𛲜 : d1 == 2 || 16 < d1 < 19 ? Θ : 0) +
            (d2 == 8 || d2 == 14 ? 𛲜 : d2 == 2 || 16 < d2 < 19 ? Θ : 0)
    else
        eff = (d1 == 2 || 15 < d1 < 18 ? 𛲜 : d1 == 4 || d1 == 9 ||
            d1 == 10 ? Θ : 0) +
            (d2 == 2 || 15 < d2 < 18 ? 𛲜 : d2 == 4 || d2 == 9 ||
            d2 == 10 ? Θ : 0)
    end
    if eff == -3
        return 125, 512
    elseif eff == -2
        return 25,  64
    elseif eff == -1
        return 5,   8
    elseif eff == 0
        return 1,   1
    elseif eff == 1
        return 8,   5
    else
        return 64,  25
    end
end

# CP multipliers from PvPoke
const cpm = Dict(
    1.0 => 0.0939999967813492, 1.5 => 0.135137432089339,
    2.0 => 0.166397869586945, 2.5 => 0.192650913155325,
    3.0 => 0.215732470154762, 3.5 => 0.236572651424822,
    4.0 => 0.255720049142838, 4.5 => 0.273530372106572,
    5.0 => 0.290249884128571, 5.5 => 0.306057381389863,
    6.0 => 0.321087598800659, 6.5 => 0.335445031996451,
    7.0 => 0.349212676286697, 7.5 => 0.362457736609939,
    8.0 => 0.375235587358475, 8.5 => 0.387592407713878,
    9.0 => 0.399567276239395, 9.5 => 0.4111935532161,
    10.0 => 0.422500014305115, 10.5 => 0.432926420512509,
    11.0 => 0.443107545375824, 11.5 => 0.453059948165049,
    12.0 => 0.46279838681221, 12.5 => 0.472336085311278,
    13.0 => 0.481684952974319, 13.5 => 0.490855807179549,
    14.0 => 0.499858438968658, 14.5 => 0.5087017489616,
    15.0 => 0.517393946647644, 15.5 => 0.525942516110322,
    16.0 => 0.534354329109192, 16.5 => 0.542635753803599,
    17.0 => 0.550792694091797, 17.5 => 0.558830584490385,
    18.0 => 0.566754519939423, 18.5 => 0.57456912814537,
    19.0 => 0.582278907299042, 19.5 => 0.589887907888945,
    20.0 => 0.597400009632111, 20.5 => 0.604823648665171,
    21.0 => 0.61215728521347, 21.5 => 0.619404107958234,
    22.0 => 0.626567125320435, 22.5 => 0.633649178748576,
    23.0 => 0.6406529545784, 23.5 => 0.647580971386554,
    24.0 => 0.654435634613037, 24.5 => 0.661219265805859,
    25.0 => 0.667934000492095, 25.5 => 0.674581885647492,
    26.0 => 0.681164920330048, 26.5 => 0.687684901255373,
    27.0 => 0.694143652915955, 27.5 => 0.700542901033063,
    28.0 => 0.706884205341339, 28.5 => 0.713169074873823,
    29.0 => 0.719399094581604, 29.5 => 0.725575586915154,
    30.0 => 0.731700003147125, 30.5 => 0.734741038550429,
    31.0 => 0.737769484519958, 31.5 => 0.740785579737136,
    32.0 => 0.743789434432983, 32.5 => 0.746781197247765,
    33.0 => 0.749761044979095, 33.5 => 0.752729099732281,
    34.0 => 0.75568550825119, 34.5 => 0.758630370209851,
    35.0 => 0.761563837528229, 35.5 => 0.76448604959218,
    36.0 => 0.767397165298462, 36.5 => 0.770297293677362,
    37.0 => 0.773186504840851, 37.5 => 0.776064947064992,
    38.0 => 0.778932750225067, 38.5 => 0.781790050767666,
    39.0 => 0.784636974334717, 39.5 => 0.787473608513275,
    40.0 => 0.790300011634827, 40.5 => 0.792803968023538,
    41.0 => 0.795300006866455, 41.5 => 0.797803898371622,
    42.0 => 0.800300002098083, 42.5 => 0.802803871877596,
    43.0 => 0.805299997329711, 43.5 => 0.807803850847053,
    44.0 => 0.81029999256134, 44.5 => 0.812803835179168,
    45.0 => 0.815299987792968, 45.5 => 0.817803806620319,
    46.0 => 0.820299983024597, 46.5 => 0.822803778631297,
    47.0 => 0.825299978256225, 47.5 => 0.827803750922782,
    48.0 => 0.830299973487854, 48.5 => 0.832803753381377,
    49.0 => 0.835300028324127, 49.5 => 0.837803755931569,
    50.0 => 0.840300023555755
)

# Color scheme to match PvPoke
const colors = [RGBA(153/255, 159/255, 161/255, 1.0),
                RGBA(213/255,  63/255,  91/255, 1.0),
                RGBA(148/255, 171/255, 225/255, 1.0),
                RGBA(193/255,  98/255, 212/255, 1.0),
                RGBA(212/255, 141/255,  91/255, 1.0),
                RGBA(208/255, 196/255, 142/255, 1.0),
                RGBA(158/255, 195/255,  49/255, 1.0),
                RGBA( 89/255, 107/255, 181/255, 1.0),
                RGBA( 82/255, 142/255, 160/255, 1.0),
                RGBA(254/255, 163/255,  84/255, 1.0),
                RGBA( 86/255, 158/255, 222/255, 1.0),
                RGBA( 94/255, 189/255,  91/255, 1.0),
                RGBA(246/255, 215/255,  75/255, 1.0),
                RGBA(245/255, 126/255, 121/255, 1.0),
                RGBA(120/255, 212/255, 192/255, 1.0),
                RGBA( 14/255, 104/255, 184/255, 1.0),
                RGBA( 86/255,  86/255,  99/255, 1.0),
                RGBA(240/255, 152/255, 228/255, 1.0)]

# Purple-ish shield color to match game
const shieldColor = RGBA(235/255,13/255,199/255, 1.0)

"""
    silph_to_pvpoke(name)

Given the name of a pokemon from the Silph API, return the pvpoke id

# Examples
```jldoctest
julia> silph_to_pvpoke("Mr. Mime")
mr_mime
"""
function silph_to_pvpoke(name::String)
    name = lowercase(name)
    name = replace(name, "-" => "_")
    name = replace(name, "_normal" => "")
    name = replace(name, "mr. " => "mr_")
    name = replace(name, "alola" => "alolan")
    name = replace(name, "galar" => "galarian")
    name = replace(name, "sunshine" => "sunny")
    name = replace(name, "basculin_red" => "basculin")
    name = replace(name, "basculin_blue" => "basculin")
    name = replace(name, "darmanitan" => "darmanitan_standard")
    name = replace(name, "gastrodon_blue" => "gastrodon_west_sea")
    name = replace(name, "gastrodon_pink" => "gastrodon_east_sea")
    name = replace(name, "sirfetch'd" => "sirfetchd")
    return name
end

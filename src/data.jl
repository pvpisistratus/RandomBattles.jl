using JSON, StaticArrays, Colors, Memoize, Setfield

const gamemaster = JSON.parsefile(joinpath(@__DIR__, "../data/gamemaster.json"))
const greatRankings = JSON.parsefile(joinpath(@__DIR__, "../data/rankings-1500.json"))
const ultraRankings = JSON.parsefile(joinpath(@__DIR__, "../data/rankings-2500.json"))
const masterRankings = JSON.parsefile(joinpath(@__DIR__, "../data/rankings-10000.json"))

@memoize function get_rankings(rankings::String; league = "great")
    rankings == "great" && return greatRankings
    rankings == "ultra" && return ultraRankings
    rankings == "master" && return masterRankings
    try
        return JSON.parsefile(joinpath(@__DIR__, "../data/$(rankings).json"))
    catch
        return JSON.parsefile(joinpath(@__DIR__, "../data/$(rankings)-$(league).json"))
    end
end

get_cp_limit(league::String) = league == "master" ? 10_000 : league == "ultra" ? 2_500 : 1_500

function get_type_id(typeName::String)
    type_id = @match typeName begin
        "normal"   => Int8(1)
        "fighting" => Int8(2)
        "flying"   => Int8(3)
        "poison"   => Int8(4)
        "ground"   => Int8(5)
        "rock"     => Int8(6)
        "bug"      => Int8(7)
        "ghost"    => Int8(8)
        "steel"    => Int8(9)
        "fire"     => Int8(10)
        "water"    => Int8(11)
        "grass"    => Int8(12)
        "electric" => Int8(13)
        "psychic"  => Int8(14)
        "ice"      => Int8(15)
        "dragon"   => Int8(16)
        "dark"     => Int8(17)
        "fairy"    => Int8(18)
        _          => Int8(19)
    end
    return type_id
end

𛲜 = 1.6      # weakness
Θ = 1 / 𛲜    # resistance
✗ = Θ^2      # "immunity"
const type_effectiveness = (@SMatrix [
    1 1 1 1 1 Θ 1 ✗ Θ 1 1 1 1 1 1 1 1 1 1                  # normal
    𛲜 1 Θ Θ 1 𛲜 Θ ✗ 𛲜 1 1 1 1 Θ 𛲜 1 𛲜 Θ 1                  # fighting
    1 𛲜 1 1 1 Θ 𛲜 1 Θ 1 1 𛲜 Θ 1 1 1 1 1 1                  # flying
    1 1 1 Θ Θ Θ 1 Θ ✗ 1 1 𛲜 1 1 1 1 1 𛲜 1                  # poison
    1 1 ✗ 𛲜 1 𛲜 Θ 1 𛲜 𛲜 1 Θ 𛲜 1 1 1 1 1 1                  # ground
    1 Θ 𛲜 1 Θ 1 𛲜 1 Θ 𛲜 1 1 1 1 𛲜 1 1 1 1                  # rock
    1 Θ Θ Θ 1 1 1 Θ Θ Θ 1 𛲜 1 𛲜 1 1 𛲜 Θ 1                  # bug
    ✗ 1 1 1 1 1 1 𛲜 1 1 1 1 1 𛲜 1 1 Θ 1 1                  # ghost
    1 1 1 1 1 𛲜 1 1 Θ Θ Θ 1 Θ 1 𛲜 1 1 𛲜 1                  # steel
    1 1 1 1 1 Θ 𛲜 1 𛲜 Θ Θ 𛲜 1 1 𛲜 Θ 1 1 1                  # fire
    1 1 1 1 𛲜 𛲜 1 1 1 𛲜 Θ Θ 1 1 1 Θ 1 1 1                  # water
    1 1 Θ Θ 𛲜 𛲜 Θ 1 Θ Θ 𛲜 Θ 1 1 1 Θ 1 1 1                  # grass
    1 1 𛲜 1 ✗ 1 1 1 1 1 𛲜 Θ Θ 1 1 Θ 1 1 1                  # electric
    1 𛲜 1 𛲜 1 1 1 1 Θ 1 1 1 1 Θ 1 1 ✗ 1 1                  # psychic
    1 1 𛲜 1 𛲜 1 1 1 Θ Θ Θ 𛲜 1 1 Θ 𛲜 1 1 1                  # ice
    1 1 1 1 1 1 1 1 Θ 1 1 1 1 1 1 𛲜 1 ✗ 1                  # dragon
    1 Θ 1 1 1 1 1 𛲜 1 1 1 1 1 𛲜 1 1 Θ Θ 1                  # dark
    1 𛲜 1 Θ 1 1 1 1 Θ Θ 1 1 1 1 1 𛲜 𛲜 1 1                  # fairy
])'

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

const shieldColor = RGBA(235/255,13/255,199/255, 1.0)

const typings = unique(map(x -> sort(RandomBattles.get_type_id.(x["types"])), gamemaster["pokemon"]))
function get_effectiveness(defenderTypes::Vector{Int8}, moveType::Int8)
    return round(UInt16, 12_800 * type_effectiveness[defenderTypes[1], moveType] *
        type_effectiveness[defenderTypes[2], moveType])
end
store_eff(e::UInt16) = return @match e begin
     0x3200 => Int8(4)
     0x1f40 => Int8(3)
     0x1388 => Int8(2)
     0x0c35 => Int8(1)
     0x5000 => Int8(5)
     0x8000 => Int8(6)
end
get_eff(e::Int8) = return @match e begin
     Int8(1) => 3125
     Int8(2) => 5000
     Int8(3) => 8000
     Int8(4) => 12800
     Int8(5) => 20480
     Int8(6) => 32768
end
const effectiveness = [store_eff(get_effectiveness(i, j))) for i in typings, j = Int8(1):Int8(18)]

fast_moves_gm = filter(x -> x["energy"] == 0, gamemaster["moves"])
const fast_moves = hcat(map(x -> Int8(x["power"]), fast_moves_gm), map(x -> Int8(x["energyGain"]), fast_moves_gm),
    map(x -> RandomBattles.get_type_id(x["type"]), fast_moves_gm), map(x -> Int8(x["cooldown"] ÷ 500), fast_moves_gm))

function get_buff_chance(c)
    return @match c begin
         "1" => Int8(1)
         ".125" => Int8(8)
         ".1" => Int8(10)
         ".3" => Int8(3) # yeah, I know (will be fixed in apply_buffs)
         ".5" => Int8(2)
         "0.5" => Int8(2)
         ".2" => Int8(5)
    end
end

charged_moves_gm = filter(x -> x["energy"] != 0, gamemaster["moves"])
const charged_moves = hcat(map(x -> RandomBattles.get_type_id(x["type"]), charged_moves_gm),
    map(x -> Int8(x["power"] ÷ 5), charged_moves_gm), map(x -> Int8(x["energy"]), charged_moves_gm),
    map(x -> haskey(x, "buffApplyChance") ? get_buff_chance(x["buffApplyChance"]) : Int8(0),  charged_moves_gm))

struct StatBuffs
    val::UInt8
end

function StatBuffs(atk::Int8, def::Int8)
    StatBuffs((clamp(atk, Int8(-4), Int8(4)) + Int8(8)) + (clamp(def, Int8(-4), Int8(4)) + Int16(8))<<Int16(4))
end

get_atk(x::StatBuffs) = Int8(x.val & 0x0F) - Int8(8)
get_def(x::StatBuffs) = Int8(x.val >> 4) - Int8(8)

Base.:+(x::StatBuffs, y::StatBuffs) = StatBuffs(get_atk(x) + get_atk(y), get_def(x) + get_def(y))

const defaultBuff = StatBuffs(Int8(0), Int8(0))

const charged_moves_buffs = hcat(map(x -> haskey(x, "buffs") && x["buffTarget"] == "opponent" ?
    RandomBattles.StatBuffs(Int8(x["buffs"][1]), Int8(x["buffs"][2])) : RandomBattles.defaultBuff,
    charged_moves_gm), map(x -> haskey(x, "buffs") && x["buffTarget"] == "self" ?
    RandomBattles.StatBuffs(Int8(x["buffs"][1]), Int8(x["buffs"][2])) : RandomBattles.defaultBuff,
    charged_moves_gm))

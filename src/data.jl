using JSON, StaticArrays, Colors

const gamemaster = JSON.parsefile(joinpath(@__DIR__, "../data/gamemaster.json"))
const greatRankings = JSON.parsefile(joinpath(
    @__DIR__,
    "../data/rankings-1500.json",
))
const ultraRankings = JSON.parsefile(joinpath(
    @__DIR__,
    "../data/rankings-2500.json",
))
const masterRankings = JSON.parsefile(joinpath(
    @__DIR__,
    "../data/rankings-10000.json",
))

function get_rankings(league::String)
    if league == "master"
        return masterRankings
    elseif league == "ultra"
        return ultraRankings
    else
        return greatRankings
    end
end

function get_cp_limit(league::String)
    if league == "master"
        return 10_000
    elseif league == "ultra"
        return 2_500
    else
        return 1_500
    end
end

𛲜 = 1.6      # weakness
Θ = 1 / 𛲜    # resistance
✗ = Θ^2      # "immunity"
const type_effectiveness = (@SMatrix [# ✴✊✈☠ ⛰ ☗⁂⚰ ⛓ ♨☔✿ ⚡⚛ ❄⛩☽ ❤ ∅
    1 1 1 1 1 Θ 1 ✗ Θ 1 1 1 1 1 1 1 1 1 1                  # normal
    𛲜 1 Θ Θ 1 𛲜 Θ ✗ 𛲜 1 1 1 1 Θ 𛲜 1 𛲜 Θ 1                  # fighting
    1 𛲜 1 1 1 Θ 𛲜 1 Θ 1 1 𛲜 Θ 1 1 1 1 1 1                  # flying
    1 1 1 Θ Θ Θ 1 Θ ✗ 1 1 𛲜 1 1 1 1 1 𛲜 1                  # poison
    1 1 ✗ 𛲜 1 𛲜 Θ 1 𛲜 𛲜 1 Θ 𛲜 1 1 1 1 1 1                  # ground
    1 Θ 𛲜 1 Θ 1 𛲜 1 Θ 𛲜 1 1 1 1 𛲜 1 1 1 1                  # rock
    1 Θ 1 Θ 1 1 1 Θ Θ Θ 1 𛲜 1 𛲜 1 1 𛲜 Θ 1                  # bug
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
    1 => 0.094,
    1.5 => 0.1351374318,
    2 => 0.16639787,
    2.5 => 0.192650919,
    3 => 0.21573247,
    3.5 => 0.2365726613,
    4 => 0.25572005,
    4.5 => 0.2735303812,
    5 => 0.29024988,
    5.5 => 0.3060573775,
    6 => 0.3210876,
    6.5 => 0.3354450362,
    7 => 0.34921268,
    7.5 => 0.3624577511,
    8 => 0.3752356,
    8.5 => 0.387592416,
    9 => 0.39956728,
    9.5 => 0.4111935514,
    10 => 0.4225,
    10.5 => 0.4329264091,
    11 => 0.44310755,
    11.5 => 0.4530599591,
    12 => 0.4627984,
    12.5 => 0.472336093,
    13 => 0.48168495,
    13.5 => 0.4908558003,
    14 => 0.49985844,
    14.5 => 0.508701765,
    15 => 0.51739395,
    15.5 => 0.5259425113,
    16 => 0.5343543,
    16.5 => 0.5426357375,
    17 => 0.5507927,
    17.5 => 0.5588305862,
    18 => 0.5667545,
    18.5 => 0.5745691333,
    19 => 0.5822789,
    19.5 => 0.5898879072,
    20 => 0.5974,
    20.5 => 0.6048236651,
    21 => 0.6121573,
    21.5 => 0.6194041216,
    22 => 0.6265671,
    22.5 => 0.6336491432,
    23 => 0.64065295,
    23.5 => 0.6475809666,
    24 => 0.65443563,
    24.5 => 0.6612192524,
    25 => 0.667934,
    25.5 => 0.6745818959,
    26 => 0.6811649,
    26.5 => 0.6876849038,
    27 => 0.69414365,
    27.5 => 0.70054287,
    28 => 0.7068842,
    28.5 => 0.7131691091,
    29 => 0.7193991,
    29.5 => 0.7255756136,
    30 => 0.7317,
    30.5 => 0.7347410093,
    31 => 0.7377695,
    31.5 => 0.7407855938,
    32 => 0.74378943,
    32.5 => 0.7467812109,
    33 => 0.74976104,
    33.5 => 0.7527290867,
    34 => 0.7556855,
    34.5 => 0.7586303683,
    35 => 0.76156384,
    35.5 => 0.7644860647,
    36 => 0.76739717,
    36.5 => 0.7702972656,
    37 => 0.7731865,
    37.5 => 0.7760649616,
    38 => 0.77893275,
    38.5 => 0.7817900548,
    39 => 0.784637,
    39.5 => 0.7874736075,
    40 => 0.7903,
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
                RGBA(240/255,152/255,228/255, 1.0)]

const shieldColor = RGBA(235/255,13/255,199/255, 1.0)

"""
    StaticPokemon(types, stats, fastMove, chargedMoves)

Struct for holding the values associated with the mons that do not change
throughout the battle: types, stats, and moves. Note that like moves, this
struct is agnostic to the actual identity/dex/species of the mon.
"""
struct StaticPokemon{T1<:PokemonType, T2<:PokemonType}
    stats::Stats
    fastMove::FastMove
    charged_move_1::ChargedMove
    charged_move_2::ChargedMove
end

"""
    StaticPokemon(i; league = "great", cup = "all",
        custom_moveset = ["none"], custom_stats = ())

Construct a StaticPokemon from the index of a mon within its rankings
(optionally specified). Other optional inputs are a custom moveset or IVs.
"""
function StaticPokemon(i::Int64; league::String = "great", cup = "all",
  custom_moveset = ["none"], custom_stats = ())
    rankings = get_rankings(cup, league = league)
    gmid = get_gamemaster_mon_id(rankings[i]["speciesId"])
    gm = gamemaster["pokemon"][gmid]
    types = typings[convert(Array{String}, gm["types"])[1]],
        typings[convert(Array{String}, gm["types"])[2]]
    cp_limit = get_cp_limit(league)
    if custom_stats != ()
        level, atk, def, hp = parse.(Int8, custom_stats)
        if level == 0
            function get_cp(lvl)
                attack = (atk + gm["baseStats"]["atk"]) * cpm[lvl]
                defense = (def + gm["baseStats"]["def"]) * cpm[lvl]
                hitpoints = floor(Int16, (hp + gm["baseStats"]["hp"]) *
                    cpm[lvl])
                return floor(max(10,
                    (attack * sqrt(defense) * sqrt(hitpoints)) / 10.0))
            end
            level = (1:0.5:50)[findfirst(x -> get_cp(x) > cp_limit,
                1:0.5:50) - 1]
        end
    elseif league == "master"
        level, atk, def, hp = 50, 15, 15, 15
    else
        level = gm["defaultIVs"]["cp$(cp_limit)"][1]
        atk = gm["defaultIVs"]["cp$(cp_limit)"][2]
        def = gm["defaultIVs"]["cp$(cp_limit)"][3]
        hp = gm["defaultIVs"]["cp$(cp_limit)"][4]
    end
    attack = haskey(gm, "tags") && "shadow" in gm["tags"] ? floor(UInt16,
        (6/5 * atk + gm["baseStats"]["atk"]) * cpm[level] * 100) :
        floor(UInt16, (atk + gm["baseStats"]["atk"]) * cpm[level] * 100)
    defense = haskey(gm, "tags") && "shadow" in gm["tags"] ? floor(UInt16,
        (5/6 * def + gm["baseStats"]["def"]) * cpm[level] * 100) :
        floor(UInt16, (def + gm["baseStats"]["def"]) * cpm[level] * 100)
    hitpoints = floor(Int16, (hp + gm["baseStats"]["hp"]) * cpm[level])
    stats = Stats(attack, defense, hitpoints)
    if haskey(rankings[i], "moveStr")
        moves = parse.(Ref(Int64), split(rankings[i]["moveStr"], "-"))
        fastMovesAvailable = gm["fastMoves"]
        sort!(fastMovesAvailable)
        fastMoveGm = gamemaster["moves"][get_gamemaster_move_id(
            fastMovesAvailable[moves[1]+1])]
        fastMove = Move(fastMoveGm, types)
        chargedMovesAvailable = gm["chargedMoves"]
        if haskey(gm, "tags") &&
           "shadoweligible" in gm["tags"] && gm["level25CP"] < cp_limit
            push!(chargedMovesAvailable, "RETURN")
        elseif haskey(gm, "tags") && "shadow" in gm["tags"]
            push!(chargedMovesAvailable, "FRUSTRATION")
        end
        sort!(chargedMovesAvailable)
        chargedMove1 = ChargedMove(gamemaster["moves"][get_gamemaster_move_id(
            chargedMovesAvailable[moves[2]])], types)
        chargedMove2 = ChargedMove(gamemaster["moves"][get_gamemaster_move_id(
            chargedMovesAvailable[moves[3]])], types)
    else
        moveset = custom_moveset == ["none"] ?
            rankings[i]["moveset"] : custom_moveset
        fastMove = FastMove(moveset[1]::String, types)
        chargedMove1 = ChargedMove(moveset[2]::String, types)
        chargedMove2 = ChargedMove(moveset[3]::String, types)
    end
    return StaticPokemon{types[1], types[2]}(
        stats,
        fastMove,
        get_energy(chargedMove1) > get_energy(chargedMove2) ? chargedMove2 : chargedMove1,
        get_energy(chargedMove1) > get_energy(chargedMove2) ? chargedMove1 : chargedMove2
    )
end

"""
    StaticPokemon(mon; league = "great", cup = "all")

Construct a StaticPokemon from the name of the pokemon, and the meta it is
within. Movesets and IVs can also be specified by comma-separating the string
being passed in.
"""
function StaticPokemon(mon::String; league = "great", cup = "all")
    if occursin(",", mon)
        mon_arr = split(mon, ",")
        if length(mon_arr) == 4
            return StaticPokemon(get_rankings_mon_id(convert(String,
                mon_arr[1]), league = league, cup = cup), league = league,
                cup = cup, custom_moveset = convert.(String, mon_arr[2:4]))
        elseif length(mon_arr) == 7
            return StaticPokemon(get_rankings_mon_id(convert(String,
                mon_arr[1])), league = league, cup = cup,
                custom_moveset = convert.(String, mon_arr[2:4]),
                custom_stats = ("0", mon_arr[5], mon_arr[6], mon_arr[7]))
        elseif length(mon_arr) == 8
            return StaticPokemon(get_rankings_mon_id(convert(String,
                mon_arr[1])), league = league, cup = cup,
                custom_moveset = convert.(String, mon_arr[2:4]),
                custom_stats = (mon_arr[5], mon_arr[6], mon_arr[7], mon_arr[8]))
        end
    else
        return StaticPokemon(get_rankings_mon_id(
            mon, league = league, cup = cup),
            league = league, cup = cup)
    end
end

"""
    DynamicPokemon(hp, energy)

Struct for holding the values associated with the mons that change throughout
the battle: current hp and energy. Note that like moves, this struct is
agnostic to the actual identity/dex/species of the mon.
"""
struct DynamicPokemon
    data::UInt16    # hp (initially hitpoints stat) and energy (initially 0)
end

"""
    DynamicPokemon(mon)

Construct a starting DynamicPokemon from a StaticPokemon. This is just setting
the starting hp of the mon to the stat value, and the energy to zero.
"""

function get_energy(p::DynamicPokemon)
    return p.data >> 0x0009
end

function get_hp(p::DynamicPokemon)
    return p.data % 0x0200
end

function add_energy(p::DynamicPokemon, e::UInt16)
    return DynamicPokemon(min(0x0064, get_energy(p) + e) << 9 + get_hp(p))
end

function subtract_energy(p::DynamicPokemon, e::UInt16)
    curr_e = get_energy(p)
    return DynamicPokemon((curr_e - min(curr_e, e)) << 9 + get_hp(p))
end

function damage(p::DynamicPokemon, d::UInt16)
    return DynamicPokemon(p.data - min(get_hp(p), d))
end

function DynamicPokemon(mon::StaticPokemon)
    DynamicPokemon(mon.stats.hitpoints)
end

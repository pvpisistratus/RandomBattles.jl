using StaticArrays

"""
    StaticPokemon(types, stats, fastMove, chargedMoves)

Struct for holding the values associated with the mons that do not change
throughout the battle: types, stats, and moves. Note that like moves, this
struct is agnostic to the actual identity/dex/species of the mon.
"""
struct StaticIndividualPokemon
    damage_matrix::SVector{3, Int16}
    fastMove::FastMove
    chargedMoves::SVector{2,ChargedMove}
    stats::Stats
    types::SVector{2,Int8}
end

"""
    calculate_damage(
        attacker::StaticPokemon,
        atkBuff::Int8,
        defender::StaticPokemon,
        defBuff::Int8,
        move::FastMove,
        charge::Int8,
    )

Calculate the damage a particular pokemon does against another using its fast move

"""
function calculate_damage(
    attack::UInt16,
    atkBuff::Int8,
    defender::StaticIndividualPokemon,
    defBuff::Int8,
    move::FastMove
)
    return Int16((Int64(move.power) * Int64(move.stab) *
        Int64(attack) * Int64(get_buff_modifier(atkBuff)) *
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
        12_800) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(get_buff_modifier(defBuff)) * 12_800_000) + 1)
end

"""
    calculate_damage(
        attacker::StaticPokemon,
        atkBuff::Int8,
        defender::StaticPokemon,
        defBuff::Int8,
        move::ChargedMove,
        charge::Int8,
    )

Calculate the damage a particular pokemon does against another using a charged move

"""
function calculate_damage(
    attack::UInt16,
    atkBuff::Int8,
    defender::StaticIndividualPokemon,
    defBuff::Int8,
    move::ChargedMove,
    charge::Int8,
)
    return Int16((Int64(move.power) * Int64(move.stab) *
        Int64(attack) * Int64(get_buff_modifier(atkBuff)) *
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(get_buff_modifier(defBuff)) * 1_280_000_000) + 1)
end

"""
    StaticPokemon(i; league = "great", cup = "open", custom_moveset = ["none"], custom_stats = ())

Construct a StaticPokemon from the index of a mon within its rankings
(optionally specified). Other optional inputs are a custom moveset or IVs.
"""
function StaticIndividualPokemon(i::Int64; league::String = "great", cup = "open",
  custom_moveset = ["none"], custom_stats = (), opponent::Union{Nothing, StaticIndividualPokemon} = nothing)
    rankings = get_rankings(cup == "open" ? league : cup, league = league)
    gmid = get_gamemaster_mon_id(rankings[i]["speciesId"])
    gm = gamemaster["pokemon"][gmid]
    types = typings[convert(Array{String}, gm["types"])[1]], typings[convert(Array{String}, gm["types"])[2]]
    cp_limit = get_cp_limit(league)
    if custom_stats != ()
        level, atk, def, hp = parse.(Int8, custom_stats)
        if level == 0
            function get_cp(lvl)
                attack = (atk + gm["baseStats"]["atk"]) * cpm[lvl]
                defense = (def + gm["baseStats"]["def"]) * cpm[lvl]
                hitpoints = floor(Int16, (hp + gm["baseStats"]["hp"]) * cpm[lvl])
                cp = floor(max(10, (attack * sqrt(defense) * sqrt(hitpoints)) / 10.0))
                return cp
            end
            level = (1:0.5:40)[findfirst(x -> get_cp(x) > cp_limit, 1:0.5:40) - 1]
        end
    elseif league == "master"
        level, atk, def, hp = 40, 15, 15, 15
    else
        level = gm["defaultIVs"]["cp$(cp_limit)"][1]
        atk = gm["defaultIVs"]["cp$(cp_limit)"][2]
        def = gm["defaultIVs"]["cp$(cp_limit)"][3]
        hp = gm["defaultIVs"]["cp$(cp_limit)"][4]
    end
    attack = haskey(gm, "tags") && "shadow" in gm["tags"] ? floor(UInt16, (6/5 * atk + gm["baseStats"]["atk"]) * cpm[level] * 100) : floor(UInt16, (atk + gm["baseStats"]["atk"]) * cpm[level] * 100)
    defense = haskey(gm, "tags") && "shadow" in gm["tags"] ? floor(UInt16, (5/6 * def + gm["baseStats"]["def"]) * cpm[level] * 100) : floor(UInt16, (def + gm["baseStats"]["def"]) * cpm[level] * 100)
    hitpoints = floor(Int16, (hp + gm["baseStats"]["hp"]) * cpm[level])
    stats = Stats(attack, defense, hitpoints)
    if haskey(rankings[i], "moveStr")
        moves = parse.(Ref(Int64), split(rankings[i]["moveStr"], "-"))
        fastMovesAvailable = gm["fastMoves"]
        sort!(fastMovesAvailable)
        fastMoveGm = gamemaster["moves"][get_gamemaster_move_id(fastMovesAvailable[moves[1]+1],)]
        fastMove = Move(fastMoveGm, types)
        chargedMovesAvailable = gm["chargedMoves"]
        if haskey(gm, "tags") &&
           "shadoweligible" in gm["tags"] && gm["level25CP"] < cp_limit
            push!(chargedMovesAvailable, "RETURN")
        elseif haskey(gm, "tags") && "shadow" in gm["tags"]
            push!(chargedMovesAvailable, "FRUSTRATION")
        end
        sort!(chargedMovesAvailable)
        chargedMove1Gm = gamemaster["moves"][get_gamemaster_move_id(chargedMovesAvailable[moves[2]],)]
        chargedMove2Gm = gamemaster["moves"][get_gamemaster_move_id(chargedMovesAvailable[moves[3]],)]
        chargedMoves = [Move(chargedMove1Gm, types), Move(chargedMove2Gm, types)]
    else
        moveset = custom_moveset == ["none"] ? rankings[i]["moveset"] : custom_moveset
        fastMove = FastMove(moveset[1]::String, types)
        chargedMoves = [ChargedMove(moveset[2]::String, types), ChargedMove(moveset[3]::String, types)]
    end
    return StaticIndividualPokemon(
        isnothing(opponent) ? (@SVector [Int16(0), Int16(0), Int16(0)]) : (@SVector [
            calculate_damage(attack, Int8(0), opponent, Int8(0), fastMove),
            calculate_damage(attack, Int8(0), opponent, Int8(0), chargedMoves[1], Int8(100)),
            calculate_damage(attack, Int8(0), opponent, Int8(0), chargedMoves[2], Int8(100))
        ])
        fastMove,
        chargedMoves,
        stats,
        types
    )
end

"""
    StaticPokemon(mon; league = "great", cup = "open")

Construct a StaticPokemon from the name of the pokemon, and the meta it is
within. Movesets and IVs can also be specified by comma-separating the string
being passed in.
"""
function StaticIndividualPokemon(mon::String; league = "great", cup = "open",
  opponent::Union{Nothing, StaticIndividualPokemon} = nothing)
    if occursin(",", mon)
        mon_arr = split(mon, ",")
        if length(mon_arr) == 4
            return StaticIndividualPokemon(get_rankings_mon_id(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]), opponent = opponent)
        elseif length(mon_arr) == 7
            return StaticIndividualPokemon(get_rankings_mon_id(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]),
                custom_stats = ("0", mon_arr[5], mon_arr[6], mon_arr[7]), opponent = opponent)
        elseif length(mon_arr) == 8
            return StaticIndividualPokemon(get_rankings_mon_id(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]),
                custom_stats = (mon_arr[5], mon_arr[6], mon_arr[7], mon_arr[8]), opponent = opponent)
        end
    else
        return StaticIndividualPokemon(get_rankings_mon_id(mon, league = league, cup = cup),
            league = league, cup = cup, opponent = opponent)
    end
end

"""
    DynamicPokemon(mon)

Construct a starting DynamicPokemon from a StaticPokemon. This is just setting
the starting hp of the mon to the stat value, and the energy to zero.
"""
function DynamicPokemon(mon::StaticIndividualPokemon)
    return DynamicPokemon(mon.stats.hitpoints, Int8(0))
end

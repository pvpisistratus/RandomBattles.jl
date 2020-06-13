using StaticArrays

struct Stats
    attack::Float32
    defense::Float32
    hitpoints::Int16
end

struct StatBuffs
    atk::Int8
    def::Int8
end

struct Move
    moveType::Int8
    stab::Float32
    power::Int16
    energy::Int8
    cooldown::Int16
    buffChance::Float32
    oppAtkModifier::Int8
    oppDefModifier::Int8
    selfAtkModifier::Int8
    selfDefModifier::Int8
end

function Move(move_name::String, types)
    move_index = findfirst(isequal(move_name), map(x ->
        gamemaster["moves"][x]["moveId"], 1:length(gamemaster["moves"])))
    gm_move = gamemaster["moves"][move_index]
    return Move(gm_move, types)
end

function Move(gm_move::Dict{String,Any}, types)
    if gm_move["energyGain"] == 0
        return Move(
            get_type_id(gm_move["type"]),
            (get_type_id(gm_move["type"]) in types) ? 1.2 : 1.0,
            gm_move["power"],
            gm_move["energy"],
            0,
            haskey(gm_move, "buffs") ?
            parse(Float64, gm_move["buffApplyChance"]) : 0.0,
            haskey(
                gm_move,
                "buffs",
            ) && gm_move["buffTarget"] == "opponent" ?
            Int(gm_move["buffs"][1]) : 0,
            haskey(
                gm_move,
                "buffs",
            ) && gm_move["buffTarget"] == "opponent" ?
            Int(gm_move["buffs"][2]) : 0,
            haskey(
                gm_move,
                "buffs",
            ) && gm_move["buffTarget"] == "self" ?
            Int(gm_move["buffs"][1]) : 0,
            haskey(
                gm_move,
                "buffs",
            ) && gm_move["buffTarget"] == "self" ?
            Int(gm_move["buffs"][2]) : 0,
        )
    else
        return Move(
                get_type_id(gm_move["type"]),
                (get_type_id(gm_move["type"]) in types) ? 1.3 : 1,
                gm_move["power"],
                gm_move["energyGain"],
                gm_move["cooldown"],
                0.0,
                0,
                0,
                0,
                0,
            )
    end
end

struct Pokemon
    #These values are determined on initialization, and do not change in battle
    types::SVector{2,Int8}
    stats::Stats
    fastMove::Move
    chargedMoves::SVector{2,Move}
    toString::String

    #These values are initialized, but change throughout the battle
    hp::Int16                 #Initially hp stat of mon
    energy::Int8              #Initially 0
    fastMoveCooldown::Int16   #Initially based on fast move
end

function Pokemon(i::Int64; league::String = "great", cup = "open", custom_moveset = ["none"], custom_stats = ())
    rankings = get_rankings(cup == "open" ? league : cup)
    gmid = get_gamemaster_mon_id(rankings[i]["speciesId"])
    gm = gamemaster["pokemon"][gmid]
    types = get_type_id.(convert(Array{String}, gm["types"]))
    cp_limit = get_cp_limit(league)
    if custom_stats != ()
        level, atk, def, hp = custom_stats
    elseif league == "master"
        level, atk, def, hp = 40, 15, 15, 15
    else
        level = gm["defaultIVs"]["cp$(cp_limit)"][1]
        atk = gm["defaultIVs"]["cp$(cp_limit)"][2]
        def = gm["defaultIVs"]["cp$(cp_limit)"][3]
        hp = gm["defaultIVs"]["cp$(cp_limit)"][4]
    end
    attack = (atk + gm["baseStats"]["atk"]) * cpm[level]
    defense = (def + gm["baseStats"]["def"]) * cpm[level]
    hitpoints = floor((hp + gm["baseStats"]["hp"]) * cpm[level])
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
            attack *= gamemaster["settings"]["shadowAtkMult"]
            defense *= gamemaster["settings"]["shadowDefMult"]
        end
        sort!(chargedMovesAvailable)
        chargedMove1Gm = gamemaster["moves"][get_gamemaster_move_id(chargedMovesAvailable[moves[2]],)]
        chargedMove2Gm = gamemaster["moves"][get_gamemaster_move_id(chargedMovesAvailable[moves[3]],)]
        chargedMoves = [Move(chargedMove1Gm, types), Move(chargedMove2Gm, types)]
        toString = rankings[i]["speciesId"] * "," * fastMovesAvailable[moves[1]+1] *
                   "," * chargedMovesAvailable[moves[2]] * "," *
                   chargedMovesAvailable[moves[3]]
    else
        moveset = custom_moveset == ["none"] ? rankings[i]["moveset"] : custom_moveset
        fastMove = Move(moveset[1]::String, types)
        chargedMoves = [Move(moveset[2]::String, types), Move(moveset[3]::String, types)]
        toString = rankings[i]["speciesId"] * "," * moveset[1] *
                   "," * moveset[2] * "," * moveset[3]
    end
    return Pokemon(
        types,
        stats,
        fastMove,
        chargedMoves,
        toString,
        hitpoints,
        0,
        fastMove.cooldown,
    )
end

function Pokemon(mon::String; league = "great", cup = "open")
    if occursin(",", mon)
        mon_arr = split(mon, ",")
        if length(mon_arr) == 4
            return Pokemon(convert_indices(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]))
        else
            return Pokemon(convert_indices(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]),
                custom_stats = (mon_arr[5], mon_arr[6], mon_arr[7], mon_arr[8]))
        end
    else
        return Pokemon(convert_indices(mon, league = league, cup = cup),
            league = league, cup = cup)
    end
end

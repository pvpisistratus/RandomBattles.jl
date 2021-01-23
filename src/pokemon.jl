using StaticArrays

struct Stats
    attack::UInt16
    defense::UInt16
    hitpoints::Int16
end

struct StatBuffs
    atk::Int8
    def::Int8
end

const defaultBuff = StatBuffs(Int8(0), Int8(0))

struct Move
    moveType::Int8
    stab::Int8
    power::UInt8
    energy::Int8
    cooldown::Int8
    buffChance::Int8
    oppAtkModifier::Int8
    oppDefModifier::Int8
    selfAtkModifier::Int8
    selfDefModifier::Int8
end

const defaultMove = Move(Int8(0), Int8(0), UInt8(0), Int8(0), Int8(0), Int8(0), Int8(0), Int8(0), Int8(0), Int8(0))

function Move(move_name::String, types)
    if move_name == "NONE"
        return defaultMove
    end
    move_index = findfirst(isequal(move_name), map(x ->
        gamemaster["moves"][x]["moveId"], 1:length(gamemaster["moves"])))
    gm_move = gamemaster["moves"][move_index]
    return Move(gm_move, types)
end

function Move(gm_move::Dict{String,Any}, types)
    if gm_move["energyGain"] == 0
        return Move(
            get_type_id(gm_move["type"]),
            (get_type_id(gm_move["type"]) in types) ? Int8(12) : Int8(10),
            UInt8(gm_move["power"]),
            Int8(gm_move["energy"]),
            Int8(0),
            haskey(gm_move, "buffs") ?
            floor(Int8, parse(Float64, gm_move["buffApplyChance"]) * 100) : Int8(0),
            haskey(gm_move, "buffs") && gm_move["buffTarget"] == "opponent" ? Int8(gm_move["buffs"][1]) : Int8(0),
            haskey(gm_move, "buffs") && gm_move["buffTarget"] == "opponent" ? Int8(gm_move["buffs"][2]) : Int8(0),
            haskey(gm_move, "buffs") && gm_move["buffTarget"] == "self" ? Int8(gm_move["buffs"][1]) : Int8(0),
            haskey(gm_move, "buffs") && gm_move["buffTarget"] == "self" ? Int8(gm_move["buffs"][2]) : Int8(0)
        )
    else
        return Move(
                get_type_id(gm_move["type"]),
                (get_type_id(gm_move["type"]) in types) ? Int8(12) : Int8(1),
                UInt8(gm_move["power"]),
                Int8(gm_move["energyGain"]),
                Int8(gm_move["cooldown"] ÷ 500),
                Int8(0),
                Int8(0),
                Int8(0),
                Int8(0),
                Int8(0),
            )
    end
end

struct Pokemon
    #These values are determined on initialization, and do not change in battle
    types::SVector{2,Int8}
    stats::Stats
    fastMove::Move
    chargedMoves::SVector{2,Move}

    #These values are initialized, but change throughout the battle
    hp::Int16                 #Initially hp stat of mon
    energy::Int8              #Initially 0
    fastMoveCooldown::Int8   #Initially based on fast move
end

function vectorize(mon::Pokemon)
    @inbounds return [Int8(1) in mon.types, Int8(2) in mon.types, Int8(3) in mon.types, Int8(4) in mon.types,
        Int8(5) in mon.types, Int8(6) in mon.types, Int8(7) in mon.types, Int8(8) in mon.types,
        Int8(9) in mon.types, Int8(10) in mon.types, Int8(11) in mon.types, Int8(12) in mon.types,
        Int8(13) in mon.types, Int8(14) in mon.types, Int8(15) in mon.types, Int8(16) in mon.types,
        Int8(17) in mon.types, Int8(18) in mon.types, mon.stats.attack, mon.stats.defense,
        mon.stats.hitpoints, Int8(1) == mon.fastMove.moveType,
        Int8(2) == mon.fastMove.moveType, Int8(3) == mon.fastMove.moveType,
        Int8(4) == mon.fastMove.moveType, Int8(5) == mon.fastMove.moveType,
        Int8(6) == mon.fastMove.moveType, Int8(7) == mon.fastMove.moveType,
        Int8(8) == mon.fastMove.moveType, Int8(9) == mon.fastMove.moveType,
        Int8(10) == mon.fastMove.moveType, Int8(11) == mon.fastMove.moveType,
        Int8(12) == mon.fastMove.moveType, Int8(13) == mon.fastMove.moveType,
        Int8(14) == mon.fastMove.moveType, Int8(15) == mon.fastMove.moveType,
        Int8(16) == mon.fastMove.moveType, Int8(17) == mon.fastMove.moveType,
        Int8(18) == mon.fastMove.moveType, mon.fastMove.stab,
        mon.fastMove.power, mon.fastMove.energy, mon.fastMove.cooldown,
        Int8(1) == mon.chargedMoves[1].moveType, Int8(2) == mon.chargedMoves[1].moveType,
        Int8(3) == mon.chargedMoves[1].moveType, Int8(4) == mon.chargedMoves[1].moveType,
        Int8(5) == mon.chargedMoves[1].moveType, Int8(6) == mon.chargedMoves[1].moveType,
        Int8(7) == mon.chargedMoves[1].moveType, Int8(8) == mon.chargedMoves[1].moveType,
        Int8(9) == mon.chargedMoves[1].moveType, Int8(10) == mon.chargedMoves[1].moveType,
        Int8(11) == mon.chargedMoves[1].moveType, Int8(12) == mon.chargedMoves[1].moveType,
        Int8(13) == mon.chargedMoves[1].moveType, Int8(14) == mon.chargedMoves[1].moveType,
        Int8(15) == mon.chargedMoves[1].moveType, Int8(16) == mon.chargedMoves[1].moveType,
        Int8(17) == mon.chargedMoves[1].moveType, Int8(18) == mon.chargedMoves[1].moveType,
        mon.chargedMoves[1].stab, mon.chargedMoves[1].power,
        mon.chargedMoves[1].energy, mon.chargedMoves[1].buffChance,
        mon.chargedMoves[1].oppAtkModifier, mon.chargedMoves[1].oppDefModifier,
        mon.chargedMoves[1].selfAtkModifier,
        mon.chargedMoves[1].selfDefModifier, Int8(1) == mon.chargedMoves[2].moveType,
        Int8(2) == mon.chargedMoves[2].moveType, Int8(3) == mon.chargedMoves[2].moveType,
        Int8(4) == mon.chargedMoves[2].moveType, Int8(5) == mon.chargedMoves[2].moveType,
        Int8(6) == mon.chargedMoves[2].moveType, Int8(7) == mon.chargedMoves[2].moveType,
        Int8(8) == mon.chargedMoves[2].moveType, Int8(9) == mon.chargedMoves[2].moveType,
        Int8(10) == mon.chargedMoves[2].moveType, Int8(11) == mon.chargedMoves[2].moveType,
        Int8(12) == mon.chargedMoves[2].moveType, Int8(13) == mon.chargedMoves[2].moveType,
        Int8(14) == mon.chargedMoves[2].moveType, Int8(15) == mon.chargedMoves[2].moveType,
        Int8(16) == mon.chargedMoves[2].moveType, Int8(17) == mon.chargedMoves[2].moveType,
        Int8(18) == mon.chargedMoves[2].moveType, mon.chargedMoves[2].stab,
        mon.chargedMoves[2].power, mon.chargedMoves[2].energy,
        mon.chargedMoves[2].buffChance, mon.chargedMoves[2].oppAtkModifier,
        mon.chargedMoves[2].oppDefModifier, mon.chargedMoves[2].selfAtkModifier,
        mon.chargedMoves[2].selfDefModifier, mon.hp, mon.energy,
        mon.fastMoveCooldown]
end


function Pokemon(i::Int64; league::String = "great", cup = "open", custom_moveset = ["none"], custom_stats = ())
    rankings = get_rankings(cup == "open" ? league : cup, league = league)
    gmid = get_gamemaster_mon_id(rankings[i]["speciesId"])
    gm = gamemaster["pokemon"][gmid]
    types = get_type_id.(convert(Array{String}, gm["types"]))
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
    attack = floor(UInt16, (atk + gm["baseStats"]["atk"]) * cpm[level] * 100)
    defense = floor(UInt16, (def + gm["baseStats"]["def"]) * cpm[level] * 100)
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
            attack *= gamemaster["settings"]["shadowAtkMult"]
            defense *= gamemaster["settings"]["shadowDefMult"]
        end
        sort!(chargedMovesAvailable)
        chargedMove1Gm = gamemaster["moves"][get_gamemaster_move_id(chargedMovesAvailable[moves[2]],)]
        chargedMove2Gm = gamemaster["moves"][get_gamemaster_move_id(chargedMovesAvailable[moves[3]],)]
        chargedMoves = [Move(chargedMove1Gm, types), Move(chargedMove2Gm, types)]
    else
        moveset = custom_moveset == ["none"] ? rankings[i]["moveset"] : custom_moveset
        fastMove = Move(moveset[1]::String, types)
        chargedMoves = [Move(moveset[2]::String, types), Move(moveset[3]::String, types)]
    end
    return Pokemon(
        types,
        stats,
        fastMove,
        chargedMoves,
        hitpoints,
        Int8(0),
        fastMove.cooldown,
    )
end

function Pokemon(mon::String; league = "great", cup = "open")
    if occursin(",", mon)
        mon_arr = split(mon, ",")
        if length(mon_arr) == 4
            return Pokemon(convert_indices(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]))
        elseif length(mon_arr) == 7
            return Pokemon(convert_indices(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]),
                custom_stats = ("0", mon_arr[5], mon_arr[6], mon_arr[7]))
        elseif length(mon_arr) == 8
            return Pokemon(convert_indices(convert(String, mon_arr[1]), league = league, cup = cup),
                league = league, cup = cup, custom_moveset = convert.(String, mon_arr[2:4]),
                custom_stats = (mon_arr[5], mon_arr[6], mon_arr[7], mon_arr[8]))
        end
    else
        return Pokemon(convert_indices(mon, league = league, cup = cup),
            league = league, cup = cup)
    end
end

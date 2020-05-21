using JSON, StaticArrays

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

function Pokemon(i::Int64; league = "great")
    rankings = get_rankings(league)
    cp_limit = get_cp_limit(league)
    moves = parse.(Ref(Int64), split(rankings[i]["moveStr"], "-"))
    gmid = get_gamemaster_mon_id(rankings[i]["speciesId"])
    gm = gamemaster["pokemon"][gmid]
    types = get_type_id.(convert(Array{String}, gm["types"]))
    if league == "master"
        level, atk, def, hp = 40, 15, 15, 15
    else
        level = gm["defaultIVs"]["cp$(cp_limit)"][1]
        atk = gm["defaultIVs"]["cp$(cp_limit)"][2]
        def = gm["defaultIVs"]["cp$(cp_limit)"][3]
        hp = gm["defaultIVs"]["cp$(cp_limit)"][4]
    end
    attack = (atk + gm["baseStats"]["atk"]) * cpm[level]
    defense = (def + gm["baseStats"]["def"]) * cpm[level]
    attack *= haskey(gm, "tags") && "shadow" in gm["tags"] ?
              gamemaster["settings"]["shadowAtkMultiplier"] : 1
    defense *= haskey(gm, "tags") && "shadow" in gm["tags"] ?
               gamemaster["settings"]["shadowDefMultiplier"] : 1
    hitpoints = floor((hp + gm["baseStats"]["hp"]) * cpm[level])
    stats = Stats(attack, defense, hitpoints)
    fastMovesAvailable = gm["fastMoves"]
    sort!(fastMovesAvailable)
    fastMoveGm = gamemaster["moves"][get_gamemaster_move_id(fastMovesAvailable[moves[1]+1],)]
    fastMove = Move(
        get_type_id(fastMoveGm["type"]),
        (get_type_id(fastMoveGm["type"]) in types) ? 1.3 : 1,
        fastMoveGm["power"],
        fastMoveGm["energyGain"],
        fastMoveGm["cooldown"],
        0.0,
        0,
        0,
        0,
        0,
    )
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
    chargedMove1 = Move(
        get_type_id(chargedMove1Gm["type"]),
        (get_type_id(chargedMove1Gm["type"]) in types) ? 1.2 : 1.0,
        chargedMove1Gm["power"],
        chargedMove1Gm["energy"],
        0,
        haskey(chargedMove1Gm, "buffs") ?
        parse(Float64, chargedMove1Gm["buffApplyChance"]) : 0.0,
        haskey(
            chargedMove1Gm,
            "buffs",
        ) && chargedMove1Gm["buffTarget"] == "opponent" ?
        Int(chargedMove1Gm["buffs"][1]) : 0,
        haskey(
            chargedMove1Gm,
            "buffs",
        ) && chargedMove1Gm["buffTarget"] == "opponent" ?
        Int(chargedMove1Gm["buffs"][2]) : 0,
        haskey(
            chargedMove1Gm,
            "buffs",
        ) && chargedMove1Gm["buffTarget"] == "self" ?
        Int(chargedMove1Gm["buffs"][1]) : 0,
        haskey(
            chargedMove1Gm,
            "buffs",
        ) && chargedMove1Gm["buffTarget"] == "self" ?
        Int(chargedMove1Gm["buffs"][2]) : 0,
    )
    chargedMove2 = Move(
        get_type_id(chargedMove2Gm["type"]),
        (get_type_id(chargedMove2Gm["type"]) in types) ? 1.3 : 1,
        chargedMove2Gm["power"],
        chargedMove2Gm["energy"],
        0,
        haskey(chargedMove2Gm, "buffs") ?
        parse(Float64, chargedMove2Gm["buffApplyChance"]) : 0.0,
        haskey(
            chargedMove2Gm,
            "buffs",
        ) && chargedMove2Gm["buffTarget"] == "opponent" ?
        Int(chargedMove2Gm["buffs"][1]) : 0,
        haskey(
            chargedMove2Gm,
            "buffs",
        ) && chargedMove2Gm["buffTarget"] == "opponent" ?
        Int(chargedMove2Gm["buffs"][2]) : 0,
        haskey(
            chargedMove2Gm,
            "buffs",
        ) && chargedMove2Gm["buffTarget"] == "self" ?
        Int(chargedMove2Gm["buffs"][1]) : 0,
        haskey(
            chargedMove2Gm,
            "buffs",
        ) && chargedMove2Gm["buffTarget"] == "self" ?
        Int(chargedMove2Gm["buffs"][2]) : 0,
    )
    chargedMoves = [chargedMove1, chargedMove2]
    toString = rankings[i]["speciesId"] * "," * fastMovesAvailable[moves[1]+1] *
               "," * chargedMovesAvailable[moves[2]] * "," *
               chargedMovesAvailable[moves[3]]
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

struct Team
    #These values are initialized, but change throughout the battle
    mons::SVector{3,Pokemon}
    buffs::StatBuffs         #Initially 0, 0
    switchCooldown::Int64    #Initially 0
    shields::Int8            #Initially 2
    active::Int64            #Initially 1 (the lead)
    shielding::Bool          #Initially random
end

Team(mons::Array{Int64}; league = "great") =
    Team(Pokemon.(mons, league = league), StatBuffs(0, 0), 0, 2, 1, rand(Bool))

Team(mons::Array{String}; league = "great") =
    Team(convert_indices.(mons, league = league), league = league)

struct ChargedAction
    move::Move
    charge::Float64
end

struct SwitchAction
    pokemon::Int8
    time::Int16
end

struct State
    teams::SVector{2,Team}
    agent::Int64
    chargedMovePending::ChargedAction
    switchPending::SwitchAction
end

State(team1::Team, team2::Team) = State(
    [team1, team2],
    1,
    ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 1), 0),
    SwitchAction(0, 0),
)

State(teams::Array{Int64}; league = "great") = State(
    [
     Team(
         Pokemon.(teams[1:(length(teams)÷2)], league = league),
         StatBuffs(0, 0),
         0,
         2,
         1,
         rand(Bool),
     ),
     Team(
         Pokemon.(
             teams[(length(teams)÷2+1):length(teams)],
             league = league,
         ),
         StatBuffs(0, 0),
         0,
         2,
         1,
         rand(Bool),
     ),
    ],
    1,
    ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 1), 0),
    SwitchAction(0, 0),
)

State(teams::Array{String}; league = "great") =
    State(convert_indices.(teams, league = league), league = league)

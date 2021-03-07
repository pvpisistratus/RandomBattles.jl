using StaticArrays, Setfield

struct Stats
    attack::UInt16
    defense::UInt16
    hitpoints::Int16
end

struct Pokemon
    #These values are determined on initialization, and do not change in battle
    typing::Int8
    stats::Stats
    fastMove::UInt8
    chargedMoves::SVector{2,UInt8}

    #These values are initialized, but change throughout the battle
    hp::Int16                 #Initially hp stat of mon
    energy::Int8              #Initially 0
end

function vectorize(mon::Pokemon)
    @inbounds return [Int8(1) in typings[mon.typing], Int8(2) in typings[mon.typing],
        Int8(3) in typings[mon.typing], Int8(4) in typings[mon.typing],
        Int8(5) in typings[mon.typing], Int8(6) in typings[mon.typing],
        Int8(7) in typings[mon.typing], Int8(8) in typings[mon.typing],
        Int8(9) in typings[mon.typing], Int8(10) in typings[mon.typing],
        Int8(11) in typings[mon.typing], Int8(12) in typings[mon.typing],
        Int8(13) in typings[mon.typing], Int8(14) in typings[mon.typing],
        Int8(15) in typings[mon.typing], Int8(16) in typings[mon.typing],
        Int8(17) in typings[mon.typing], Int8(18) in typings[mon.typing],
        mon.stats.attack, mon.stats.defense, mon.fastMove,
        mon.chargedMoves[1], mon.chargedMoves[2], mon.hp, mon.energy]
end


function Pokemon(i::Int64; league::String = "great", cup = "open", custom_moveset = ["none"], custom_stats = ())
    rankings = get_rankings(cup == "open" ? league : cup, league = league)
    gmid = get_gamemaster_mon_id(rankings[i]["speciesId"])
    gm = gamemaster["pokemon"][gmid]
    typing = Int8(findfirst(x -> x == sort(get_type_id.(convert(Array{String}, gm["types"]))), typings))
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
        fastMove = get_fast_move_id(fastMovesAvailable[moves[1]+1])
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
        chargedMove1Gm = get_charged_move_id(chargedMovesAvailable[moves[2]])
        chargedMove2Gm = get_charged_move_id(chargedMovesAvailable[moves[3]])
        chargedMoves = [chargedMove1Gm, chargedMove2Gm]
    else
        moveset = custom_moveset == ["none"] ? rankings[i]["moveset"] : custom_moveset
        fastMove = get_fast_move_id(moveset[1]::String)
        chargedMoves = [get_charged_move_id(moveset[2]::String), get_charged_move_id(moveset[3]::String)]
    end
    return Pokemon(
        typing,
        stats,
        fastMove,
        chargedMoves,
        hitpoints,
        Int8(0),
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

function Setfield.:setindex(arr::StaticArrays.SVector{3, Pokemon}, p::Pokemon, i::Int8)
    return setindex(arr, p, Int64(i))
end

using Setfield, Match

get_other_agent(agent::Int8) = agent == Int8(1) ? Int8(2) : Int8(1)

switch_agent(state::BattleState) = @set state.agent = get_other_agent(state.agent)

function get_gamemaster_mon_id(name::String)
    for i = 1:length(gamemaster["pokemon"])
        if gamemaster["pokemon"][i]["speciesId"] == name
            return i
        end
    end
end

function get_gamemaster_move_id(name::String)
    for i = 1:length(gamemaster["moves"])
        if gamemaster["moves"][i]["moveId"] == name
            return i
        end
    end
end

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

function convert_indices(
    name::String;
    league::String = "great",
    cup = "open"
)
    rankings = get_rankings(cup == "open" ? league : cup, league = league)
    ranking = 0
    for i = 1:length(rankings)
        if rankings[i]["speciesId"] == name
            ranking = i
        end
    end
    return ranking
end;

function silph_to_pvpoke(name::String)
    name = lowercase(name)
    name = replace(name, "-" => "_")
    name = replace(name, "_normal" => "")
    name = replace(name, "mr. " => "mr_")
    name = replace(name, "ho-oh" => "ho_oh")
    name = replace(name, "alola" => "alolan")
    name = replace(name, "galar" => "galarian")
    name = replace(name, "sunshine" => "sunny")
    name = replace(name, "porygon-z" => "porygon_z")
    name = replace(name, "basculin_red" => "basculin")
    name = replace(name, "basculin_blue" => "basculin")
    name = replace(name, "darmanitan" => "darmanitan_standard")
    name = replace(name, "gastrodon_blue" => "gastrodon_west_sea")
    name = replace(name, "gastrodon_pink" => "gastrodon_east_sea")
    name = replace(name, "sirfetch'd" => "sirfetchd")
    return name
end;

function get_min_score(state::BattleState)
    return 0.5 * (state.teams[2].mons[1].stats.hitpoints -
      state.teams[2].mons[1].hp +
      state.teams[2].mons[2].stats.hitpoints -
      state.teams[2].mons[2].hp +
      state.teams[2].mons[3].stats.hitpoints -
      state.teams[2].mons[3].hp) /
     (state.teams[2].mons[1].stats.hitpoints +
      state.teams[2].mons[2].stats.hitpoints +
      state.teams[2].mons[3].stats.hitpoints)
end

function get_max_score(state::BattleState)
    return 0.5 + (0.5 * (state.teams[1].mons[1].hp + state.teams[1].mons[2].hp +
         state.teams[1].mons[3].hp) /
        (state.teams[1].mons[1].stats.hitpoints +
         state.teams[1].mons[2].stats.hitpoints +
         state.teams[1].mons[3].stats.hitpoints))
end

function get_battle_score(state::BattleState)
    if typeof(state) == IndividualBattleState
        return (0.5 * (state.teams[1].mons[1].hp) /
            (state.teams[1].mons[1].stats.hitpoints)) +
           (0.5 * (state.teams[2].mons[1].stats.hitpoints -
             state.teams[2].mons[1].hp) /
            (state.teams[2].mons[1].stats.hitpoints))
    else
        return get_min_score(state) + get_max_score(state) - 0.5
    end
end

function step_timers(state::BattleState)
    next_state = @set state.teams[1].switchCooldown = max(Int8(0), state.teams[1].switchCooldown - Int8(1))
    next_state = @set next_state.teams[1].mons[next_state.teams[1].active].fastMoveCooldown = max(Int8(0),
        state.teams[1].mons[state.teams[1].active].fastMoveCooldown - Int8(1))
    next_state = @set next_state.teams[2].switchCooldown = max(Int8(0), next_state.teams[2].switchCooldown - Int8(1))
    next_state = @set next_state.teams[2].mons[next_state.teams[2].active].fastMoveCooldown = max(Int8(0),
        state.teams[2].mons[state.teams[2].active].fastMoveCooldown - Int8(1))
    return next_state
end

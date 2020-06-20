using Setfield, Match

get_other_agent(agent::Int64) = agent == 1 ? agent = 2 : agent = 1

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
        "normal"   => 1
        "fighting" => 2
        "flying"   => 3
        "poison"   => 4
        "ground"   => 5
        "rock"     => 6
        "bug"      => 7
        "ghost"    => 8
        "steel"    => 9
        "fire"     => 10
        "water"    => 11
        "grass"    => 12
        "electric" => 13
        "psychic"  => 14
        "ice"      => 15
        "dragon"   => 16
        "dark"     => 17
        "fairy"    => 18
        _          => 19
    end
    return type_id
end

function convert_indices(
    name::String;
    league::String = "great",
    cup = "open"
)
    rankings = get_rankings(cup == "open" ? league : cup)
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
    name = replace(name, "sunshine" => "sunny")
    name = replace(name, "porygon-z" => "porygon_z")
    name = replace(name, "basculin_red" => "basculin")
    name = replace(name, "basculin_blue" => "basculin")
    name = replace(name, "darmanitan" => "darmanitan_standard")
    name = replace(name, "gastrodon_blue" => "gastrodon_west_sea")
    name = replace(name, "gastrodon_pink" => "gastrodon_east_sea")
    return name
end;

function get_battle_score(state::BattleState)
    if typeof(state) == IndividualBattleState
        return (0.5 * (state.teams[1].mons[1].hp) /
            (state.teams[1].mons[1].stats.hitpoints)) +
           (0.5 * (state.teams[2].mons[1].stats.hitpoints -
             state.teams[2].mons[1].hp) /
            (state.teams[2].mons[1].stats.hitpoints))
    else
        return (0.5 * (state.teams[1].mons[1].hp + state.teams[1].mons[2].hp +
             state.teams[1].mons[3].hp) /
            (state.teams[1].mons[1].stats.hitpoints +
             state.teams[1].mons[2].stats.hitpoints +
             state.teams[1].mons[3].stats.hitpoints)) +
           (0.5 * (state.teams[2].mons[1].stats.hitpoints -
             state.teams[2].mons[1].hp +
             state.teams[2].mons[2].stats.hitpoints -
             state.teams[2].mons[2].hp +
             state.teams[2].mons[3].stats.hitpoints -
             state.teams[2].mons[3].hp) /
            (state.teams[2].mons[1].stats.hitpoints +
             state.teams[2].mons[2].stats.hitpoints +
             state.teams[2].mons[3].stats.hitpoints))
    end
end

function step_timers(state::BattleState)
    next_state = @set state.teams[1].switchCooldown = max(
        0,
        state.teams[1].switchCooldown - 500,
    )
    next_state = @set next_state.teams[1].mons[next_state.teams[1].active].fastMoveCooldown = max(
        0,
        state.teams[1].mons[state.teams[1].active].fastMoveCooldown - 500,
    )
    next_state = @set next_state.teams[2].switchCooldown = max(
        0,
        next_state.teams[2].switchCooldown - 500,
    )
    next_state = @set next_state.teams[2].mons[next_state.teams[2].active].fastMoveCooldown = max(
        0,
        next_state.teams[2].mons[next_state.teams[2].active].fastMoveCooldown - 500,
    )

    return next_state
end

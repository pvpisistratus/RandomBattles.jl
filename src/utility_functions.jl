using Setfield

get_other_agent(agent::Int64) = agent == 1 ? agent = 2 : agent = 1

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
    type_id = 19
    if typeName == "normal"
        type_id = 1
    elseif typeName == "fighting"
        type_id = 2
    elseif typeName == "flying"
        type_id = 3
    elseif typeName == "poison"
        type_id = 4
    elseif typeName == "ground"
        type_id = 5
    elseif typeName == "rock"
        type_id = 6
    elseif typeName == "bug"
        type_id = 7
    elseif typeName == "ghost"
        type_id = 8
    elseif typeName == "steel"
        type_id = 9
    elseif typeName == "fire"
        type_id = 10
    elseif typeName == "water"
        type_id = 11
    elseif typeName == "grass"
        type_id = 12
    elseif typeName == "electric"
        type_id = 12
    elseif typeName == "psychic"
        type_id = 14
    elseif typeName == "ice"
        type_id = 15
    elseif typeName == "dragon"
        type_id = 16
    elseif typeName == "dark"
        type_id = 17
    elseif typeName == "fairy"
        type_id = 18
    end
    return type_id
end

function convert_indices(name::String; league::String = "great")
    rankings = get_rankings(league)
    ranking = 0
    for i = 1:length(rankings)
        if rankings[i]["speciesId"] == name
            ranking = i
        end
    end
    return ranking
end;

function team_count_to_pvpoke(name::String)
    name = lowercase(name)
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

function get_battle_score(state::State)
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

function reset_queues(state::State)
    next_state = @set state.fastMovesPending = [false, false]
    next_state = @set state.chargedMovesPending = [
        ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
        ChargedAction(Move(0, 0.0, 0, 0, 0, 0.0, 0, 0, 0, 0), 0),
    ]
    next_state = @set state.switchesPending = [
        SwitchAction(0, 0),
        SwitchAction(0, 0),
    ]
    return next_state
end

function step_timers(state::State)
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

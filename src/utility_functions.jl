using Setfield, Match

get_other_agent(agent::Int8) = agent == Int8(1) ? Int8(2) : Int8(1)

switch_agent(state::State) = @set state.agent = get_other_agent(state.agent)
switch_agent(state::IndividualBattleState) = @set state.agent = get_other_agent(state.agent)

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
            return Int8(i)
        end
    end
end

function get_fast_move_id(name::String)
    j = 1
    for i = 1:length(gamemaster["moves"])
        gamemaster["moves"][i]["moveId"] == name && return Int8(j)
        j += gamemaster["moves"][i]["energy"] == 0 ? 1 : 0
    end
    return Int8(0)
end

function get_charged_move_id(name::String)
    name == "NONE" && return Int8(0)
    j = 1
    for i = 1:length(gamemaster["moves"])
        gamemaster["moves"][i]["moveId"] == name && return Int8(j)
        j += gamemaster["moves"][i]["energy"] != 0 ? 1 : 0
    end
    return Int8(0)
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

function get_min_score(state::State)
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

function get_max_score(state::State)
    return 0.5 + (0.5 * (state.teams[1].mons[1].hp + state.teams[1].mons[2].hp +
         state.teams[1].mons[3].hp) /
        (state.teams[1].mons[1].stats.hitpoints +
         state.teams[1].mons[2].stats.hitpoints +
         state.teams[1].mons[3].stats.hitpoints))
end

function get_battle_score(state::IndividualBattleState)
    return (0.5 * (state.teams[1].mon.hp) / (state.teams[1].mon.stats.hitpoints)) +
        (0.5 * (state.teams[2].mon.stats.hitpoints - state.teams[2].mon.hp) /
        (state.teams[2].mon.stats.hitpoints))
end

function get_battle_score(state::State)
    return get_min_score(state) + get_max_score(state) - 0.5
end

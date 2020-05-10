using Setfield

function get_gamemaster_mon_id(name::String, gamemaster::Dict{String,Any})
    for i = 1:length(gamemaster["pokemon"])
        if gamemaster["pokemon"][i]["speciesId"] == name
            return i
        end
    end
end

function get_gamemaster_move_id(name::String, gamemaster::Dict{String,Any})
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

function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    return type_effectiveness[defenderTypes[1], moveType] *
           type_effectiveness[defenderTypes[2], moveType]
end

function calculate_damage(
    attacker::Pokemon,
    atkBuff::Int8,
    defender::Pokemon,
    defBuff::Int8,
    move::Move,
    charge::Float64,
)
    return floor(move.power * move.stab *
                 ((attacker.stats.attack * 4.0) / (4 - atkBuff) /
                  (defender.stats.defense * (4 + defBuff) / 4.0)) *
                 get_effectiveness(defender.types, move.moveType) * charge *
                 0.5 * 1.3) + 1
end

function apply_buffs(state::State)
    receiver = state.agent
    sender = (receiver == 1) ? 2 : 1
    if rand(Uniform(0, 1)) < state.chargedMovePending.move.buffChance
        state = @set state.teams[receiver].buffs.atk = clamp(
            state.teams[receiver].buffs.atk +
            state.chargedMovePending.move.oppAtkModifier,
            -4,
            4,
        )
        state = @set state.teams[receiver].buffs.def = clamp(
            state.teams[receiver].buffs.def +
            state.chargedMovePending.move.oppDefModifier,
            -4,
            4,
        )
        state = @set state.teams[sender].buffs.atk = clamp(
            state.teams[sender].buffs.atk +
            state.chargedMovePending.move.selfAtkModifier,
            -4,
            4,
        )
        state = @set state.teams[sender].buffs.def = clamp(
            state.teams[sender].buffs.def +
            state.chargedMovePending.move.selfDefModifier,
            -4,
            4,
        )
    end
    return state
end

function convert_indices(name, rankings)
    ranking = Int16(0)
    for i = 1:length(rankings)
        if rankings[i]["speciesId"] == name
            ranking = Int16(i)
        end
    end
    return ranking
end;

using Setfield

function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    return type_effectiveness[defenderTypes[1], moveType] *
           type_effectiveness[defenderTypes[2], moveType]
end

function get_buff_modifier(buff::Int8)
    return buff > 0 ?
           (gamemaster["settings"]["buffDivisor"] + buff) /
           gamemaster["settings"]["buffDivisor"] :
           gamemaster["settings"]["buffDivisor"] /
           (gamemaster["settings"]["buffDivisor"] - buff)
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
                 ((attacker.stats.attack * get_buff_modifier(atkBuff)) /
                  (defender.stats.defense * get_buff_modifier(defBuff))) *
                 get_effectiveness(defender.types, move.moveType) * charge *
                 0.5 * 1.3) + 1
end

function fast_move(state::State)
    state = @set state.teams[state.agent].mons[state.teams[state.agent].active].fastMoveCooldown = state.teams[state.agent].mons[state.teams[state.agent].active].fastMove.cooldown
    state = @set state.teams[state.agent].mons[state.teams[state.agent].active].energy += state.teams[state.agent].mons[state.teams[state.agent].active].fastMove.energy
    state = @set state.teams[get_other_agent(state.agent)].mons[state.teams[get_other_agent(state.agent)].active].hp = max(
        0,
        state.teams[get_other_agent(state.agent)].mons[state.teams[get_other_agent(state.agent)].active].hp -
        calculate_damage(
            state.teams[state.agent].mons[state.teams[state.agent].active],
            state.teams[state.agent].buffs.atk,
            state.teams[get_other_agent(state.agent)].mons[state.teams[get_other_agent(state.agent)].active],
            state.teams[get_other_agent(state.agent)].buffs.def,
            state.teams[state.agent].mons[state.teams[state.agent].active].fastMove,
            1.0,
        ),
    )
    return state
end

function queue_charged_move(state::State, move::Int64)
    agent = state.agent
    attackingTeam = state.teams[agent]
    attacker = attackingTeam.mons[attackingTeam.active]
    state = @set state.chargedMovesPending[agent] = ChargedAction(
        attacker.chargedMoves[move],
        1,
    )
    return state
end

function queue_switch(state::State, switchTo::Int64; time::Int64 = 0)
    state = @set state.switchesPending[state.agent] = SwitchAction(
        switchTo,
        time,
    )
    return state
end

function get_cmp(state::State)
    chargedActions = state.chargedMovesPending
    cmp = 0
    if chargedActions[1].charge == 0 && chargedActions[2].charge == 0
        cmp = 0
    elseif chargedActions[1].charge != 0 && chargedActions[2].charge == 0
        cmp = 1
    elseif chargedActions[1].charge == 0 && chargedActions[2].charge != 0
        cmp = 2
    else
        attack1 = state.teams[1].mons[state.teams[1].active].stats.attack
        attack2 = state.teams[2].mons[state.teams[2].active].stats.attack
        if attack1 > attack2
            cmp = 1
        elseif attack2 < attack1
            cmp = 2
        else
            cmp = rand(1:2)
        end
    end
    return cmp
end

function apply_buffs(state::State, cmp::Int64)
    attackingTeam = state.teams[cmp]
    defendingTeam = state.teams[get_other_agent(cmp)]
    move = state.chargedMovesPending[cmp].move
    if rand(Uniform(0, 1)) < move.buffChance
        state = @set defendingTeam.buffs.atk = clamp(
            defendingTeam.buffs.atk + move.oppAtkModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
        state = @set defendingTeam.buffs.def = clamp(
            defendingTeam.buffs.def + move.oppDefModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
        state = @set attackingTeam.buffs.atk = clamp(
            attackingTeam.buffs.atk + move.selfAtkModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
        state = @set attackingTeam.buffs.def = clamp(
            attackingTeam.buffs.def + move.selfDefModifier,
            -gamemaster["settings"]["maxBuffStages"],
            gamemaster["settings"]["maxBuffStages"],
        )
    end
    return state
end

function evaluate_charged_moves(state::State)
    cmp = get_cmp(state)
    if cmp != 0
        attackingTeam = state.teams[cmp]
        attacker = attackingTeam.mons[attackingTeam.active]
        defendingTeam = state.teams[get_other_agent(cmp)]
        defender = defendingTeam.mons[defendingTeam.active]
        move = state.chargedMovesPending[cmp].move
        println(move)
        state = @set state.teams[cmp].mons[state.teams[cmp].active].energy -= move.energy
        for i = 1:2
            state = @set state.teams[i].switchCooldown = max(
                0,
                state.teams[i].switchCooldown - 10000,
            )
        end
        if defendingTeam.shields > 0 && defendingTeam.shielding
            state = @set state.teams[get_other_agent(cmp)].shields -= 1
        else
            state = @set state.teams[get_other_agent(cmp)].mons[state.teams[get_other_agent(cmp)].active].hp = max(
                0,
                defender.hp - calculate_damage(
                    attacker,
                    attackingTeam.buffs.atk,
                    defender,
                    defendingTeam.buffs.def,
                    move,
                    state.chargedMovesPending[cmp].charge,
                ),
            )
        end
        state = apply_buffs(state, cmp)
    end
    return state
end

function evaluate_switches(state::State)
    for i = 1:2
        switch = state.switchesPending[i]
        if switch.pokemon != 0
            j = get_other_agent(i)
            state = @set state.teams[i].active = switch.pokemon
            state = @set state.teams[i].buffs = StatBuffs(0, 0)
            if switch.time != 0
                state = @set state.teams[j].switchCooldown = max(
                    0,
                    state.teams[j].switchCooldown - switch.time - 500,
                )
            else
                state = @set state.teams[i].switchCooldown = 60000
            end
        end
    end
    return state
end

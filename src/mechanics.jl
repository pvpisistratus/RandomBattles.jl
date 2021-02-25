using Setfield

function get_effectiveness(defenderTypes::SVector{2,Int8}, moveType::Int8)
    @inbounds return type_effectiveness[defenderTypes[1], moveType] *
            type_effectiveness[defenderTypes[2], moveType]
end

function get_buff_modifier(buff::Int8)
    @inbounds return buff == Int8(0) ? Int8(12) : (buff > Int8(0) ? Int8(12) + Int8(3) * buff : Int8(48) ÷ (Int8(4) - buff))
end

function calculate_damage(
    attacker::StaticPokemon,
    atkBuff::Int8,
    defender::StaticPokemon,
    defBuff::Int8,
    move::FastMove,
    charge::Int8,
)
    return Int16((Int64(move.power) * Int64(move.stab) *
        Int64(attacker.stats.attack) * Int64(get_buff_modifier(atkBuff)) *
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(get_buff_modifier(defBuff)) * 1_280_000_000) + 1)
end

function calculate_damage(
    attacker::StaticPokemon,
    atkBuff::Int8,
    defender::StaticPokemon,
    defBuff::Int8,
    move::ChargedMove,
    charge::Int8,
)
    return Int16((Int64(move.power) * Int64(move.stab) *
        Int64(attacker.stats.attack) * Int64(get_buff_modifier(atkBuff)) *
        floor(Int64, get_effectiveness(defender.types, move.moveType) *
        12_800) * Int64(charge) * 65) ÷ (Int64(defender.stats.defense) *
        Int64(get_buff_modifier(defBuff)) * 1_280_000_000) + 1)
end

function queue_fast_move(state::DynamicState, static_state::StaticState, agent::Int8)
    @inbounds return @set state.fastMovesPending[agent] = static_state.teams[agent].mons[state.teams[agent].active].fastMove.cooldown
end

function get_cmp(state::DynamicState, static_state::StaticState, dec::Decision)
    @inbounds charges = dec.chargedMovesPending[1].charge, dec.chargedMovesPending[2].charge
    @inbounds charges[2] == Int8(0) && return Int8(1)
    @inbounds charges[1] == Int8(0) && return Int8(2)
    @inbounds attacks = static_state.teams[1].mons[state.teams[1].active].stats.attack,
        static_state.teams[2].mons[state.teams[2].active].stats.attack
    @inbounds attacks[1] > attacks[2] && return Int8(1)
    @inbounds attacks[1] < attacks[2] && return Int8(2)
    return rand((Int8(1), Int8(2)))
end

function apply_buffs(state::DynamicState, static_state::StaticState, dec::Decision, cmp::Int8)
    next_state = state
    @inbounds move = static_state.teams[cmp].mons[state.teams[cmp].active].chargedMoves[dec.chargedMovesPending[cmp].move]
    @inbounds if rand(Int8(0):Int8(99)) < move.buffChance
        if move.opp_buffs != defaultBuff
            @inbounds next_state = @set next_state.teams[get_other_agent(cmp)].buffs += move.opp_buffs
        else
            @inbounds next_state = @set next_state.teams[cmp].buffs += move.self_buffs
        end
    end
    return next_state
end

function evaluate_fast_moves(state::DynamicState, static_state::StaticState, agent::Int8)
    next_state = state
    @inbounds next_state = @set next_state.teams[agent].mons[next_state.teams[agent].active].energy =
        min(next_state.teams[agent].mons[next_state.teams[agent].active].energy +
        static_state.teams[agent].mons[next_state.teams[agent].active].fastMove.energy, Int8(100))
    other_agent = agent == 1 ? 2 : 1
    @inbounds next_state = @set next_state.teams[other_agent].mons[next_state.teams[other_agent].active].hp = max(
        Int16(0),
        next_state.teams[other_agent].mons[next_state.teams[other_agent].active].hp -
        calculate_damage(
            static_state.teams[agent].mons[next_state.teams[agent].active],
            get_atk(next_state.teams[agent].buffs),
            static_state.teams[other_agent].mons[next_state.teams[other_agent].active],
            get_def(next_state.teams[other_agent].buffs),
            static_state.teams[agent].mons[next_state.teams[agent].active].fastMove,
            Int8(100),
        ),
    )

    return next_state
end

function evaluate_charged_moves(state::DynamicState, static_state::StaticState, dec::Decision)
    cmp = get_cmp(state, static_state, dec)
    next_state = state
    if cmp > Int8(0)
        move = static_state.teams[cmp].mons[next_state.teams[cmp].active].chargedMoves[dec.chargedMovesPending[cmp].move]
        @inbounds next_state = @set next_state.teams[cmp].mons[next_state.teams[cmp].active].energy -= move.energy
        @inbounds next_state = @set next_state.teams[1].switchCooldown = max(Int8(0), next_state.teams[1].switchCooldown - Int8(20))
        @inbounds next_state = @set next_state.teams[2].switchCooldown = max(Int8(0), next_state.teams[2].switchCooldown - Int8(20))
        other_agent = get_other_agent(cmp)
        @inbounds if next_state.teams[other_agent].shields > Int8(0) && dec.shielding[other_agent]
            @inbounds next_state = @set next_state.teams[other_agent].shields -= Int8(1)
        else
            @inbounds next_state = @set next_state.teams[other_agent].mons[next_state.teams[other_agent].active].hp = max(
                Int16(0),
                next_state.teams[get_other_agent(cmp)].mons[next_state.teams[other_agent].active].hp - calculate_damage(
                    static_state.teams[cmp].mons[next_state.teams[cmp].active],
                    get_atk(next_state.teams[cmp].buffs),
                    static_state.teams[other_agent].mons[next_state.teams[other_agent].active],
                    get_def(next_state.teams[other_agent].buffs),
                    move,
                    dec.chargedMovesPending[cmp].charge,
                ),
            )
        end
        next_state = apply_buffs(next_state, static_state, dec, cmp)
        if next_state.fastMovesPending[other_agent] != Int8(-1)
            next_state = evaluate_fast_moves(next_state, static_state, cmp)
        end
        @inbounds next_dec = @set dec.chargedMovesPending[cmp] = defaultCharge
    end
    return next_state, next_dec
end

function evaluate_switches(state::DynamicState, dec::Decision)
    next_state = state
    @inbounds if dec.switchesPending[1].pokemon != Int8(0)
        @inbounds next_state = @set next_state.teams[1].active = dec.switchesPending[1].pokemon
        @inbounds next_state = @set next_state.teams[1].buffs = defaultBuff
        @inbounds if dec.switchesPending[1].time != Int8(0)
            @inbounds next_state = @set next_state.teams[2].switchCooldown = max(
                Int8(0),
                next_state.teams[2].switchCooldown - dec.switchesPending[1].time - Int8(1),
            )
        else
            @inbounds next_state = @set next_state.teams[1].switchCooldown = Int8(120)
        end
        @inbounds next_state = @set next_state.fastMovesPending[1] = Int8(-1)
    end

    @inbounds if dec.switchesPending[2].pokemon != Int8(0)
        @inbounds next_state = @set next_state.teams[2].active = dec.switchesPending[2].pokemon
        @inbounds next_state = @set next_state.teams[2].buffs = defaultBuff
        @inbounds if dec.switchesPending[2].time != Int8(0)
            @inbounds next_state = @set next_state.teams[1].switchCooldown = max(
                Int8(0),
                next_state.teams[1].switchCooldown - dec.switchesPending[2].time - Int8(1),
            )
        else
            @inbounds next_state = @set next_state.teams[2].switchCooldown = Int8(120)
        end
        @inbounds next_state = @set next_state.fastMovesPending[2] = Int8(-1)
    end
    return next_state
end

function step_timers(state::DynamicState)
    next_state = state
    @inbounds if state.fastMovesPending[1] != Int8(-1)
        @inbounds next_state = @set next_state.fastMovesPending[1] -= Int8(1)
    end
    @inbounds if state.fastMovesPending[2] != Int8(-1)
        @inbounds next_state = @set next_state.fastMovesPending[2] -= Int8(1)
    end
    @inbounds if state.teams[1].switchCooldown != Int8(0)
        @inbounds next_state = @set next_state.teams[1].switchCooldown -= Int8(1)
    end
    @inbounds if state.teams[2].switchCooldown != Int8(0)
        @inbounds next_state = @set next_state.teams[2].switchCooldown -= Int8(1)
    end
    return next_state
end

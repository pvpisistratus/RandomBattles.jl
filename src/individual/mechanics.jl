function get_cmp(static_state::StaticIndividualState, team1throwing::Bool, team2throwing::Bool)
    !team1throwing && !team2throwing && return Int8(0), Int8(0)
    !team2throwing && return Int8(1), Int8(0)
    !team1throwing && return Int8(2), Int8(0)
    @inbounds static_state.teams[1].stats.attack > static_state.teams[2].stats.attack && return Int8(1), Int8(2)
    @inbounds static_state.teams[1].stats.attack < static_state.teams[2].stats.attack && return Int8(2), Int8(1)
    cmp = rand((Int8(1), Int8(2)))
    return cmp, (cmp == Int8(1) ? Int8(2) : Int8(1))
end

function evaluate_fast_moves(state::DynamicIndividualState, static_state::StaticIndividualState, agent1::Bool, agent2::Bool)
    @inbounds if defaultBuff == state.teams[1].buffs == state.teams[2].buffs
        @inbounds return DynamicIndividualState(@SVector[DynamicIndividualPokemon(
            agent2 ? max(Int16(0), state.teams[1].hp - static_state.teams[2].damage_matrix[1]) : state.teams[1].hp,
            agent1 ? min(state.teams[1].energy + static_state.teams[1].fastMove.energy, Int8(100)) : state.teams[1].energy,
            defaultBuff, state.teams[1].shields), DynamicIndividualPokemon(
            agent1 ? max(Int16(0), state.teams[2].hp - static_state.teams[1].damage_matrix[1]) : state.teams[2].hp,
            agent2 ? min(state.teams[2].energy + static_state.teams[2].fastMove.energy, Int8(100)) : state.teams[2].energy,
            defaultBuff, state.teams[2].shields)], state.fastMovesPending)
    else
        @inbounds return DynamicIndividualState(@SVector[DynamicIndividualPokemon(agent2 ? max(Int16(0),
                state.teams[1].hp - calculate_damage(
                static_state.teams[2].stats.attack, get_atk(state.teams[2].buffs),
                static_state.teams[1], get_def(state.teams[1].buffs),
                static_state.teams[2].fastMove)) : state.teams[1].hp,
            agent1 ? min(state.teams[1].energy + static_state.teams[1].fastMove.energy, Int8(100)) : state.teams[1].energy,
            state.teams[1].buffs, state.teams[1].shields), DynamicIndividualPokemon(agent1 ? max(Int16(0),
                state.teams[2].hp - calculate_damage(
                static_state.teams[1].stats.attack, get_atk(state.teams[1].buffs),
                static_state.teams[2], get_def(state.teams[2].buffs),
                static_state.teams[1].fastMove)) : state.teams[2].hp,
            agent2 ? min(state.teams[2].energy + static_state.teams[2].fastMove.energy, Int8(100)) : state.teams[2].energy,
            state.teams[2].buffs, state.teams[2].shields)], state.fastMovesPending)
    end
end

function evaluate_charged_moves(state::DynamicIndividualState, static_state::StaticIndividualState, cmp::Int8, move_id::Int8, charge::Int8, shielding::Bool, buffs_applied::Bool)
    @inbounds if defaultBuff == state.teams[1].buffs == state.teams[2].buffs
        if cmp == Int8(1)
            @inbounds return DynamicIndividualState(@SVector[
                DynamicIndividualPokemon(state.teams[1].hp,
                    min(state.teams[1].energy - static_state.teams[1].chargedMoves[move_id].energy, Int8(0)),
                buffs_applied ? static_state.teams[1].chargedMoves[move_id].self_buffs : defaultBuff, state.teams[1].shields),
                DynamicIndividualPokemon(shielding ? state.teams[2].hp : max(Int16(0),
                    state.teams[2].hp - static_state.teams[1].damage_matrix[move_id]), state.teams[2].energy,
                buffs_applied ? static_state.teams[1].chargedMoves[move_id].opp_buffs : defaultBuff,
                shielding ? state.teams[2].shields - Int8(1) : state.teams[2].shields)], state.fastMovesPending)
        else
            @inbounds return DynamicIndividualState(@SVector[
                DynamicIndividualPokemon(shielding ? state.teams[1].hp : max(Int16(0),
                    state.teams[1].hp - static_state.teams[2].damage_matrix[move_id],
                ), state.teams[1].energy,
                buffs_applied ? static_state.teams[2].chargedMoves[move_id].opp_buffs : defaultBuff,
                shielding ? state.teams[1].shields - Int8(1) : state.teams[1].shields),
                DynamicIndividualPokemon(state.teams[2].hp,
                    min(state.teams[2].energy - static_state.teams[2].chargedMoves[move_id].energy, Int8(0)),
                buffs_applied ? static_state.teams[2].chargedMoves[move_id].self_buffs : defaultBuff,
                state.teams[2].shields)], state.fastMovesPending)
        end
    elseif cmp == Int8(1)
        @inbounds return DynamicIndividualState(@SVector[
            DynamicIndividualPokemon(state.teams[1].hp,
                min(state.teams[1].energy - static_state.teams[1].chargedMoves[move_id].energy, Int8(0)),
            buffs_applied ? state.teams[1].buffs + static_state.teams[1].chargedMoves[move_id].self_buffs : state.teams[1].buffs,
            state.teams[1].shields),
            DynamicIndividualPokemon(shielding ? state.teams[2].hp : max(
                Int16(0),
                state.teams[2].hp -
                calculate_damage(
                    static_state.teams[1].stats.attack, get_atk(state.teams[1].buffs),
                    static_state.teams[2], get_def(state.teams[2].buffs),
                    static_state.teams[1].chargedMoves[move_id], charge,
                ),
            ), state.teams[2].energy,
            buffs_applied ? (state.teams[2].buffs + static_state.teams[1].chargedMoves[move_id].opp_buffs) : state.teams[2].buffs,
            shielding ? state.teams[2].shields - Int8(1) : state.teams[2].shields)], state.fastMovesPending)
    else
        @inbounds return DynamicIndividualState(@SVector[
            DynamicIndividualPokemon(shielding ? state.teams[1].hp : max(
                Int16(0),
                state.teams[1].hp -
                calculate_damage(
                    static_state.teams[2].stats.attack,
                    get_atk(state.teams[2].buffs),
                    static_state.teams[1],
                    get_def(state.teams[1].buffs),
                    static_state.teams[2].chargedMoves[move_id],
                    charge,
                ),
            ), state.teams[1].energy,
            buffs_applied ? (state.teams[1].buffs + static_state.teams[2].chargedMoves[move_id].opp_buffs) : state.teams[1].buffs,
            shielding ? state.teams[1].shields - Int8(1) : state.teams[1].shields),
            DynamicIndividualPokemon(state.teams[2].hp,
                min(state.teams[2].energy - static_state.teams[2].chargedMoves[move_id].energy, Int8(0)),
            buffs_applied ? state.teams[2].buffs + static_state.teams[2].chargedMoves[move_id].self_buffs : state.teams[2].buffs,
            state.teams[2].shields)], state.fastMovesPending)
    end
end

function step_timers(state::DynamicIndividualState, fmCooldown1::Int8, fmCooldown2::Int8)
    @inbounds return DynamicIndividualState(state.teams,
        @SVector[fmCooldown1 == Int8(0) ? max(Int8(-1), state.fastMovesPending[1] - Int8(1)) : fmCooldown1 - Int8(1),
            fmCooldown2 == Int8(0) ? max(Int8(-1), state.fastMovesPending[2] - Int8(1)) : fmCooldown2 - Int8(1)])
end

function get_battle_score(state::DynamicIndividualState, static_state::StaticIndividualState)
    return (0.5 * (state.teams[1].hp) / (static_state.teams[1].stats.hitpoints)) +
        (0.5 * (static_state.teams[2].stats.hitpoints - state.teams[2].hp) /
        (static_state.teams[2].stats.hitpoints))
end

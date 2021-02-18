function diff(p1::DynamicPokemon, p2::DynamicPokemon)
    if p1.hp != p2.hp
        println("Hp changed from $(p1.hp) to $(p2.hp)")
    end
    if p1.energy != p2.energy
        println("Energy changed from $(p1.energy) to $(p2.energy)")
    end
end

function diff(b1::StatBuffs, b2::StatBuffs)
    if get_atk(b1) != get_atk(b2)
        println("Attack changed from $(get_atk(b1)) to $(get_atk(b2))")
    end
    if get_def(b1) != get_def(b2)
        println("Defense changed from $(get_def(b1)) to $(get_def(b2))")
    end
end

function diff(t1::DynamicTeam, t2::DynamicTeam)
    if t1.active != t2.active
        println("Active mon changed from $(t1.active) to $(t2.active)")
    end
    if t1.shields != t2.shields
        println("Shields changed from $(t1.shields) to $(t2.shields)")
    end
    if t1.switchCooldown != t2.switchCooldown
        println("Switch Cooldown changed from $(t1.switchCooldown) to $(t2.switchCooldown)")
    end
    if t1.buffs != t2.buffs
        diff(t1.buffs, t2.buffs)
    end
    if t1.mons[1] != t2.mons[1]
        println("Mon 1: ")
        diff(t1.mons[1], t2.mons[1])
    end
    if t1.mons[2] != t2.mons[2]
        println("Mon 2: ")
        diff(t1.mons[2], t2.mons[2])
    end
    if t1.mons[3] != t2.mons[3]
        println("Mon 3: ")
        diff(t1.mons[3], t2.mons[3])
    end
end

function diff(s1::IndividualBattleState, s2::IndividualBattleState)
    if s1.agent != s2.agent
        println("Agent changed from $(s1.agent) to $(s2.agent)")
    end
    if s1.teams[1] != s2.teams[1]
        println("Team 1: ")
        diff(s1.teams[1], s2.teams[1])
    end
    if s1.teams[2] != s2.teams[2]
        println("Team 2: ")
        diff(s1.teams[2], s2.teams[2])
    end
end

function diff(s1::DynamicState, s2::DynamicState)
    if s1.agent != s2.agent
        println("Agent changed from $(s1.agent) to $(s2.agent)")
    end
    if s1.teams[1] != s2.teams[1]
        println("Team 1: ")
        diff(s1.teams[1], s2.teams[1])
    end
    if s1.teams[2] != s2.teams[2]
        println("Team 2: ")
        diff(s1.teams[2], s2.teams[2])
    end
    if s1.fastMovesPending[1] != s2.fastMovesPending[1]
        println("Agent 1's fast move queue changed from $(s1.fastMovesPending[1]) to $(s2.fastMovesPending[1])")
    end
    if s1.fastMovesPending[2] != s2.fastMovesPending[2]
        println("Agent 2's fast move queue changed from $(s1.fastMovesPending[2]) to $(s2.fastMovesPending[2])")
    end
end

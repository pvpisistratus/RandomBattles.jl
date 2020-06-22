function diff(p1::RandomBattles.Pokemon, p2::RandomBattles.Pokemon)
    if p1.hp != p2.hp
        println("Hp changed from $(p1.hp) to $(p2.hp)")
    end
    if p1.energy != p2.energy
        println("Energy changed from $(p1.energy) to $(p2.energy)")
    end
    if p1.fastMoveCooldown != p2.fastMoveCooldown
        println("Fast Move Cooldown changed from $(p1.fastMoveCooldown) to $(p2.fastMoveCooldown)")
    end
end

function diff(b1::RandomBattles.StatBuffs, b2::RandomBattles.StatBuffs)
    if b1.atk != s2.atk
        println("Attack changed from $(s1.atk) to $(s2.atk)")
    end
    if b1.def != s2.def
        println("Defense changed from $(s1.def) to $(s2.def)")
    end
end

function diff(t1::Team, t2::Team)
    if t1.active != t2.active
        println("Active mon changed from $(t1.active) to $(t2.active)")
    end
    if t1.shields != t2.shields
        println("Shields changed from $(t1.shields) to $(t2.shields)")
    end
    if t1.shielding != t2.shielding
        println("Shielding changed from $(t1.shielding) to $(t2.shielding)")
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

function diff(s1::BattleState, s2::BattleState)
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

function diff(t1::DynamicIndividualPokemon, t2::DynamicIndividualPokemon)
    if t1.hp != t2.hp
        println("Hp changed from $(t1.hp) to $(t2.hp)")
    end
    if t1.energy != t2.energy
        println("Energy changed from $(t1.energy) to $(t2.energy)")
    end
    if t1.shields != t2.shields
        println("Shields changed from $(t1.shields) to $(t2.shields)")
    end
    if t1.buffs != t2.buffs
        diff(t1.buffs, t2.buffs)
    end
end

function diff(s1::DynamicIndividualState, s2::DynamicIndividualState)
    if s1.teams[1] != s2.teams[1]
        println("Team 1: ")
        diff(s1.teams[1], s2.teams[1])
    end
    if s1.teams[2] != s2.teams[2]
        println("Team 2: ")
        diff(s1.teams[2], s2.teams[2])
    end
end

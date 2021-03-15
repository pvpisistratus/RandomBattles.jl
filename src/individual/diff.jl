function diff(t1::DynamicIndividual, t2::DynamicIndividual)
    if t1.shields != t2.shields
        println("Shields changed from $(t1.shields) to $(t2.shields)")
    end
    if t1.buffs != t2.buffs
        diff(t1.buffs, t2.buffs)
    end
    if t1.mon != t2.mon
        println("Mon 1: ")
        diff(t1.mon, t2.mon)
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

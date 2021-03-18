"""
    Stats(attack, defense, hitpoints)

Stores the attack, defense, and hitpoints values (factoring in base and IV stats)
of a Pokemon in integers. This means that attack and defense are 100 times
larger than their real value.
"""
struct Stats
    attack::UInt16
    defense::UInt16
    hitpoints::Int16
end

"""
    StatBuffs(val)

Because the stat buffs can only be between -4 and 4 inclusive, they are collectively
stored as one 8-bit integer. Use of this constructor is not recommended. Also,
use get_atk and get_def functions for extracting individual values.
"""
struct StatBuffs
    val::UInt8
end

"""
    StatBuffs(atk, def)

Friendlier constructor for StatBuffs where attack and defense buffs can be
passed in
"""
function StatBuffs(atk::Int8, def::Int8)
    StatBuffs((clamp(atk, Int8(-4), Int8(4)) + Int8(8)) + (clamp(def, Int8(-4), Int8(4)) + Int16(8))<<Int16(4))
end

"""
    get_atk(x::StatBuffs)

Get the attack value of the StatBuffs passed in
"""
get_atk(x::StatBuffs) = Int8(x.val & 0x0F) - Int8(8)

"""
    get_def(x::StatBuffs)

Get the defense value of the StatBuffs passed in
"""
get_def(x::StatBuffs) = Int8(x.val >> 4) - Int8(8)

"""
    +(x::StatBuffs, y::StatBuffs)

Adding two StatBuffs together adds the attack and defense values, and clamps
the result between -4 and 4 inclusive.
"""
Base.:+(x::StatBuffs, y::StatBuffs) = StatBuffs(get_atk(x) + get_atk(y), get_def(x) + get_def(y))

# Value for all buffs being zero, useful for construction or after switches
const defaultBuff = StatBuffs(Int8(0), Int8(0))

using StaticArrays

struct Decision
    chargedMovesPending::SVector{2,ChargedAction}
    shielding::SVector{2, Bool}
    switchesPending::SVector{2,SwitchAction}
end

const defaultDecision = Decision([defaultCharge, defaultCharge], [false, false], [defaultSwitch, defaultSwitch])

function Setfield.:setindex(arr::StaticArrays.SVector{2, Bool}, n::Bool, i::Int8)
    return setindex(arr, n, Int64(i))
end

function Decision(decision::Tuple{Int64,Int64})
    return Decision(
        @SVector[5 <= decision[1] <= 6 ? ChargedAction(Int8(1), Int8(100)) :
            7 <= decision[1] <= 8 ? ChargedAction(Int8(2), Int8(100)) :
            defaultCharge,
            5 <= decision[2] <= 6 ? ChargedAction(Int8(1), Int8(100)) :
            7 <= decision[2] <= 8 ? ChargedAction(Int8(2), Int8(100)) :
            defaultCharge],

        @SVector[iseven(decision[1]) && 5 <= decision[2] <= 8,
            iseven(decision[2]) && 5 <= decision[1] <= 8],

        @SVector[9 <= decision[1] <= 10 ? SwitchAction(Int8(1), Int8(0)) :
            11 <= decision[1] <= 12 ? SwitchAction(Int8(2), Int8(0)) :
            13 <= decision[1] <= 14 ? SwitchAction(Int8(3), Int8(0)) :
            15 <= decision[1] <= 16 ? SwitchAction(Int8(1), Int8(24)) :
            17 <= decision[1] <= 18 ? SwitchAction(Int8(2), Int8(24)) :
            19 <= decision[1] <= 20 ? SwitchAction(Int8(3), Int8(24)) :
            defaultSwitch, 
            9 <= decision[1] <= 10 ? SwitchAction(Int8(1), Int8(0)) :
            11 <= decision[1] <= 12 ? SwitchAction(Int8(2), Int8(0)) :
            13 <= decision[1] <= 14 ? SwitchAction(Int8(3), Int8(0)) :
            15 <= decision[1] <= 16 ? SwitchAction(Int8(1), Int8(24)) :
            17 <= decision[1] <= 18 ? SwitchAction(Int8(2), Int8(24)) :
            19 <= decision[1] <= 20 ? SwitchAction(Int8(3), Int8(24)) :
            defaultSwitch])
end

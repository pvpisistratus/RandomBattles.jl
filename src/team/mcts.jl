using StaticArrays, Distributions, Setfield

struct MCTSNode
    A::UInt8
    B::UInt8
    state::DynamicState
    move::SVector{3, UInt8}
    index::UInt16
    parent::UInt16
    dec_children::SMatrix{8, 8, UInt16, 64}
    chance_children::SVector{2, UInt16}
    σ₁::SVector{8, Float64}
    x₁::SVector{8, Float64}
    n₁::SVector{8, UInt32}
    σ₂::SVector{8, Float64}
    x₂::SVector{8, Float64}
    n₂::SVector{8, UInt32}
end

get_σ(decisions::UInt8, decision::UInt8) =
    is_possible(decisions, decision) ? (1 / Base.ctpop_int(decisions)) : 0.0

function MCTSNode(s::DynamicState, static_s::StaticState, parent::UInt16,
    index::UInt16, move::SVector{3, UInt8})
    A, B = get_possible_decisions(s, static_s)
    return MCTSNode(
        A,
        B,
        s,
        move,
        index,
        parent,
        (@SMatrix zeros(UInt16, 8, 8)),
        (@SVector zeros(UInt16, 2)),
        (@SVector [get_σ(A, i) for i = 0x01:0x08]),
        (@SVector zeros(8)),
        (@SVector zeros(UInt16, 8)),
        (@SVector [get_σ(B, i) for i = 0x01:0x08]),
        (@SVector zeros(8)),
        (@SVector zeros(UInt16, 8)),
    )
end

function chance_node_in_tree(
    tree::SizedVector{20000, MCTSNode, Vector{MCTSNode}}, s::MCTSNode,
    i::UInt16, static_s::StaticState)
    state_1, state_2 = s.state, s.state
    odds = 1.0

    chance = get_chance(s.state)
    if chance == 0x05
        odds = 0.5
        state_1 = get_chance_state_1(s.state, static_s, chance)
        state_2 = get_chance_state_2(s.state, chance)
    elseif chance != 0x00
        active1, active2 = get_active(s.state)
        agent = chance < 0x03 ? 0x01 : 0x02
        odds = get_buff_chance(isodd(chance) ?
            static_s[agent][active1].charged_move_1 :
            static_s[agent][active2].charged_move_2)
        state_1 = get_chance_state_1(s.state, static_s, chance)
        state_2 = get_chance_state_2(s.state, chance)
    end

    new_i = i
    while tree[new_i].index != 0x0000
        new_i += 0x0001
    end
    chance_index = rand() < odds ? 1 : 2
    if s.chance_children[chance_index] == 0x0000
        tree[new_i] = MCTSNode(chance_index == 1 ? state_1 : state_2, static_s,
            s.index, new_i, @SVector [0x00, 0x00, UInt8(chance_index)])
        s = @set s.chance_children[chance_index] = new_i
    end
    tree[s.index] = s
    u₁ = MCTS!(tree, tree[s.chance_children[chance_index]], new_i, static_s)
    parent = tree[s.parent]
    parent = @set parent.n₁[Int64(s.move[1])] += 1
    parent = @set parent.n₂[Int64(s.move[2])] += 1
    parent = @set parent.x₁[Int64(s.move[1])] += u₁
    parent = @set parent.x₂[Int64(s.move[2])] -= u₁
    tree[parent.index] = parent
    return u₁
end

function fill_missing_children(
    tree::SizedVector{20000, MCTSNode, Vector{MCTSNode}}, s::MCTSNode,
    i::UInt16, static_s::StaticState)
    a = get_decision(s.A, s.B,
        UInt8((length(findall(!iszero, s.dec_children))) %
            Base.ctpop_int(s.A) + 1),
        UInt8((length(findall(!iszero, s.dec_children))) ÷
            Base.ctpop_int(s.A) + 1))
    state = play_turn(s.state, static_s, (a[1], a[2]))
    new_i = i
    while tree[new_i].index != 0x0000
        new_i += 0x0001
    end
    tree[new_i] = MCTSNode(state, static_s, s.index, new_i,
        @SVector [a[1], a[2], 0x00])
    u₁ = Base.cmp(0.5, play_battle(tree[new_i].state, static_s))
    tree[s.index] = @set s.dec_children[Int64(a[1]), Int64(a[2])] = new_i
    update_mcts!(tree, tree[new_i], a[1], a[2], u₁)
    return u₁
end

function select_mcts(tree::SizedVector{20000, MCTSNode, Vector{MCTSNode}},
    s::MCTSNode, γ::Float64 = 0.1)
    η = γ / Base.ctpop_int(s.A)
    max_x1, max_x2 = -Inf, -Inf
    for i = 1:8
        if !iszero(s.A & 0x02^(i-0x01))
            if s.x₁[i] > max_x1
                max_x1 = max(max_x1, s.x₁[i])
            end
        end
        if !iszero(s.B & 0x02^(i-0x01))
            if s.x₂[i] > max_x2
                max_x2 = max(max_x2, s.x₂[i])
            end
        end
    end
    w₁(i) = s.x₁[i] - max_x1
    divisor = mapreduce(x ->
        (iszero(s.A & 2^(x-1)) ? 0.0 : exp(η * w₁(x))), +, 0x01:0x08)
    tree[s.index] = @set s.σ₁ = @SVector [
        (iszero(s.A & 0x02^(i-0x01)) ? 0.0 :
        (((1 - γ) * exp(η * w₁(i))) / divisor) +
        γ / Base.ctpop_int(s.A)) for i = 0x01:0x08]
    η = γ / Base.ctpop_int(s.B)
    w₂(i) = s.x₂[i] - max_x2
    divisor = mapreduce(x -> iszero(s.B & 2^(x-1)) ? 0.0 :
        exp(η * w₂(x)), +, 1:0x08)
    tree[s.index] = @set s.σ₂ = @SVector [(iszero(s.B & 2^(i-1)) ? 0.0 :
        ((1 - γ) * exp(η * w₂(i))) / divisor +
        γ / Base.ctpop_int(s.B)) for i = 0x01:0x08]

    return UInt8(rand(Categorical(s.σ₁))), UInt8(rand(Categorical(s.σ₂)))
end

function update_mcts!(tree::SizedVector{20000, MCTSNode, Vector{MCTSNode}},
    s::MCTSNode, a₁::UInt8, a₂::UInt8, u₁::Int64)
    iszero(s.parent) && return
    parent = tree[s.parent]
    if a₁ != 0x0000 && a₂ != 0x0000
        parent = @set parent.n₁[Int64(a₁)] += 1
        parent = @set parent.n₂[Int64(a₂)] += 1
        parent = @set parent.x₁[Int64(a₁)] += u₁ / parent.σ₁[Int64(a₁)]
        parent = @set parent.x₂[Int64(a₂)] -= u₁ / parent.σ₂[Int64(a₂)]
        tree[parent.index] = parent
    end
    update_mcts!(tree, tree[s.parent], tree[s.parent].move[1],
        tree[s.parent].move[2], u₁)
end

function MCTS!(tree::SizedVector{20000, MCTSNode, Vector{MCTSNode}},
    s::MCTSNode, i::UInt16, static_s::StaticState)
    if Base.ctpop_int(s.A) == 0x00 || Base.ctpop_int(s.B) == 0x00
        score = battle_score(s.state, static_s)
        return score > 0.5 ? 1 : score < 0.5 ? -1 : 0
    elseif tree[s.index] == s && get_chance(s.state) != 0x0000
        return chance_node_in_tree(tree, s, i, static_s)
    elseif tree[s.index] == s &&
        length(findall(!iszero, s.dec_children)) !=
        Base.ctpop_int(s.A) * Base.ctpop_int(s.B)
        return fill_missing_children(tree, s, i, static_s)
    else
        a = select_mcts(tree, s)
        s₁ = tree[s.dec_children[a[1], a[2]]]
        u₁ = MCTS!(tree, s₁, i, static_s)
        update_mcts!(tree, s₁, a[1], a[2], u₁)
        return u₁
    end
end

const default_node = MCTSNode(0x00, 0x00,
        DynamicState(StaticState(("mew", "mew", "mew", "mew", "mew", "mew"))),
        (@SVector zeros(UInt8, 3)), 0x0000, 0x0000,
        (@SMatrix [0x0000 for i = 1:8, j = 1:8]), (@SVector zeros(UInt16, 2)),
        (@SVector zeros(8)), (@SVector zeros(8)), (@SVector zeros(UInt16, 8)),
        (@SVector zeros(8)), (@SVector zeros(8)), (@SVector zeros(UInt16, 8)))

function delete_nodes!(tree::SizedVector{20000, MCTSNode, Vector{MCTSNode}},
    index::UInt16, to_keep::UInt16)
    for i = 1:8, j = 1:8
        if tree[index].dec_children[i, j] != 0x0000 &&
            tree[index].dec_children[i, j] != to_keep
            delete_nodes!(tree, tree[index].dec_children[i, j], to_keep)
        end
    end
    for i = 1:2
        if tree[index].chance_children[i] != 0x0000 &&
            tree[index].chance_children[i] != to_keep
            delete_nodes!(tree, tree[index].chance_children[i], to_keep)
        end
    end
    tree[index] = default_node
end

function update_tree_MCTS!(
    tree::SizedVector{20000, MCTSNode, Vector{MCTSNode}}, curr_index::UInt16,
    static_s::StaticState)

    for i = 0x0001:0x2710
        if tree[i].index == 0x0000
            MCTS!(tree, tree[curr_index], i, static_s)
        end
    end
end

function select_decisions_MCTS(dynamic_state::DynamicState,
    static_s::StaticState)
    tree = SizedVector{20_000}([default_node for i = 0x0001:0x4e20])
    tree[0x0001] = MCTSNode(dynamic_state, static_s, 0x0000, 0x0001,
        @SVector [0x00, 0x00, 0x00])
    curr_index = 0x0001
    strat = Strategy([], [], [], [])

    while Base.ctpop_int(tree[curr_index].A) != 0x00 &&
        Base.ctpop_int(tree[curr_index].B) != 0x00
        update_tree_MCTS!(tree, curr_index, static_s)
        d1, d2 = select_mcts(tree, tree[curr_index])
        prev_index = curr_index
        curr_index = tree[curr_index].dec_children[d1, d2]

        active = get_active(tree[curr_index].state)
        chance = get_chance(tree[curr_index].state)
        if chance == 0x05
            curr_index = rand() < 0.5 ? tree[curr_index].chance_children[1] :
                tree[curr_index].chance_children[2]
        elseif chance != 0x00
            agent = chance < 0x03 ? 0x01 : 0x02
            move = isodd(chance) ?
                static_s[agent][active[agent]].charged_move_1 :
                static_s[agent][active[agent]].charged_move_2
            curr_index = buff_applies(move) ?
                tree[curr_index].chance_children[1] :
                tree[curr_index].chance_children[2]
        end

        push!(strat.decisions, (d1, d2))
        push!(strat.scores, battle_score(tree[curr_index].state, static_s))
        push!(strat.activeMons, active)
        push!(strat.hps,
            ((get_hp(tree[curr_index].state[0x01][0x01]),
            get_hp(tree[curr_index].state[0x01][0x02]),
            get_hp(tree[curr_index].state[0x01][0x03])),
            (get_hp(tree[curr_index].state[0x02][0x01]),
            get_hp(tree[curr_index].state[0x02][0x02]),
            get_hp(tree[curr_index].state[0x02][0x03]))))

        delete_nodes!(tree, prev_index, curr_index)
        new_s = tree[curr_index]
        tree[curr_index] = @set new_s.parent = 0x0000
    end

    return strat
end

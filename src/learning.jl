using Flux, RandomBattles, Distributions, OnlineStats

function crossover_and_mutate(m1, m2, mutation_dist::Distribution)
    child = deepcopy(m1)
    weights2 = Array{Tracker.TrackedReal{Float32}}(undef, 0)
    for p in Flux.params(m2).params, w in p
        push!(weights2, w)
    end
    i = 1
    for p in Flux.params(m2).params,  w in p
        if rand(Bool)
            w = weights2[i] + rand(mutation_dist)
        else
            w += rand(mutation_dist)
        end
        i += 1
    end
    return child
end

function play_nn_battle(initial_state::BattleState, model1, model2)
    state = initial_state
    num_turns = 1
    while true
        weights1 = get_possible_decisions(state, allow_nothing = true)
        weights2 = get_possible_decisions(switch_agent(state), allow_nothing = true)
        (iszero(sum(weights1)) || iszero(sum(weights2))) && return get_battle_score(state) > 0.5 ? 1 : 0
        num_turns >= 540 && return rand(0:1)

        possible_weights1 = findall(!isequal(0), weights1)
        possible_weights2 = findall(!isequal(0), weights2)

        vec_state = vectorize(state)
        decision1 = model1(vec_state)
        decision1 = possible_weights1[findmax(map(x -> decision1[x], possible_weights1))[2]]
        decision2 = model2(vec_state)
        decision2 = possible_weights2[findmax(map(x -> decision2[x], possible_weights2))[2]]

        weights1[decision1] == 0 && println("error")
        weights2[decision2] == 0 && println("error")

        state = play_turn(state, (decision1, decision2))
        num_turns += 1
    end
end

function play_nn_random_battle(initial_state::BattleState, model1)
    state = initial_state
    num_turns = 1
    while true
        weights1 = get_possible_decisions(state, allow_nothing = true)
        weights2 = get_possible_decisions(switch_agent(state), allow_nothing = false)
        (iszero(sum(weights1)) || iszero(sum(weights2))) && return get_battle_score(state) > 0.5 ? 1 : 0
        num_turns >= 540 && return rand(0:1)

        possible_weights1 = findall(!isequal(0), weights1)
        possible_weights2 = findall(!isequal(0), weights2)

        decision1 = model1(vectorize(state))
        decision1 = possible_weights1[findmax(map(x -> decision1[x], possible_weights1))[2]]
        decision2 = rand(Categorical(weights2 / sum(weights2)))

        weights1[decision1] == 0 && println("error")

        state = play_turn(state, (decision1, decision2))
        num_turns += 1
    end
end

function testing_best(models, meta)
    scores = map(x -> Mean(), 1:length(models))
    for j in 1:length(models), i in 1:300
        s = State([meta.pokemon[rand(meta.weights)].toString meta.pokemon[rand(meta.weights)].toString meta.pokemon[rand(meta.weights)].toString meta.pokemon[rand(meta.weights)].toString meta.pokemon[rand(meta.weights)].toString meta.pokemon[rand(meta.weights)].toString])
        fit!(scores[j], play_nn_random_battle(s, models[j]))
    end
    return findmax(map(x -> scores[x].μ, 1:length(models)))
end

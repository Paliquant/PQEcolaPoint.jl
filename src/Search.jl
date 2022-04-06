# == PUBLIC BELOW HERE ================================================================================================ #
function tabu(world::CRRJITContractPremiumLatticeModel, base::PQContractPremiumLatticePoint; 
    fitness::Function, neighborhood::Function)::Tuple{Float64,PQContractPremiumLatticePoint}

    # initialize -
    max_number_of_iterations = 400
    iteration_counter = 0
    length_of_simple_memory = 80
    should_stop_search = false
    current_point = base
    best_point = base
    best_fitness = fitness(world, best_point)

    # tabu list -
    tabu_set = Set{PQContractPremiumLatticePoint}()
    push!(tabu_set, best_point)

    # main loop -
    while (should_stop_search == false)

        # what is the current fitness?
        current_fitness = fitness(world, current_point)
        
        # generate a neighborhood of the current solution -> check: any good points there?
        list_of_candidate_points = neighborhood(current_point)
        for candidate_point ∈ list_of_candidate_points
            
            # is this candidate_point in the tabu_list?
            if (in(candidate_point, tabu_set) == false && fitness(world, candidate_point) > current_fitness)
                current_point = candidate_point
            end
        end
        
        # ok - is the current_point better than the best that we have?
        current_fitness = fitness(world, current_point)
        if (current_fitness > best_fitness)
            
            # update the best fitness -
            best_fitness = current_fitness

            # update -
            best_point = current_point

            # add this point to the tabu_list -
            push!(tabu_list, best_point)
        end

        # prune the tabu set - remove a random element -
        if (length(tabu_set) >= length_of_simple_memory)
            pop!(tabu_set) # remove a random element -
        end

        # update the iteration_counter -
        iteration_counter += 1
        if (iteration_counter > max_number_of_iterations)
            should_stop_search = true
        end
    end

    # return -
    return best_point
end
# == PUBLIC ABOVE HERE ================================================================================================ #
using PQEcolaPoint

# init some functions -
function _fitness(world::CRRJITContractPremiumLatticeModel, test_point::PQContractPremiumLatticePoint)::Float64

    # how would we impl constraints?
    # ...

    # fitness is premium -
    return premium(world, test_point)
end

function _neighborhood(point::PQContractPremiumLatticePoint)::Array{PQContractPremiumLatticePoint,1}

    # initialize -
    N_array = Array{PQContractPremiumLatticePoint,1}()
    D_max = 65
    D_min = 2
    I_max = 23
    I_min = 2

    if (point.d<(D_max - 1) && point.d >= D_min && point.i < (I_max - 1) && point.i >= I_min)

        push!(N_array, build(PQContractPremiumLatticePoint; i = (point.i + 1), j = point.j, s = point.s, d = point.d))
        push!(N_array, build(PQContractPremiumLatticePoint; i = (point.i - 1), j = point.j, s = point.s, d = point.d))
        push!(N_array, build(PQContractPremiumLatticePoint; i = point.i, j = point.j, s = point.s, d = (point.d + 1)))
        push!(N_array, build(PQContractPremiumLatticePoint; i = point.i, j = point.j, s = point.s, d = (point.d - 1)))
        push!(N_array, build(PQContractPremiumLatticePoint; i = (point.i + 1), j = point.j, s = point.s, d = (point.d + 1)))
        push!(N_array, build(PQContractPremiumLatticePoint; i = (point.i + 1), j = point.j, s = point.s, d = (point.d - 1)))
        push!(N_array, build(PQContractPremiumLatticePoint; i = (point.i - 1), j = point.j, s = point.s, d = (point.d + 1)))
        push!(N_array, build(PQContractPremiumLatticePoint; i = (point.i - 1), j = point.j, s = point.s, d = (point.d - 1)))
    end

    # return -
    return N_array
end


# setup DTE -
T = 300.0
DTE = range(T, stop=0.0,step=-1.0) |> collect

# setup underlying range -
Sₒ = 76.04
IV = 0.4456
σ = Sₒ*(IV)*(√(T/365))
L = round(Sₒ - 1.96*σ)  # 95%
U = round(Sₒ + 1.96*σ)  # 95%
S = range(max.(L, 0.0),stop=U, step=0.5) |> collect

# setup IV array -
IV_array = range(0.1, stop = 1.2, step = 0.05) |> collect

# setup strike coordinates -
K = range(50.0, stop = 125.0, step = 5.0) |> collect

# build JIT lattice model -
JIT_lattice = build(CRRJITContractPremiumLatticeModel, PutContractModel, S, K, IV_array, DTE; number_of_levels = 80)

# build a point -
start_point = encode(JIT_lattice; S = 73.0, DTE = 35.0, IV = 0.4498, K = 75.0) # we are underwater here -

# try the tabu -
(F,B) = tabu(JIT_lattice, start_point; fitness = _fitness, neighborhood = _neighborhood)

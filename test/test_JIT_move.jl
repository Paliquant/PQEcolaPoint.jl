using PQEcolaPoint

# setup DTE -
T = 72.0
DTE = range(T, stop=0.0,step=-1.0) |> collect

# setup underlying range -
Sₒ = 76.04
IV = 0.4456
σ = Sₒ*(IV)*(√(T/365))
L = round(Sₒ - 2.96*σ)
U = round(Sₒ + 2.96*σ)
S = range(L,stop=U, step=0.5) |> collect

# setup IV array -
IV_array = range(0.1, stop = 1.2, step = 0.05) |> collect

# setup strike coordinates -
K = range(50.0, stop = 125.0, step = 5.0) |> collect

# build JIT lattice model -
JIT_lattice = build(CRRJITContractPremiumLatticeModel, PutContractModel, S, K, IV_array, DTE; number_of_levels = 80)

# encode the to and from points -
from_point = encode(JIT_lattice; S = Sₒ, DTE = 35.0, IV = 0.4498, K = 75.0)
to_point = encode(JIT_lattice; S = Sₒ, DTE = 49.0, IV = 0.4681, K = 70.0)
p_array = move(JIT_lattice; from = from_point, to = to_point)

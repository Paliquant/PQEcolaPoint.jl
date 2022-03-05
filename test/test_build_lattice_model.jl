using PQEcolaPoint

# build a binary tree with three levels -
model = build(LatticeModel; number_of_levels = 3, branch_factor = 2)

# should return error -
_ = build(LatticeModel; number_of_levels = 1, branch_factor = 2)
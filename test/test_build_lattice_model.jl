using PQEcolaPoint

# build a binary tree with three levels -
model = build(CRRLatticeModel; number_of_levels = 14, branch_factor = 2, σ = 0.65, T = (14.0 / 365), r = 0.0174)
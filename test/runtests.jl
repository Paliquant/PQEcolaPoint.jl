using PQEcolaPoint
using Test

# -- Default test ------------------------------------------------------ #
function default_pqecolapoint_test()
    return true
end
# ------------------------------------------------------------------------------- #

@testset "default_test_set" begin
    @test default_pqecolapoint_test() == true
end
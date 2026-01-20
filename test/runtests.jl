using Test
using TableExplorer

@testset "TableExplorer.jl" begin
    # Run all test files
    include("test_utils.jl")
    include("test_column_types.jl")
    include("test_table_html.jl")
    include("test_api.jl")
end


@testset "run all examples" begin
    example_scripts = readdir(joinpath(@__DIR__,"..","examples"), join=true)
    for script in example_scripts
        include(script)
        @test true
    end
end

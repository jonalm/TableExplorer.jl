using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

@testset "API Tests" begin

    @testset "explore_table - basic functionality" begin
        include("testsets/api/explore_table_basic_functionality.jl")
    end

    @testset "explore_table - with column types" begin
        include("testsets/api/explore_table_with_column_types.jl")
    end

    @testset "explore_table - String and Symbol keys" begin
        include("testsets/api/explore_table_string_and_symbol_keys.jl")
    end

    @testset "explore_table - auto_categorical_threshold" begin
        include("testsets/api/explore_table_auto_categorical_threshold.jl")
    end

    @testset "explore_table - various table types" begin
        include("testsets/api/explore_table_various_table_types.jl")
    end

    @testset "explore_table - edge cases" begin
        include("testsets/api/explore_table_edge_cases.jl")
    end

    @testset "explore_table - special characters" begin
        include("testsets/api/explore_table_special_characters.jl")
    end

    @testset "explore_table - all column types together" begin
        include("testsets/api/explore_table_all_column_types_together.jl")
    end

    @testset "explore_table - partial column specification" begin
        include("testsets/api/explore_table_partial_column_specification.jl")
    end

    @testset "explore_table - override auto-detection" begin
        include("testsets/api/explore_table_override_auto_detection.jl")
    end

    @testset "API exports" begin
        include("testsets/api/api_exports.jl")
    end

    @testset "table_html integration" begin
        include("testsets/api/table_html_integration.jl")
    end
end

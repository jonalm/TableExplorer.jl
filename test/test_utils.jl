using Test
using TableExplorer
using DataFrames
using Tables

@testset "Utils Tests" begin

    @testset "DEFAULT_CATEGORICAL_PALETTE" begin
        include("testsets/utils/default_categorical_palette.jl")
    end

    @testset "assign_color_to_value" begin
        include("testsets/utils/assign_color_to_value.jl")
    end

    @testset "generate_categorical_colors" begin
        include("testsets/utils/generate_categorical_colors.jl")
    end

    @testset "row_to_dict" begin
        include("testsets/utils/row_to_dict.jl")
    end

    @testset "js_string_literal" begin
        include("testsets/utils/js_string_literal.jl")
    end

    @testset "create_categorical_formatter" begin
        include("testsets/utils/create_categorical_formatter.jl")
    end

    @testset "open_in_browser" begin
        include("testsets/utils/open_in_browser.jl")
    end

    @testset "get_column_data helper pattern" begin
        include("testsets/utils/get_column_data_helper_pattern.jl")
    end
end

using Test
using TableExplorer
using DataFrames
using Tables

@testset "Column Types Tests" begin

    @testset "ColumnText construction" begin
        include("testsets/column_types/column_text_construction.jl")
    end

    @testset "ColumnNumeric construction" begin
        include("testsets/column_types/column_numeric_construction.jl")
    end

    @testset "ColumnCategorical construction" begin
        include("testsets/column_types/column_categorical_construction.jl")
    end

    @testset "ColumnDateTime construction" begin
        include("testsets/column_types/column_datetime_construction.jl")
    end

    @testset "create_header_filter_config - ColumnText" begin
        include("testsets/column_types/create_header_filter_config_column_text.jl")
    end

    @testset "create_header_filter_config - ColumnNumeric" begin
        include("testsets/column_types/create_header_filter_config_column_numeric.jl")
    end

    @testset "create_header_filter_config - ColumnCategorical" begin
        include("testsets/column_types/create_header_filter_config_column_categorical.jl")
    end

    @testset "create_formatter - ColumnText" begin
        include("testsets/column_types/create_formatter_column_text.jl")
    end

    @testset "create_formatter - ColumnNumeric" begin
        include("testsets/column_types/create_formatter_column_numeric.jl")
    end

    @testset "create_formatter - ColumnCategorical" begin
        include("testsets/column_types/create_formatter_column_categorical.jl")
    end

    @testset "create_formatter - ColumnDateTime" begin
        include("testsets/column_types/create_formatter_column_datetime.jl")
    end

    @testset "create_column_config" begin
        include("testsets/column_types/create_column_config.jl")
    end

    @testset "auto_detect_column_type" begin
        include("testsets/column_types/auto_detect_column_type.jl")
    end

    @testset "get_or_detect_column_type" begin
        include("testsets/column_types/get_or_detect_column_type.jl")
    end

    @testset "ColumnHeatmap construction" begin
        include("testsets/column_types/column_heatmap_construction.jl")
    end

    @testset "create_header_filter_config - ColumnHeatmap" begin
        include("testsets/column_types/create_header_filter_config_column_heatmap.jl")
    end

    @testset "create_formatter - ColumnHeatmap" begin
        include("testsets/column_types/create_formatter_column_heatmap.jl")
    end

    @testset "get_alignment - ColumnHeatmap" begin
        include("testsets/column_types/get_alignment_column_heatmap.jl")
    end

    @testset "Edge cases - mixed types" begin
        include("testsets/column_types/edge_cases_mixed_types.jl")
    end
end

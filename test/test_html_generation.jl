using Test
using TableExplorer
using DataFrames
using JSON

@testset "HTML Generation Tests" begin

    @testset "ColumnCategorical generates dropdown filter" begin
        include("testsets/html_generation/column_categorical_generates_dropdown_filter.jl")
    end

    @testset "ColumnCategorical with custom labels" begin
        include("testsets/html_generation/column_categorical_with_custom_labels.jl")
    end

    @testset "Multiple column types with dropdowns" begin
        include("testsets/html_generation/multiple_column_types_with_dropdowns.jl")
    end

    @testset "Auto-detected categorical gets dropdown" begin
        include("testsets/html_generation/auto_detected_categorical_gets_dropdown.jl")
    end

    @testset "ColumnCategorical with missing values" begin
        include("testsets/html_generation/column_categorical_with_missing_values.jl")
    end

    @testset "ColumnCategorical with nothing values" begin
        include("testsets/html_generation/column_categorical_with_nothing_values.jl")
    end

    @testset "ColumnCategorical with both missing and nothing" begin
        include("testsets/html_generation/column_categorical_with_both_missing_and_nothing.jl")
    end

    @testset "No select filter type in generated HTML" begin
        include("testsets/html_generation/no_select_filter_type_in_generated_html.jl")
    end

    @testset "ColumnCategorical multiselect configuration" begin
        include("testsets/html_generation/column_categorical_multiselect_configuration.jl")
    end

    @testset "ColumnNumeric dropdown with value types" begin
        include("testsets/html_generation/column_numeric_dropdown_with_value_types.jl")
    end

    @testset "ColumnNumeric dropdown single select" begin
        include("testsets/html_generation/column_numeric_dropdown_single_select.jl")
    end

    @testset "ColumnNumeric dropdown only shows applicable types" begin
        include("testsets/html_generation/column_numeric_dropdown_only_shows_applicable_types.jl")
    end
end

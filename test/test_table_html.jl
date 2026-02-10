using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames
using Tables
using JSON

@testset "Table HTML Tests" begin

    @testset "config_to_json" begin
        include("testsets/table_html/config_to_json.jl")
    end

    @testset "is_js_function" begin
        include("testsets/table_html/is_js_function.jl")
    end

    @testset "table_html - basic functionality" begin
        include("testsets/table_html/table_html_basic_functionality.jl")
    end

    @testset "table_html - column types" begin
        include("testsets/table_html/table_html_column_types.jl")
    end

    @testset "table_html - String and Symbol keys" begin
        include("testsets/table_html/table_html_string_and_symbol_keys.jl")
    end

    @testset "table_html - auto_categorical_threshold" begin
        include("testsets/table_html/table_html_auto_categorical_threshold.jl")
    end

    @testset "table_html - special values" begin
        include("testsets/table_html/table_html_special_values.jl")
    end

    @testset "table_html - empty table" begin
        include("testsets/table_html/table_html_empty_table.jl")
    end

    @testset "table_html - single row" begin
        include("testsets/table_html/table_html_single_row.jl")
    end

    @testset "table_html - single column" begin
        include("testsets/table_html/table_html_single_column.jl")
    end

    @testset "table_html - Tables.jl interface compatibility" begin
        include("testsets/table_html/table_html_tables_jl_interface_compatibility.jl")
    end

    @testset "table_html - large table" begin
        include("testsets/table_html/table_html_large_table.jl")
    end

    @testset "table_html - column name variations" begin
        include("testsets/table_html/table_html_column_name_variations.jl")
    end

    @testset "table_html - template embedding" begin
        include("testsets/table_html/table_html_template_embedding.jl")
    end

    @testset "table_html - JSON serialization" begin
        include("testsets/table_html/table_html_json_serialization.jl")
    end

    @testset "table_html - override auto-detection" begin
        include("testsets/table_html/table_html_override_auto_detection.jl")
    end

    @testset "table_html - multiple formatters" begin
        include("testsets/table_html/table_html_multiple_formatters.jl")
    end
end

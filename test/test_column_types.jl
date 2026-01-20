using Test
using TableExplorer
using DataFrames
using Tables

@testset "Column Types Tests" begin

    @testset "ColumnText construction" begin
        # Test default
        col = ColumnText()
        @test col.search_type == :regex

        # Test with explicit search type
        col_exact = ColumnText(search_type=:exact)
        @test col_exact.search_type == :exact

        col_contains = ColumnText(search_type=:contains)
        @test col_contains.search_type == :contains
    end

    @testset "ColumnNumeric construction" begin
        # Test defaults
        col = ColumnNumeric()
        @test col.decimal_places === nothing
        @test col.alignment == :right
        @test col.search_type == :input

        # Test with custom values
        col_custom = ColumnNumeric(decimal_places=3, alignment=:left)
        @test col_custom.decimal_places == 3
        @test col_custom.alignment == :left
    end

    @testset "ColumnCategorical construction" begin
        # Test defaults
        col = ColumnCategorical()
        @test col.color_map === nothing
        @test col.search_type == :input
        @test col.show_colors == true
        @test col.palette == TableExplorer.DEFAULT_CATEGORICAL_PALETTE

        # Test with custom color map
        custom_colors = Dict("A" => "#ff0000", "B" => "#00ff00")
        col_custom = ColumnCategorical(color_map=custom_colors)
        @test col_custom.color_map == custom_colors

        # Test with custom palette
        custom_palette = ["#111111", "#222222"]
        col_palette = ColumnCategorical(palette=custom_palette)
        @test col_palette.palette == custom_palette

        # Test with show_colors=false
        col_no_colors = ColumnCategorical(show_colors=false)
        @test col_no_colors.show_colors == false
    end

    @testset "ColumnDateTime construction" begin
        # Test defaults
        col = ColumnDateTime()
        @test col.format == "yyyy-mm-dd HH:MM:SS"
        @test col.search_type == :input

        # Test with custom format
        col_custom = ColumnDateTime(format="yyyy-mm-dd")
        @test col_custom.format == "yyyy-mm-dd"
    end

    @testset "ColumnBoolean construction" begin
        # Test defaults
        col = ColumnBoolean()
        @test col.search_type == :dropdown
        @test col.true_label == "✓"
        @test col.false_label == "✗"

        # Test with custom labels
        col_custom = ColumnBoolean(true_label="Yes", false_label="No")
        @test col_custom.true_label == "Yes"
        @test col_custom.false_label == "No"
    end

    @testset "create_header_filter_config - ColumnText" begin
        # Test regex
        col = ColumnText(search_type=:regex)
        result = TableExplorer.create_header_filter_config(col)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "regex"
        @test result.placeholder == "Regex search..."

        # Test exact
        col = ColumnText(search_type=:exact)
        result = TableExplorer.create_header_filter_config(col)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "="
        @test result.placeholder == "Exact match..."

        # Test contains
        col = ColumnText(search_type=:contains)
        result = TableExplorer.create_header_filter_config(col)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "like"
        @test result.placeholder == "Contains..."
    end

    @testset "create_header_filter_config - ColumnNumeric" begin
        col = ColumnNumeric()
        result = TableExplorer.create_header_filter_config(col)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "regex"
        @test result.placeholder == "Regex search..."

        # Range type
        col_range = ColumnNumeric(search_type=:range)
        result = TableExplorer.create_header_filter_config(col_range)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == ">="
        @test result.placeholder == "Min value..."
    end

    @testset "create_header_filter_config - ColumnCategorical" begin
        col = ColumnCategorical()
        result = TableExplorer.create_header_filter_config(col)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "regex"
        @test result.placeholder == "Regex search..."

        col_exact = ColumnCategorical(search_type=:exact)
        result = TableExplorer.create_header_filter_config(col_exact)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "="
        @test result.placeholder == "Exact match..."
    end

    @testset "create_formatter - ColumnText" begin
        df = DataFrame(name = ["Alice", "Bob"])
        col = ColumnText()
        result = TableExplorer.create_formatter(col, df, :name)
        @test result === nothing
    end

    @testset "create_formatter - ColumnNumeric" begin
        # Test with explicit decimal places
        df = DataFrame(value = [1.23, 4.56])
        col = ColumnNumeric(decimal_places=2)
        result = TableExplorer.create_formatter(col, df, :value)
        @test result isa String
        @test occursin("toFixed(2)", result)

        # Test with auto-detection for floats
        col_auto = ColumnNumeric()
        result = TableExplorer.create_formatter(col_auto, df, :value)
        @test occursin("toFixed(2)", result)

        # Test with integers
        df_int = DataFrame(count = [1, 2, 3])
        result_int = TableExplorer.create_formatter(col_auto, df_int, :count)
        @test occursin("toLocaleString()", result_int)
    end

    @testset "create_formatter - ColumnCategorical" begin
        df = DataFrame(status = ["Active", "Inactive", "Pending"])

        # Test with manual color map
        color_map = Dict("Active" => "#00ff00", "Inactive" => "#ff0000")
        col = ColumnCategorical(color_map=color_map)
        result = TableExplorer.create_formatter(col, df, :status)
        @test result isa String
        @test occursin("Active", result)
        @test occursin("#00ff00", result)

        # Test with auto-generated colors
        col_auto = ColumnCategorical()
        result_auto = TableExplorer.create_formatter(col_auto, df, :status)
        @test result_auto isa String
        @test occursin("backgroundColor", result_auto)

        # Test with show_colors=false
        col_no_colors = ColumnCategorical(show_colors=false)
        result_no_colors = TableExplorer.create_formatter(col_no_colors, df, :status)
        @test result_no_colors === nothing

        # Test with empty column
        df_empty = DataFrame(status = String[])
        result_empty = TableExplorer.create_formatter(col_auto, df_empty, :status)
        @test result_empty === nothing
    end

    @testset "create_formatter - ColumnDateTime" begin
        using Dates
        df = DataFrame(date = [Date(2024, 1, 1)])
        col = ColumnDateTime()
        result = TableExplorer.create_formatter(col, df, :date)
        @test result === nothing  # Currently no special formatting
    end

    @testset "create_formatter - ColumnBoolean" begin
        df = DataFrame(flag = [true, false])
        col = ColumnBoolean()
        result = TableExplorer.create_formatter(col, df, :flag)
        @test result isa String
        @test occursin("✓", result)
        @test occursin("✗", result)

        # Test with custom labels
        col_custom = ColumnBoolean(true_label="Yes", false_label="No")
        result_custom = TableExplorer.create_formatter(col_custom, df, :flag)
        @test occursin("Yes", result_custom)
        @test occursin("No", result_custom)

        # Test with special characters in labels (injection vulnerability test)
        col_special = ColumnBoolean(true_label="It's true", false_label="Don't fail")
        result_special = TableExplorer.create_formatter(col_special, df, :flag)
        @test occursin("It\\'s true", result_special)
        @test occursin("Don\\'t fail", result_special)

        # Test with newlines and backslashes
        col_escape = ColumnBoolean(true_label="Yes\nOK", false_label="No\\Way")
        result_escape = TableExplorer.create_formatter(col_escape, df, :flag)
        @test occursin("Yes\\nOK", result_escape)
        @test occursin("No\\\\Way", result_escape)
    end

    @testset "get_alignment" begin
        @test TableExplorer.get_alignment(ColumnText()) === nothing
        @test TableExplorer.get_alignment(ColumnNumeric()) == "right"
        @test TableExplorer.get_alignment(ColumnNumeric(alignment=:left)) == "left"
        @test TableExplorer.get_alignment(ColumnCategorical()) === nothing
        @test TableExplorer.get_alignment(ColumnDateTime()) === nothing
        @test TableExplorer.get_alignment(ColumnBoolean()) == "center"
    end

    @testset "create_column_config" begin
        df = DataFrame(value = [1.5, 2.5], name = ["A", "B"])

        # Test basic config
        col_text = ColumnText()
        config = TableExplorer.create_column_config(df, :name, col_text)
        @test config isa Dict{String, Any}
        @test config["title"] == "name"
        @test config["field"] == "name"
        @test config["headerSort"] == true
        @test haskey(config, "headerFilter")

        # Test with numeric column
        col_num = ColumnNumeric(decimal_places=2, alignment=:right)
        config_num = TableExplorer.create_column_config(df, :value, col_num)
        @test config_num["align"] == "right"
        @test haskey(config_num, "formatter")
    end

    @testset "auto_detect_column_type" begin
        # Test numeric detection
        df_num = DataFrame(value = [1.5, 2.5, 3.5])
        result = TableExplorer.auto_detect_column_type(df_num, :value)
        @test result isa ColumnNumeric

        # Test integer detection
        df_int = DataFrame(count = [1, 2, 3])
        result = TableExplorer.auto_detect_column_type(df_int, :count)
        @test result isa ColumnNumeric

        # Test boolean detection
        df_bool = DataFrame(flag = [true, false, true])
        result = TableExplorer.auto_detect_column_type(df_bool, :flag)
        @test result isa ColumnBoolean

        # Test categorical detection (few unique values)
        df_cat = DataFrame(status = ["A", "B", "A", "C", "B"])
        result = TableExplorer.auto_detect_column_type(df_cat, :status, auto_categorical_threshold=5)
        @test result isa ColumnCategorical

        # Test text detection (many unique values)
        df_text = DataFrame(id = string.(1:20))
        result = TableExplorer.auto_detect_column_type(df_text, :id, auto_categorical_threshold=10)
        @test result isa ColumnText

        # Test with missing values
        df_missing = DataFrame(value = [1, missing, 3])
        result = TableExplorer.auto_detect_column_type(df_missing, :value)
        @test result isa ColumnNumeric

        # Test with all missing - Note: Missing type has Bool as nonmissingtype
        df_all_missing = DataFrame(value = [missing, missing])
        result = TableExplorer.auto_detect_column_type(df_all_missing, :value)
        @test result isa ColumnBoolean  # Missing -> Bool

        # Test with Nothing type
        df_nothing = DataFrame(value = [nothing, nothing])
        result = TableExplorer.auto_detect_column_type(df_nothing, :value)
        @test result isa ColumnText

        # Test categorical with threshold=nothing (disabled)
        df_cat2 = DataFrame(status = ["A", "B", "C"])
        result = TableExplorer.auto_detect_column_type(df_cat2, :status, auto_categorical_threshold=nothing)
        @test result isa ColumnText

        # Test categorical with empty strings
        df_empty = DataFrame(status = ["A", "", "B", "", "C"])
        result = TableExplorer.auto_detect_column_type(df_empty, :status, auto_categorical_threshold=5)
        @test result isa ColumnCategorical
    end

    @testset "get_or_detect_column_type" begin
        df = DataFrame(x = [1, 2, 3], y = ["a", "b", "c"])

        # Test explicit type (Symbol key)
        col_types = Dict(:x => ColumnText())
        result = TableExplorer.get_or_detect_column_type(df, :x, col_types, 10)
        @test result isa ColumnText

        # Test auto-detection
        result = TableExplorer.get_or_detect_column_type(df, :y, col_types, 10)
        @test result isa ColumnCategorical

        # Test with String key in lookup
        result = TableExplorer.get_or_detect_column_type(df, "x", col_types, 10)
        @test result isa ColumnText
    end

    @testset "Column type hierarchy" begin
        # Verify all column types are subtypes of ColumnType
        @test ColumnText <: TableExplorer.ColumnType
        @test ColumnNumeric <: TableExplorer.ColumnType
        @test ColumnCategorical <: TableExplorer.ColumnType
        @test ColumnDateTime <: TableExplorer.ColumnType
        @test ColumnBoolean <: TableExplorer.ColumnType
    end

    @testset "Edge cases - mixed types" begin
        # Test with Union types
        df = DataFrame(value = Union{Int, Missing}[1, missing, 3])
        result = TableExplorer.auto_detect_column_type(df, :value)
        @test result isa ColumnNumeric

        # Test with Union{String, Missing}
        df_str = DataFrame(name = Union{String, Missing}["Alice", missing, "Bob"])
        result = TableExplorer.auto_detect_column_type(df_str, :name, auto_categorical_threshold=5)
        @test result isa ColumnCategorical
    end
end

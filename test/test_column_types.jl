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
        @test col.search_type == :dropdown
        @test col.show_colors == true
        @test col.palette == TableExplorer.DEFAULT_CATEGORICAL_PALETTE
        @test col.multiselect == true  # Default changed to true

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

        # Test with multiselect=true
        col_multiselect = ColumnCategorical(multiselect=true)
        @test col_multiselect.multiselect == true
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

    @testset "create_header_filter_config - ColumnText" begin
        df = DataFrame(name = ["Alice", "Bob"])

        # Test regex
        col = ColumnText(search_type=:regex)
        result = TableExplorer.create_header_filter_config(col, df, :name)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "regex"
        @test result.placeholder == "Regex search..."

        # Test exact
        col = ColumnText(search_type=:exact)
        result = TableExplorer.create_header_filter_config(col, df, :name)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "="
        @test result.placeholder == "Exact match..."

        # Test contains
        col = ColumnText(search_type=:contains)
        result = TableExplorer.create_header_filter_config(col, df, :name)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "like"
        @test result.placeholder == "Contains..."
    end

    @testset "create_header_filter_config - ColumnNumeric" begin
        df = DataFrame(value = [1.5, 2.5])

        col = ColumnNumeric()
        result = TableExplorer.create_header_filter_config(col, df, :value)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "regex"
        @test result.placeholder == "Regex search..."

        # Range type
        col_range = ColumnNumeric(search_type=:range)
        result = TableExplorer.create_header_filter_config(col_range, df, :value)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == ">="
        @test result.placeholder == "Min value..."

        # Dropdown type with only numerical values
        col_dropdown = ColumnNumeric(search_type=:dropdown)
        result = TableExplorer.create_header_filter_config(col_dropdown, df, :value)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "list"
        @test result.filter_func == "numericTypeFilter"  # Default multiselect=true
        @test result.multiselect == true
        @test result.placeholder == "Select..."
        @test length(result.values) == 1  # Only "numerical"
        @test result.values[1]["label"] == "numerical"
        @test result.values[1]["value"] == "numerical"

        # Dropdown type with NaN values
        df_nan = DataFrame(value = [1.5, NaN, 2.5])
        result_nan = TableExplorer.create_header_filter_config(col_dropdown, df_nan, :value)
        @test length(result_nan.values) == 2  # "numerical" and "NaN"
        labels = [v["label"] for v in result_nan.values]
        @test "numerical" in labels
        @test "NaN" in labels

        # Dropdown type with Infinity values
        df_inf = DataFrame(value = [1.5, Inf, -Inf, 2.5])
        result_inf = TableExplorer.create_header_filter_config(col_dropdown, df_inf, :value)
        @test length(result_inf.values) == 3  # "numerical", "Infinity", "-Infinity"
        labels = [v["label"] for v in result_inf.values]
        @test "numerical" in labels
        @test "Infinity" in labels
        @test "-Infinity" in labels

        # Dropdown type with missing/nothing values
        df_null = DataFrame(value = [1.5, missing, nothing, 2.5])
        result_null = TableExplorer.create_header_filter_config(col_dropdown, df_null, :value)
        @test length(result_null.values) == 2  # "numerical" and "(null)"
        labels = [v["label"] for v in result_null.values]
        @test "numerical" in labels
        @test "(null)" in labels

        # Dropdown type with all special values
        df_all = DataFrame(value = [1.5, NaN, Inf, -Inf, missing, nothing, 2.5])
        result_all = TableExplorer.create_header_filter_config(col_dropdown, df_all, :value)
        @test length(result_all.values) == 5  # All types
        labels = [v["label"] for v in result_all.values]
        @test "numerical" in labels
        @test "NaN" in labels
        @test "Infinity" in labels
        @test "-Infinity" in labels
        @test "(null)" in labels

        # Test single select mode
        col_single = ColumnNumeric(search_type=:dropdown, multiselect=false)
        result_single = TableExplorer.create_header_filter_config(col_single, df_all, :value)
        @test result_single.filter_func == "numericTypeSingleFilter"
        @test result_single.multiselect == false
    end

    @testset "create_header_filter_config - ColumnCategorical" begin
        df = DataFrame(status = ["Active", "Inactive", "Pending"])

        # Test dropdown (default - now multiselect=true)
        col = ColumnCategorical()
        result = TableExplorer.create_header_filter_config(col, df, :status)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "list"
        @test result.filter_func == "in"  # Changed to "in" since default is multiselect=true
        @test result.placeholder == "Select..."
        @test result.values !== nothing
        @test length(result.values) == 3
        @test all(v -> haskey(v, "label") && haskey(v, "value"), result.values)
        @test result.multiselect == true  # Default is multiselect

        # Test exact search
        col_exact = ColumnCategorical(search_type=:exact)
        result = TableExplorer.create_header_filter_config(col_exact, df, :status)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "="
        @test result.placeholder == "Exact match..."
        @test result.values === nothing

        # Test input search
        col_input = ColumnCategorical(search_type=:input)
        result = TableExplorer.create_header_filter_config(col_input, df, :status)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == "input"
        @test result.filter_func == "regex"
        @test result.placeholder == "Regex search..."
        @test result.values === nothing

        # Test with Missing values
        df_missing = DataFrame(status = ["Active", missing, "Inactive"])
        result_missing = TableExplorer.create_header_filter_config(col, df_missing, :status)
        @test result_missing.values !== nothing
        @test length(result_missing.values) == 3
        @test any(v -> v["label"] == "(null)", result_missing.values)

        # Test with Nothing values
        df_nothing = DataFrame(status = ["Active", nothing, "Inactive"])
        result_nothing = TableExplorer.create_header_filter_config(col, df_nothing, :status)
        @test result_nothing.values !== nothing
        @test length(result_nothing.values) == 3
        @test any(v -> v["label"] == "(null)", result_nothing.values)

        # Test with both Missing and Nothing - should only create one (null) option
        df_both = DataFrame(status = ["Active", missing, nothing, "Inactive"])
        result_both = TableExplorer.create_header_filter_config(col, df_both, :status)
        @test result_both.values !== nothing
        @test length(result_both.values) == 3  # Active, Inactive, (null) - not 4!
        @test any(v -> v["label"] == "(null)", result_both.values)
        @test count(v -> v["label"] == "(null)", result_both.values) == 1  # Only one null entry

        # Test explicit multiselect
        col_multiselect = ColumnCategorical(multiselect=true)
        result_multi = TableExplorer.create_header_filter_config(col_multiselect, df, :status)
        @test result_multi.multiselect == true
        @test result_multi.filter_func == "in"

        # Test single select (explicit)
        col_single = ColumnCategorical(multiselect=false)
        result_single = TableExplorer.create_header_filter_config(col_single, df, :status)
        @test result_single.multiselect == false
        @test result_single.filter_func == "="
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

        # Test with integers - should use String() not toLocaleString()
        df_int = DataFrame(count = [1, 2, 3])
        result_int = TableExplorer.create_formatter(col_auto, df_int, :count)
        @test occursin("String(val)", result_int)
        @test !occursin("toLocaleString()", result_int)

        # Test with Union{Missing, Float64} - should use toFixed() for consistent decimal separator
        df_missing = DataFrame(value = [1.23, missing, 4.56])
        result_missing = TableExplorer.create_formatter(col_auto, df_missing, :value)
        @test occursin("toFixed", result_missing)
        @test !occursin("toLocaleString()", result_missing)
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


    @testset "create_column_config" begin
        df = DataFrame(value = [1.5, 2.5], name = ["A", "B"], status = ["Active", "Inactive"])

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

        # Test with categorical column (dropdown - default is now multiselect)
        col_cat = ColumnCategorical()
        config_cat = TableExplorer.create_column_config(df, :status, col_cat)
        @test config_cat["headerFilter"] == "list"
        @test haskey(config_cat, "headerFilterParams")
        @test haskey(config_cat["headerFilterParams"], "values")
        @test length(config_cat["headerFilterParams"]["values"]) == 2
        @test haskey(config_cat["headerFilterParams"], "multiselect")  # Present since default is multiselect=true
        @test config_cat["headerFilterParams"]["multiselect"] == true
        @test config_cat["headerFilterFunc"] == "in"

        # Test with categorical column (explicit single select)
        col_cat_single = ColumnCategorical(multiselect=false)
        config_cat_single = TableExplorer.create_column_config(df, :status, col_cat_single)
        @test config_cat_single["headerFilter"] == "list"
        @test !haskey(config_cat_single["headerFilterParams"], "multiselect")  # Not present for single select
        @test config_cat_single["headerFilterFunc"] == "="
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

        # Test with Nothing type
        df_nothing = DataFrame(value = [nothing, nothing])
        result = TableExplorer.auto_detect_column_type(df_nothing, :value)
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

    @testset "ColumnHeatmap construction" begin
        # Test defaults
        col = ColumnHeatmap()
        @test col.min_value === nothing
        @test col.max_value === nothing
        @test col.alignment == :center
        @test col.palette == TableExplorer.CONTINUOUS_PALETTE

        # Test with explicit min/max
        col_custom = ColumnHeatmap(min_value=0.0, max_value=100.0)
        @test col_custom.min_value == 0.0
        @test col_custom.max_value == 100.0

        # Test with custom alignment
        col_align = ColumnHeatmap(alignment=:right)
        @test col_align.alignment == :right

        # Test with custom palette
        custom_palette = ["#000000", "#ffffff"]
        col_palette = ColumnHeatmap(palette=custom_palette)
        @test col_palette.palette == custom_palette
    end

    @testset "create_header_filter_config - ColumnHeatmap" begin
        df = DataFrame(value = [1.5, 2.5, 3.5])

        # ColumnHeatmap has no filter
        col = ColumnHeatmap()
        result = TableExplorer.create_header_filter_config(col, df, :value)
        @test result isa TableExplorer.HeaderFilterConfig
        @test result.filter_type == ""
        @test result.filter_func == ""
        @test result.placeholder == ""
        @test result.values === nothing
    end

    @testset "create_formatter - ColumnHeatmap" begin
        # Test with auto min/max calculation
        df = DataFrame(value = [1.0, 2.0, 3.0, 4.0, 5.0])
        col = ColumnHeatmap()
        result = TableExplorer.create_formatter(col, df, :value)
        @test result isa String
        @test occursin("var minVal = 1.0", result)
        @test occursin("var maxVal = 5.0", result)
        @test occursin("palette", result)
        @test occursin("return '';", result)  # Should return empty string

        # Test with explicit min/max
        col_explicit = ColumnHeatmap(min_value=0.0, max_value=10.0)
        result = TableExplorer.create_formatter(col_explicit, df, :value)
        @test occursin("var minVal = 0.0", result)
        @test occursin("var maxVal = 10.0", result)

        # Test with missing/nothing values
        df_missing = DataFrame(value = [1.0, missing, nothing, 3.0])
        result_missing = TableExplorer.create_formatter(col, df_missing, :value)
        @test occursin("var minVal = 1.0", result_missing)
        @test occursin("var maxVal = 3.0", result_missing)

        # Test with NaN/Inf values - should be excluded from min/max
        df_special = DataFrame(value = [1.0, NaN, Inf, -Inf, 5.0])
        result_special = TableExplorer.create_formatter(col, df_special, :value)
        @test occursin("var minVal = 1.0", result_special)
        @test occursin("var maxVal = 5.0", result_special)

        # Test min==max edge case
        df_same = DataFrame(value = [2.0, 2.0, 2.0])
        result_same = TableExplorer.create_formatter(col, df_same, :value)
        @test occursin("var minVal = 2.0", result_same)
        @test occursin("var maxVal = 3.0", result_same)  # Should be min + 1

        # Test empty column (all missing/NaN)
        df_empty = DataFrame(value = [missing, NaN, nothing])
        result_empty = TableExplorer.create_formatter(col, df_empty, :value)
        @test occursin("var minVal = 0.0", result_empty)  # Default min
        @test occursin("var maxVal = 1.0", result_empty)  # Default max

        # Test single value column
        df_single = DataFrame(value = [3.5])
        result_single = TableExplorer.create_formatter(col, df_single, :value)
        @test occursin("var minVal = 3.5", result_single)
        @test occursin("var maxVal = 4.5", result_single)  # min + 1

        # Test that palette is embedded
        custom_palette = ["#ff0000", "#00ff00", "#0000ff"]
        col_palette = ColumnHeatmap(palette=custom_palette)
        result_palette = TableExplorer.create_formatter(col_palette, df, :value)
        @test occursin("#ff0000", result_palette)
        @test occursin("#00ff00", result_palette)
        @test occursin("#0000ff", result_palette)
    end

    @testset "get_alignment - ColumnHeatmap" begin
        @test TableExplorer.get_alignment(ColumnHeatmap()) == "center"
        @test TableExplorer.get_alignment(ColumnHeatmap(alignment=:left)) == "left"
        @test TableExplorer.get_alignment(ColumnHeatmap(alignment=:right)) == "right"
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

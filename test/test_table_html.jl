using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames
using Tables
using JSON

@testset "Table HTML Tests" begin

    @testset "config_to_json" begin
        # Test basic config without functions
        config = Dict("title" => "Test", "field" => "test_field")
        result = TableExplorer.config_to_json(config)
        @test occursin("\"title\"", result)
        @test occursin("\"Test\"", result)
        @test occursin("\"field\"", result)

        # Test config with formatter function
        config_with_func = Dict(
            "title" => "Value",
            "formatter" => "function(cell) { return cell.getValue(); }"
        )
        result = TableExplorer.config_to_json(config_with_func)
        @test occursin("\"formatter\": function(cell)", result)
        @test !occursin("\"function(cell)", result)  # Should not be double-quoted

        # Test with titleFormatter
        config_title_func = Dict(
            "title" => "Header",
            "titleFormatter" => "function(cell) { return 'Custom'; }"
        )
        result = TableExplorer.config_to_json(config_title_func)
        @test occursin("\"titleFormatter\": function(cell)", result)

        # Test with custom formatter ending with "Formatter"
        config_custom_formatter = Dict(
            "title" => "Custom",
            "customFormatter" => "function(cell) { return 'test'; }"
        )
        result = TableExplorer.config_to_json(config_custom_formatter)
        @test occursin("\"customFormatter\": function(cell)", result)
        @test !occursin("\"function(cell)", result)

        # Test with leading whitespace in function
        config_whitespace = Dict(
            "formatter" => "  function(cell) { return cell.getValue(); }"
        )
        result = TableExplorer.config_to_json(config_whitespace)
        @test occursin("\"formatter\":   function(cell)", result)

        # Test that non-function strings are properly quoted
        config_non_func = Dict(
            "formatter" => "not a function",
            "titleFormatter" => "also not a function"
        )
        result = TableExplorer.config_to_json(config_non_func)
        @test occursin("\"not a function\"", result)
        @test occursin("\"also not a function\"", result)

        # Test with edge case: formatter key but not a string value
        config_non_string = Dict(
            "formatter" => 123,
            "title" => "Test"
        )
        result = TableExplorer.config_to_json(config_non_string)
        @test occursin("\"formatter\": 123", result)
        @test occursin("\"title\": \"Test\"", result)
    end

    @testset "is_js_function" begin
        # Test valid JavaScript functions
        @test TableExplorer.is_js_function("formatter", "function(cell) { return 1; }")
        @test TableExplorer.is_js_function("titleFormatter", "function() { return 'test'; }")
        @test TableExplorer.is_js_function("customFormatter", "function(x) { return x; }")
        @test TableExplorer.is_js_function("myFormatter", "function() {}")

        # Test with leading whitespace
        @test TableExplorer.is_js_function("formatter", "  function() {}")
        @test TableExplorer.is_js_function("formatter", "\tfunction() {}")

        # Test invalid cases
        @test !TableExplorer.is_js_function("formatter", "not a function")
        @test !TableExplorer.is_js_function("formatter", "func() {}")  # doesn't start with "function"
        @test !TableExplorer.is_js_function("title", "function() {}")  # wrong key
        @test !TableExplorer.is_js_function("formatter", 123)  # not a string
        @test !TableExplorer.is_js_function("myFormat", "function() {}")  # doesn't end with "Formatter"
    end

    @testset "table_html - basic functionality" begin
        df = DataFrame(
            id = [1, 2, 3],
            name = ["Alice", "Bob", "Charlie"],
            value = [100.5, 200.75, 300.25]
        )

        html = table_html(df)

        # Test that HTML string is returned
        @test html isa String
        @test !isempty(html)

        # Test that HTML contains expected structure
        @test occursin("<html", html)
        @test occursin("</html>", html)
        @test occursin("<body", html)
        @test occursin("</body>", html)

        # Test that data is embedded
        @test occursin("Alice", html)
        @test occursin("Bob", html)
        @test occursin("Charlie", html)

        # Test that column names are present
        @test occursin("id", html)
        @test occursin("name", html)
        @test occursin("value", html)

        # Test that row and column counts are present (in HTML format: "Rows: X / Y")
        @test occursin("Rows:", html)
        @test occursin("Columns:", html)
        @test occursin("/ 3", html)  # Total rows
        @test occursin("</span> / 3 |", html)  # Row count format
    end

    @testset "table_html - column types" begin
        df = DataFrame(
            text_col = ["A", "B", "C"],
            num_col = [1.5, 2.5, 3.5],
            cat_col = ["X", "Y", "X"],
            bool_col = [true, false, true]
        )

        html = table_html(df,
            :text_col => ColumnText(search_type=:exact),
            :num_col => ColumnNumeric(decimal_places=2),
            :cat_col => ColumnCategorical(color_map=Dict("X" => "#ff0000", "Y" => "#00ff00")),
            :bool_col => ColumnBoolean(true_label="Yes", false_label="No")
        )

        @test html isa String
        @test !isempty(html)

        # Verify column-specific configurations are present
        @test occursin("toFixed(2)", html)  # Numeric formatter
        @test occursin("#ff0000", html)  # Categorical colors
        @test occursin("Yes", html)  # Boolean labels
        @test occursin("No", html)
    end

    @testset "table_html - String and Symbol keys" begin
        df = DataFrame(a = [1, 2], b = [3, 4])

        # Test with String keys
        html1 = table_html(df, "a" => ColumnNumeric(decimal_places=1))
        @test occursin("toFixed(1)", html1)

        # Test with Symbol keys
        html2 = table_html(df, :b => ColumnNumeric(decimal_places=2))
        @test occursin("toFixed(2)", html2)

        # Test mixed
        html3 = table_html(df,
            "a" => ColumnNumeric(decimal_places=1),
            :b => ColumnNumeric(decimal_places=2)
        )
        @test occursin("toFixed(1)", html3)
        @test occursin("toFixed(2)", html3)
    end

    @testset "table_html - auto_categorical_threshold" begin
        df = DataFrame(
            status = repeat(["A", "B", "C"], 10),
            id = 1:30
        )

        # Test with threshold enabled
        html_with_threshold = table_html(df, auto_categorical_threshold=5)
        # Status should be categorical (3 unique values <= 5)
        @test occursin("backgroundColor", html_with_threshold)

        # Test with threshold disabled
        html_no_threshold = table_html(df, auto_categorical_threshold=nothing)
        # Should have less categorical formatting
        @test html_no_threshold isa String

        # Test with low threshold
        html_low_threshold = table_html(df, auto_categorical_threshold=2)
        # Status has 3 unique values > 2, so should not be categorical
        @test html_low_threshold isa String
    end

    @testset "table_html - special values" begin
        df = DataFrame(
            normal = [1.0, 2.0, 3.0],
            with_nan = [1.0, NaN, 3.0],
            with_inf = [1.0, Inf, -Inf],
            with_missing = [1, missing, 3]
        )

        html = table_html(df)
        @test html isa String

        # Verify HTML is generated successfully even with special values
        @test occursin("normal", html)
        @test occursin("with_nan", html)
        @test occursin("with_inf", html)
        @test occursin("with_missing", html)
    end

    @testset "table_html - empty table" begin
        df = DataFrame(a = Int[], b = String[])

        html = table_html(df)
        @test html isa String
        @test occursin("Rows:", html)
        @test occursin("Columns:</strong> 2", html)
    end

    @testset "table_html - single row" begin
        df = DataFrame(x = [42], y = ["test"])

        html = table_html(df)
        @test html isa String
        @test occursin("/ 1 |", html)  # 1 total row
        @test occursin("42", html)
        @test occursin("test", html)
    end

    @testset "table_html - single column" begin
        df = DataFrame(value = [1, 2, 3, 4, 5])

        html = table_html(df)
        @test html isa String
        @test occursin("/ 5 |", html)  # 5 total rows
        @test occursin("Columns:</strong> 1", html)
    end

    @testset "table_html - Tables.jl interface compatibility" begin
        # Test with NamedTuple
        nt = (a = [1, 2, 3], b = ["x", "y", "z"])
        html_nt = table_html(nt)
        @test html_nt isa String
        @test occursin("\"x\"", html_nt)

        # Test with DataFrame (already tested above)
        df = DataFrame(c = [1, 2], d = [3, 4])
        html_df = table_html(df)
        @test html_df isa String

        # Test that non-table throws error
        @test_throws ArgumentError table_html([1, 2, 3])
    end

    @testset "table_html - large table" begin
        # Test with a moderately large table
        n = 1000
        df = DataFrame(
            id = 1:n,
            category = rand(["A", "B", "C", "D"], n),
            value = rand(n) .* 100,
            flag = rand(Bool, n)
        )

        html = table_html(df)
        @test html isa String
        @test occursin("/ 1000 |", html)  # 1000 total rows

        # Test that all data is embedded (spot check)
        @test occursin("id", html)
        @test occursin("category", html)
    end

    @testset "table_html - column name variations" begin
        # Test with various column name types
        df = DataFrame(
            Symbol("normal") => [1, 2],
            Symbol("with space") => [3, 4],
            Symbol("with-dash") => [5, 6],
            Symbol("with_underscore") => [7, 8]
        )

        html = table_html(df)
        @test html isa String
        @test occursin("normal", html)
        @test occursin("with space", html)
        @test occursin("with-dash", html)
        @test occursin("with_underscore", html)
    end

    @testset "table_html - template embedding" begin
        df = DataFrame(x = [1])
        html = table_html(df)

        # Verify that placeholders are replaced
        @test !occursin("{{CSS_CONTENT}}", html)
        @test !occursin("{{JS_CONTENT}}", html)
        @test !occursin("{{TABLE_DATA}}", html)
        @test !occursin("{{COLUMNS}}", html)
        @test !occursin("{{NROWS}}", html)
        @test !occursin("{{NCOLS}}", html)

        # Verify CSS and JS content is embedded
        @test occursin("<style>", html) || occursin("table", html)  # Some CSS content
        @test occursin("Tabulator", html) || occursin("var table", html)  # Some JS content
    end

    @testset "table_html - JSON serialization" begin
        df = DataFrame(
            str = ["test", "data"],
            num = [1, 2],
            bool = [true, false]
        )

        html = table_html(df)

        # Verify valid JSON structure is present
        # (We can't easily parse it from the HTML, but we can check for structure)
        @test occursin("\"str\"", html)
        @test occursin("\"num\"", html)
        @test occursin("\"bool\"", html)
    end

    @testset "table_html - override auto-detection" begin
        # Create a column that would be auto-detected as categorical
        df = DataFrame(status = ["A", "B", "A", "B"])

        # Override to use text
        html = table_html(df,
            :status => ColumnText(),
            auto_categorical_threshold=10
        )

        # Should not have categorical colors because we explicitly set it to ColumnText
        # (This is a bit tricky to test without parsing HTML, but we can check structure)
        @test html isa String
        @test occursin("status", html)
    end

    @testset "table_html - multiple formatters" begin
        df = DataFrame(
            a = [1.5, 2.5],
            b = [true, false],
            c = ["X", "Y"]
        )

        html = table_html(df,
            :a => ColumnNumeric(decimal_places=3),
            :b => ColumnBoolean(true_label="T", false_label="F"),
            :c => ColumnCategorical(color_map=Dict("X" => "#aabbcc", "Y" => "#ddeeff"))
        )

        @test occursin("toFixed(3)", html)
        @test occursin("\"T\"", html) || occursin("'T'", html)
        @test occursin("#aabbcc", html)
        @test occursin("#ddeeff", html)
    end
end

using Test
using TableExplorer
using DataFrames
using Tables

@testset "Utils Tests" begin

    @testset "DEFAULT_CATEGORICAL_PALETTE" begin
        @test length(TableExplorer.DEFAULT_CATEGORICAL_PALETTE) == 15
        @test all(color -> startswith(color, "#"), TableExplorer.DEFAULT_CATEGORICAL_PALETTE)
        @test all(color -> length(color) == 7, TableExplorer.DEFAULT_CATEGORICAL_PALETTE)
    end

    @testset "assign_color_to_value" begin
        palette = ["#ff0000", "#00ff00", "#0000ff"]

        # Test first value
        result = TableExplorer.assign_color_to_value((1, "A"), palette)
        @test result isa Pair{String, String}
        @test result.first == "A"
        @test result.second == "#ff0000"

        # Test second value
        result = TableExplorer.assign_color_to_value((2, "B"), palette)
        @test result.first == "B"
        @test result.second == "#00ff00"

        # Test wrapping (4th value should get first color)
        result = TableExplorer.assign_color_to_value((4, "D"), palette)
        @test result.first == "D"
        @test result.second == "#ff0000"

        # Test with integer values
        result = TableExplorer.assign_color_to_value((1, 42), palette)
        @test result.first == "42"
        @test result.second == "#ff0000"
    end

    @testset "generate_categorical_colors" begin
        palette = ["#ff0000", "#00ff00", "#0000ff"]

        # Test basic generation
        values = ["C", "A", "B"]
        result = TableExplorer.generate_categorical_colors(values, palette)
        @test result isa Dict{String, String}
        @test length(result) == 3
        @test haskey(result, "A")
        @test haskey(result, "B")
        @test haskey(result, "C")

        # Test deterministic sorting - "A" comes first alphabetically
        @test result["A"] == "#ff0000"
        @test result["B"] == "#00ff00"
        @test result["C"] == "#0000ff"

        # Test with more values than colors (wrapping)
        values = ["A", "B", "C", "D"]
        result = TableExplorer.generate_categorical_colors(values, palette)
        @test length(result) == 4
        @test result["D"] == "#ff0000"  # Wraps to first color

        # Test with default palette
        values = ["X", "Y", "Z"]
        result = TableExplorer.generate_categorical_colors(values)
        @test length(result) == 3
    end

    @testset "row_to_dict" begin
        df = DataFrame(
            a = [1, 2, 3],
            b = ["x", "y", "z"],
            c = [1.5, 2.5, 3.5]
        )

        # Test normal row
        row = Tables.rows(df)[1]
        colnames = [:a, :b, :c]
        result = TableExplorer.row_to_dict(row, colnames)
        @test result isa Dict{String, Any}
        @test result["a"] == 1
        @test result["b"] == "x"
        @test result["c"] == 1.5

        # Test with NaN
        df_nan = DataFrame(a = [NaN, 1.0], b = [2.0, 3.0])
        row_nan = Tables.rows(df_nan)[1]
        result = TableExplorer.row_to_dict(row_nan, [:a, :b])
        @test result["a"] === nothing
        @test result["b"] == 2.0

        # Test with Inf
        df_inf = DataFrame(a = [Inf, 1.0], b = [2.0, -Inf])
        row_inf = Tables.rows(df_inf)[1]
        result = TableExplorer.row_to_dict(row_inf, [:a, :b])
        @test result["a"] === nothing
        @test result["b"] == 2.0

        row_inf2 = Tables.rows(df_inf)[2]
        result2 = TableExplorer.row_to_dict(row_inf2, [:a, :b])
        @test result2["a"] == 1.0
        @test result2["b"] === nothing

        # Test with missing values
        df_missing = DataFrame(a = [missing, 1], b = [2, missing])
        row_missing = Tables.rows(df_missing)[1]
        result = TableExplorer.row_to_dict(row_missing, [:a, :b])
        @test ismissing(result["a"])
        @test result["b"] == 2
    end

    @testset "js_string_literal" begin
        # Test basic string
        @test TableExplorer.js_string_literal("hello") == "hello"

        # Test single quotes
        @test TableExplorer.js_string_literal("It's true") == "It\\'s true"

        # Test backslashes
        @test TableExplorer.js_string_literal("path\\to\\file") == "path\\\\to\\\\file"

        # Test newlines
        @test TableExplorer.js_string_literal("Line 1\nLine 2") == "Line 1\\nLine 2"

        # Test carriage returns
        @test TableExplorer.js_string_literal("Line 1\rLine 2") == "Line 1\\rLine 2"

        # Test combined escaping
        @test TableExplorer.js_string_literal("It's\na test\\file") == "It\\'s\\na test\\\\file"

        # Test empty string
        @test TableExplorer.js_string_literal("") == ""

        # Test multiple quotes
        @test TableExplorer.js_string_literal("'quoted' text") == "\\'quoted\\' text"
    end

    @testset "create_categorical_formatter" begin
        color_map = Dict(
            "Pass" => "#28a745",
            "Fail" => "#dc3545"
        )

        result = TableExplorer.create_categorical_formatter(color_map)
        @test result isa String
        @test startswith(result, "function(cell)")
        @test occursin("'Pass': '#28a745'", result)
        @test occursin("'Fail': '#dc3545'", result)
        @test occursin("backgroundColor", result)
        @test occursin("brightness", result)
        @test occursin("#f0f0f0", result)  # Default color

        # Test empty color map
        empty_map = Dict{String, String}()
        result_empty = TableExplorer.create_categorical_formatter(empty_map)
        @test occursin("colorMap = {\n\n  }", result_empty)

        # Test with special characters in keys
        color_map_special = Dict(
            "It's OK" => "#28a745",
            "Don't fail" => "#dc3545",
            "Line\nbreak" => "#ffc107"
        )
        result_special = TableExplorer.create_categorical_formatter(color_map_special)
        @test occursin("It\\'s OK", result_special)
        @test occursin("Don\\'t fail", result_special)
        @test occursin("Line\\nbreak", result_special)
    end

    @testset "open_in_browser" begin
        # We can't really test browser opening without side effects,
        # but we can test it doesn't error on supported platforms
        mktempdir() do tmpdir
            test_file = joinpath(tmpdir, "test.html")
            write(test_file, "<html><body>Test</body></html>")

            # Test that it doesn't throw an error
            # (actual browser opening behavior varies by platform)
            if Sys.isapple() || Sys.iswindows() || Sys.islinux()
                # We can't test actual opening without side effects
                # Just verify the function exists and is callable
                @test hasmethod(TableExplorer.open_in_browser, (String,))
            else
                # On unsupported platforms, should warn
                @test_logs (:warn,) TableExplorer.open_in_browser(test_file)
            end
        end
    end

    @testset "get_column_data helper pattern" begin
        # Test the common pattern used throughout the codebase
        df = DataFrame(x = [1, 2, 3], y = ["a", "b", "c"])
        cols = Tables.columns(df)

        col_x = Tables.getcolumn(cols, :x)
        @test col_x == [1, 2, 3]

        col_y = Tables.getcolumn(cols, :y)
        @test col_y == ["a", "b", "c"]
    end
end

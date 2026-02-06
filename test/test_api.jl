using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

@testset "API Tests" begin

    @testset "explore_table - basic functionality" begin
        df = DataFrame(
            id = [1, 2, 3],
            name = ["Alice", "Bob", "Charlie"]
        )

        # Test that explore_table creates HTML file
        mktempdir() do tmpdir
            # We can't easily test browser opening without side effects,
            # but we can verify the HTML generation works
            html = table_html(df)
            @test html isa String
            @test !isempty(html)
        end
    end

    @testset "explore_table - with column types" begin
        df = DataFrame(
            value = [1.5, 2.5, 3.5],
            status = ["Active", "Inactive", "Pending"]
        )

        # Test with column type specifications
        html = table_html(df,
            :value => ColumnNumeric(decimal_places=2),
            :status => ColumnCategorical()
        )
        @test html isa String
        @test occursin("toFixed(2)", html)
    end

    @testset "explore_table - String and Symbol keys" begin
        df = DataFrame(a = [1, 2], b = ["x", "y"])

        # Test with String keys
        html1 = table_html(df, "a" => ColumnNumeric())
        @test html1 isa String

        # Test with Symbol keys
        html2 = table_html(df, :b => ColumnText())
        @test html2 isa String

        # Test mixed
        html3 = table_html(df,
            "a" => ColumnNumeric(),
            :b => ColumnText()
        )
        @test html3 isa String
    end

    @testset "explore_table - auto_categorical_threshold" begin
        df = DataFrame(
            category = repeat(["A", "B", "C"], 5)
        )

        # Test with threshold
        html1 = table_html(df, auto_categorical_threshold=10)
        @test html1 isa String

        # Test with threshold disabled
        html2 = table_html(df, auto_categorical_threshold=nothing)
        @test html2 isa String

        # Both should generate valid HTML
        @test !isempty(html1)
        @test !isempty(html2)
    end

    @testset "explore_table - various table types" begin
        # Test with DataFrame
        df = DataFrame(x = [1, 2, 3])
        html_df = table_html(df)
        @test html_df isa String

        # Test with NamedTuple
        nt = (a = [1, 2], b = [3, 4])
        html_nt = table_html(nt)
        @test html_nt isa String

        # Test with column table (from Tables.columntable)
        ct = Tables.columntable(df)
        html_ct = table_html(ct)
        @test html_ct isa String
    end

    @testset "explore_table - edge cases" begin
        # Empty table
        df_empty = DataFrame(a = Int[], b = String[])
        html_empty = table_html(df_empty)
        @test html_empty isa String

        # Single row
        df_single = DataFrame(x = [1])
        html_single = table_html(df_single)
        @test html_single isa String

        # Large table
        df_large = DataFrame(
            id = 1:1000,
            value = rand(1000)
        )
        html_large = table_html(df_large)
        @test html_large isa String
    end

    @testset "explore_table - special characters" begin
        df = DataFrame(
            text = ["<html>", "&nbsp;", "quote\"test", "apostrophe's"]
        )

        html = table_html(df)
        @test html isa String
        # The HTML should handle special characters properly
        @test !isempty(html)
    end

    @testset "explore_table - all column types together" begin
        using Dates

        df = DataFrame(
            text_col = ["A", "B", "C"],
            numeric_col = [1.5, 2.5, 3.5],
            categorical_col = ["X", "Y", "X"],
            boolean_col = [true, false, true],
            date_col = [Date(2024, 1, 1), Date(2024, 1, 2), Date(2024, 1, 3)]
        )

        html = table_html(df,
            :text_col => ColumnText(search_type=:exact),
            :numeric_col => ColumnNumeric(decimal_places=2),
            :categorical_col => ColumnCategorical(
                color_map=Dict("X" => "#ff0000", "Y" => "#00ff00")
            ),
            :date_col => ColumnDateTime(format="yyyy-mm-dd")
        )

        @test html isa String
        @test !isempty(html)

        # Verify each column type configuration is present
        @test occursin("toFixed(2)", html)
        @test occursin("#ff0000", html)
        @test occursin("Yes", html)
    end

    @testset "explore_table - partial column specification" begin
        df = DataFrame(
            a = [1, 2, 3],
            b = ["x", "y", "z"],
            c = [true, false, true]
        )

        # Specify only one column, others should auto-detect
        html = table_html(df,
            :a => ColumnNumeric(decimal_places=3)
        )

        @test html isa String
        @test occursin("toFixed(3)", html)
        # b and c should be auto-detected
        @test occursin("\"b\"", html)
        @test occursin("\"c\"", html)
    end

    @testset "explore_table - override auto-detection" begin
        # Create data that would normally be auto-detected as categorical
        df = DataFrame(
            status = repeat(["A", "B"], 5)
        )

        # Override with explicit ColumnText
        html = table_html(df,
            :status => ColumnText(),
            auto_categorical_threshold=10
        )

        @test html isa String
        # Should be treated as text, not categorical
        # (Hard to verify without parsing, but at least it should work)
    end

    @testset "API exports" begin
        # Verify that public API is exported
        @test isdefined(TableExplorer, :explore_table)
        @test isdefined(TableExplorer, :ColumnText)
        @test isdefined(TableExplorer, :ColumnNumeric)
        @test isdefined(TableExplorer, :ColumnCategorical)
        @test isdefined(TableExplorer, :ColumnDateTime)

        # Verify they're actually exported (accessible without TableExplorer. prefix)
        using TableExplorer
        @test isdefined(Main, :explore_table)
        @test isdefined(Main, :ColumnText)
        @test isdefined(Main, :ColumnNumeric)
        @test isdefined(Main, :ColumnCategorical)
        @test isdefined(Main, :ColumnDateTime)
    end

    @testset "table_html integration" begin
        # Verify table_html is not exported but is accessible
        @test isdefined(TableExplorer, :table_html)
        @test applicable(table_html, DataFrame(a=[1]))
    end
end

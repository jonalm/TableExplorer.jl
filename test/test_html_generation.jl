using Test
using TableExplorer
using DataFrames
using JSON

@testset "HTML Generation Tests" begin

    @testset "ColumnCategorical generates dropdown filter" begin
        df = DataFrame(
            status = ["Active", "Inactive", "Pending"],
            value = [1, 2, 3]
        )

        # Generate HTML with categorical column
        html = TableExplorer.table_html(df,
            :status => ColumnCategorical()
        )

        @test html isa String
        @test !isempty(html)

        # Verify it's valid HTML
        @test occursin("<!DOCTYPE html>", html)
        @test occursin("<html", html)
        @test occursin("</html>", html)

        # Verify Tabulator.js is included
        @test occursin("tabulator", html)

        # Extract columns configuration from HTML
        columns_start = findfirst("const columns = ", html)
        @test !isnothing(columns_start)

        # Verify the status column has list filter (not select)
        @test occursin("\"headerFilter\": \"list\"", html)
        @test !occursin("\"headerFilter\": \"select\"", html)

        # Verify headerFilterParams is present
        @test occursin("\"headerFilterParams\"", html)

        # Verify the values are present in the dropdown
        @test occursin("\"label\":\"Active\"", html) || occursin("\"label\": \"Active\"", html)
        @test occursin("\"label\":\"Inactive\"", html) || occursin("\"label\": \"Inactive\"", html)
        @test occursin("\"label\":\"Pending\"", html) || occursin("\"label\": \"Pending\"", html)

        # Verify filter function is set (default is now multiselect, so "in")
        @test occursin("\"headerFilterFunc\": \"in\"", html) || occursin("\"headerFilterFunc\":\"in\"", html)

        # Verify multiselect is present (since default is multiselect=true)
        @test occursin("\"multiselect\"", html)

        # Verify placeholder is set
        @test occursin("\"headerFilterPlaceholder\": \"Select...\"", html)
    end

    @testset "ColumnCategorical with custom labels" begin
        df = DataFrame(
            status = ["Pass", "Fail", "Pass"],
            value = [1, 2, 3]
        )

        # Generate HTML with custom boolean labels
        html = TableExplorer.table_html(df,
            :status => ColumnCategorical(
                color_map=Dict("Pass" => "#00ff00", "Fail" => "#ff0000")
            )
        )

        @test html isa String

        # Verify dropdown is configured
        @test occursin("\"headerFilter\": \"list\"", html)

        # Verify the custom colors are in the formatter
        @test occursin("#00ff00", html)
        @test occursin("#ff0000", html)
    end

    @testset "Multiple column types with dropdowns" begin
        df = DataFrame(
            status = ["Active", "Inactive", "Active"],
            flag = [true, false, true],
            score = [1.5, 2.5, 3.5]
        )

        html = TableExplorer.table_html(df,
            :status => ColumnCategorical(),
            :score => ColumnNumeric(decimal_places=2)
        )

        @test html isa String

        # Count occurrences of list filters (should be 2: status and flag)
        list_filter_count = length(collect(eachmatch(r"\"headerFilter\":\s*\"list\"", html)))
        @test list_filter_count == 2

        # Numeric column should have input filter
        @test occursin("\"headerFilter\": \"input\"", html)
    end

    @testset "Auto-detected categorical gets dropdown" begin
        # Create DataFrame with categorical column (few unique values)
        df = DataFrame(
            category = ["A", "B", "A", "B", "C"],
            value = [1, 2, 3, 4, 5]
        )

        # Use auto-detection
        html = TableExplorer.table_html(df, auto_categorical_threshold=5)

        @test html isa String

        # Category column should auto-detect as categorical and get list filter
        @test occursin("\"headerFilter\": \"list\"", html)

        # Verify dropdown values for auto-detected categorical
        @test occursin("\"label\":\"A\"", html) || occursin("\"label\": \"A\"", html)
        @test occursin("\"label\":\"B\"", html) || occursin("\"label\": \"B\"", html)
        @test occursin("\"label\":\"C\"", html) || occursin("\"label\": \"C\"", html)
    end

    @testset "ColumnCategorical with missing values" begin
        df = DataFrame(
            status = ["Active", missing, "Inactive"]
        )

        html = TableExplorer.table_html(df,
            :status => ColumnCategorical()
        )

        @test html isa String

        # Verify dropdown includes (null) label (not (missing))
        @test occursin("\"label\":\"(null)\"", html) || occursin("\"label\": \"(null)\"", html)

        # Verify list filter is used
        @test occursin("\"headerFilter\": \"list\"", html)
    end

    @testset "ColumnCategorical with nothing values" begin
        df = DataFrame(
            status = ["Active", nothing, "Inactive"]
        )

        html = TableExplorer.table_html(df,
            :status => ColumnCategorical()
        )

        @test html isa String

        # Verify dropdown includes (null) label (not (nothing))
        @test occursin("\"label\":\"(null)\"", html) || occursin("\"label\": \"(null)\"", html)

        # Verify list filter is used
        @test occursin("\"headerFilter\": \"list\"", html)
    end

    @testset "ColumnCategorical with both missing and nothing" begin
        df = DataFrame(
            status = ["Active", missing, nothing, "Inactive"]
        )

        html = TableExplorer.table_html(df,
            :status => ColumnCategorical()
        )

        @test html isa String

        # Verify only ONE (null) option appears, not separate (missing) and (nothing)
        @test occursin("\"label\":\"(null)\"", html) || occursin("\"label\": \"(null)\"", html)
        @test !occursin("\"label\":\"(missing)\"", html) && !occursin("\"label\": \"(missing)\"", html)
        @test !occursin("\"label\":\"(nothing)\"", html) && !occursin("\"label\": \"(nothing)\"", html)

        # Count occurrences of (null) - should be exactly 1
        null_count = length(collect(eachmatch(r"\"label\":\s*\"\(null\)\"", html)))
        @test null_count == 1

        # Verify list filter is used
        @test occursin("\"headerFilter\": \"list\"", html)
    end

    @testset "No select filter type in generated HTML" begin
        # Create various column types
        df = DataFrame(
            cat = ["A", "B", "C"],
            bool = [true, false, true],
            num = [1, 2, 3],
            text = ["foo", "bar", "baz"]
        )

        html = TableExplorer.table_html(df,
            :cat => ColumnCategorical(),
            :num => ColumnNumeric(),
            :text => ColumnText()
        )

        @test html isa String

        # CRITICAL: Ensure "select" is never used as headerFilter type
        # (Tabulator 6.3 replaced "select" with "list")
        @test !occursin("\"headerFilter\": \"select\"", html)
        @test !occursin("\"headerFilter\":\"select\"", html)
    end

    @testset "ColumnCategorical multiselect configuration" begin
        df = DataFrame(
            status = ["Active", "Inactive", "Pending"],
            value = [1, 2, 3]
        )

        # Test with multiselect enabled
        html = TableExplorer.table_html(df,
            :status => ColumnCategorical(multiselect=true)
        )

        @test html isa String

        # Verify multiselect is in headerFilterParams
        @test occursin("\"multiselect\": true", html) || occursin("\"multiselect\":true", html)

        # Verify filter function is "in" for multiselect
        @test occursin("\"headerFilterFunc\": \"in\"", html) || occursin("\"headerFilterFunc\":\"in\"", html)

        # Test without multiselect (explicit single select)
        html_single = TableExplorer.table_html(df,
            :status => ColumnCategorical(multiselect=false)
        )

        @test html_single isa String

        # Verify multiselect is NOT in headerFilterParams for single select
        @test !occursin("\"multiselect\"", html_single)

        # Verify filter function is "=" for single select
        @test occursin("\"headerFilterFunc\": \"=\"", html_single) || occursin("\"headerFilterFunc\":\"=\"", html_single)
    end

    @testset "ColumnNumeric dropdown with value types" begin
        df = DataFrame(
            value = [1.5, NaN, Inf, -Inf, missing, 2.5]
        )

        # Generate HTML with numeric dropdown
        html = TableExplorer.table_html(df,
            :value => ColumnNumeric(search_type=:dropdown)
        )

        @test html isa String

        # Verify list filter is used
        @test occursin("\"headerFilter\": \"list\"", html) || occursin("\"headerFilter\":\"list\"", html)

        # Verify all value types are present in dropdown
        @test occursin("\"label\":\"numerical\"", html) || occursin("\"label\": \"numerical\"", html)
        @test occursin("\"label\":\"NaN\"", html) || occursin("\"label\": \"NaN\"", html)
        @test occursin("\"label\":\"Infinity\"", html) || occursin("\"label\": \"Infinity\"", html)
        @test occursin("\"label\":\"-Infinity\"", html) || occursin("\"label\": \"-Infinity\"", html)
        @test occursin("\"label\":\"(null)\"", html) || occursin("\"label\": \"(null)\"", html)

        # Verify multiselect is enabled by default
        @test occursin("\"multiselect\": true", html) || occursin("\"multiselect\":true", html)

        # Verify custom filter function is used
        @test occursin("numericTypeFilter", html)
    end

    @testset "ColumnNumeric dropdown single select" begin
        df = DataFrame(
            value = [1.5, NaN, 2.5]
        )

        # Generate HTML with single select numeric dropdown
        html = TableExplorer.table_html(df,
            :value => ColumnNumeric(search_type=:dropdown, multiselect=false)
        )

        @test html isa String

        # Verify multiselect is NOT enabled
        @test !occursin("\"multiselect\"", html)

        # Verify single select filter function is used
        @test occursin("numericTypeSingleFilter", html)
    end

    @testset "ColumnNumeric dropdown only shows applicable types" begin
        # Test with only normal numbers (no special values)
        df_normal = DataFrame(value = [1.0, 2.0, 3.0])
        html_normal = TableExplorer.table_html(df_normal,
            :value => ColumnNumeric(search_type=:dropdown)
        )

        @test occursin("\"label\":\"numerical\"", html_normal) || occursin("\"label\": \"numerical\"", html_normal)
        @test !occursin("\"label\":\"NaN\"", html_normal) && !occursin("\"label\": \"NaN\"", html_normal)
        @test !occursin("\"label\":\"Infinity\"", html_normal) && !occursin("\"label\": \"Infinity\"", html_normal)
        @test !occursin("\"label\":\"(null)\"", html_normal) && !occursin("\"label\": \"(null)\"", html_normal)

        # Test with only NaN (no other special values)
        df_nan_only = DataFrame(value = [NaN, NaN])
        html_nan_only = TableExplorer.table_html(df_nan_only,
            :value => ColumnNumeric(search_type=:dropdown)
        )

        @test occursin("\"label\":\"NaN\"", html_nan_only) || occursin("\"label\": \"NaN\"", html_nan_only)
        @test !occursin("\"label\":\"numerical\"", html_nan_only) && !occursin("\"label\": \"numerical\"", html_nan_only)
        @test !occursin("\"label\":\"Infinity\"", html_nan_only) && !occursin("\"label\": \"Infinity\"", html_nan_only)
    end
end

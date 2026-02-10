using Test
using TableExplorer
using DataFrames

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

# Test boolean columns - values should be actual booleans, not strings
df_bool = DataFrame(active = [true, false, true, false])
result_bool = TableExplorer.create_header_filter_config(col, df_bool, :active)
@test result_bool.values !== nothing
@test length(result_bool.values) == 2
# Check that values are actual booleans, not strings
bool_values = [v["value"] for v in result_bool.values if v["label"] != "(null)"]
@test all(v -> v isa Bool, bool_values)
@test true in bool_values
@test false in bool_values
# Labels should still be strings for display
bool_labels = [v["label"] for v in result_bool.values if v["label"] != "(null)"]
@test all(v -> v isa String, bool_labels)
@test "true" in bool_labels
@test "false" in bool_labels

# Test boolean column with missing values
df_bool_missing = DataFrame(active = [true, false, missing])
result_bool_missing = TableExplorer.create_header_filter_config(col, df_bool_missing, :active)
@test result_bool_missing.values !== nothing
@test length(result_bool_missing.values) == 3
@test any(v -> v["label"] == "(null)", result_bool_missing.values)
# Non-null values should still be booleans
bool_values_missing = [v["value"] for v in result_bool_missing.values if v["label"] != "(null)"]
@test all(v -> v isa Bool, bool_values_missing)

using Test
using TableExplorer
using DataFrames

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

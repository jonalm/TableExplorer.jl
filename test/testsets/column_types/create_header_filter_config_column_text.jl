using Test
using TableExplorer
using DataFrames

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

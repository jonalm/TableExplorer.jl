using Test
using TableExplorer

# Test default
col = ColumnText()
@test col.search_type == :regex

# Test with explicit search type
col_exact = ColumnText(search_type=:exact)
@test col_exact.search_type == :exact

col_contains = ColumnText(search_type=:contains)
@test col_contains.search_type == :contains

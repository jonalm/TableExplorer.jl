using Test
using TableExplorer

# Test defaults
col = ColumnDateTime()
@test col.format == "yyyy-mm-dd HH:MM:SS"
@test col.search_type == :input

# Test with custom format
col_custom = ColumnDateTime(format="yyyy-mm-dd")
@test col_custom.format == "yyyy-mm-dd"

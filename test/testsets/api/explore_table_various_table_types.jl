using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames
using Tables

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

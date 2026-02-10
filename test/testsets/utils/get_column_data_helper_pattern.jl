using Test
using DataFrames
using Tables

# Test the common pattern used throughout the codebase
df = DataFrame(x = [1, 2, 3], y = ["a", "b", "c"])
cols = Tables.columns(df)

col_x = Tables.getcolumn(cols, :x)
@test col_x == [1, 2, 3]

col_y = Tables.getcolumn(cols, :y)
@test col_y == ["a", "b", "c"]

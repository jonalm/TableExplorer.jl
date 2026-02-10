using Test
using TableExplorer

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

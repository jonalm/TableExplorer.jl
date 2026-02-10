using Test
using TableExplorer

palette = ["#ff0000", "#00ff00", "#0000ff"]

# Test basic generation
values = ["C", "A", "B"]
result = TableExplorer.generate_categorical_colors(values, palette)
@test result isa Dict{String, String}
@test length(result) == 3
@test haskey(result, "A")
@test haskey(result, "B")
@test haskey(result, "C")

# Test deterministic sorting - "A" comes first alphabetically
@test result["A"] == "#ff0000"
@test result["B"] == "#00ff00"
@test result["C"] == "#0000ff"

# Test with more values than colors (wrapping)
values = ["A", "B", "C", "D"]
result = TableExplorer.generate_categorical_colors(values, palette)
@test length(result) == 4
@test result["D"] == "#ff0000"  # Wraps to first color

# Test with default palette
values = ["X", "Y", "Z"]
result = TableExplorer.generate_categorical_colors(values)
@test length(result) == 3

# Test with missing values
values_missing = ["B", "A", missing]
result_missing = TableExplorer.generate_categorical_colors(values_missing, palette)
@test length(result_missing) == 3
@test haskey(result_missing, "A")
@test haskey(result_missing, "B")
@test haskey(result_missing, "missing")
# Missing should be sorted last
@test result_missing["A"] == "#ff0000"
@test result_missing["B"] == "#00ff00"
@test result_missing["missing"] == "#0000ff"

# Test with nothing values
values_nothing = ["B", "A", nothing]
result_nothing = TableExplorer.generate_categorical_colors(values_nothing, palette)
@test length(result_nothing) == 3
@test haskey(result_nothing, "A")
@test haskey(result_nothing, "B")
@test haskey(result_nothing, "nothing")
# Nothing should be sorted last
@test result_nothing["A"] == "#ff0000"
@test result_nothing["B"] == "#00ff00"
@test result_nothing["nothing"] == "#0000ff"

# Test with both missing and nothing
values_both = ["C", missing, "A", nothing, "B"]
result_both = TableExplorer.generate_categorical_colors(values_both, palette)
@test length(result_both) == 5
# Normal values sorted first
@test result_both["A"] == "#ff0000"
@test result_both["B"] == "#00ff00"
@test result_both["C"] == "#0000ff"
# Special values sorted last (and wrap around)
@test result_both["missing"] == "#ff0000"  # Wraps
@test result_both["nothing"] == "#00ff00"  # Wraps

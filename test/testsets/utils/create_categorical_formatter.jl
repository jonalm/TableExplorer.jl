using Test
using TableExplorer

color_map = Dict(
    "Pass" => "#28a745",
    "Fail" => "#dc3545"
)

result = TableExplorer.create_categorical_formatter(color_map)
@test result isa String
@test startswith(result, "function(cell)")
@test occursin("'Pass': '#28a745'", result)
@test occursin("'Fail': '#dc3545'", result)
@test occursin("backgroundColor", result)
@test occursin("brightness", result)
@test occursin("#f0f0f0", result)  # Default color

# Test empty color map
empty_map = Dict{String, String}()
result_empty = TableExplorer.create_categorical_formatter(empty_map)
@test occursin("colorMap = {\n\n  }", result_empty)

# Test with special characters in keys
color_map_special = Dict(
    "It's OK" => "#28a745",
    "Don't fail" => "#dc3545",
    "Line\nbreak" => "#ffc107"
)
result_special = TableExplorer.create_categorical_formatter(color_map_special)
@test occursin("It\\'s OK", result_special)
@test occursin("Don\\'t fail", result_special)
@test occursin("Line\\nbreak", result_special)

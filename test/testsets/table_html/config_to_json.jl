using Test
using TableExplorer

# Test basic config without functions
config = Dict("title" => "Test", "field" => "test_field")
result = TableExplorer.config_to_json(config)
@test occursin("\"title\"", result)
@test occursin("\"Test\"", result)
@test occursin("\"field\"", result)

# Test config with formatter function
config_with_func = Dict(
    "title" => "Value",
    "formatter" => "function(cell) { return cell.getValue(); }"
)
result = TableExplorer.config_to_json(config_with_func)
@test occursin("\"formatter\": function(cell)", result)
@test !occursin("\"function(cell)", result)  # Should not be double-quoted

# Test with titleFormatter
config_title_func = Dict(
    "title" => "Header",
    "titleFormatter" => "function(cell) { return 'Custom'; }"
)
result = TableExplorer.config_to_json(config_title_func)
@test occursin("\"titleFormatter\": function(cell)", result)

# Test with custom formatter ending with "Formatter"
config_custom_formatter = Dict(
    "title" => "Custom",
    "customFormatter" => "function(cell) { return 'test'; }"
)
result = TableExplorer.config_to_json(config_custom_formatter)
@test occursin("\"customFormatter\": function(cell)", result)
@test !occursin("\"function(cell)", result)

# Test with leading whitespace in function
config_whitespace = Dict(
    "formatter" => "  function(cell) { return cell.getValue(); }"
)
result = TableExplorer.config_to_json(config_whitespace)
@test occursin("\"formatter\":   function(cell)", result)

# Test that non-function strings are properly quoted
config_non_func = Dict(
    "formatter" => "not a function",
    "titleFormatter" => "also not a function"
)
result = TableExplorer.config_to_json(config_non_func)
@test occursin("\"not a function\"", result)
@test occursin("\"also not a function\"", result)

# Test with edge case: formatter key but not a string value
config_non_string = Dict(
    "formatter" => 123,
    "title" => "Test"
)
result = TableExplorer.config_to_json(config_non_string)
@test occursin("\"formatter\": 123", result)
@test occursin("\"title\": \"Test\"", result)

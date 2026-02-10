using Test
using TableExplorer

# Test valid JavaScript functions
@test TableExplorer.is_js_function("formatter", "function(cell) { return 1; }")
@test TableExplorer.is_js_function("titleFormatter", "function() { return 'test'; }")
@test TableExplorer.is_js_function("customFormatter", "function(x) { return x; }")
@test TableExplorer.is_js_function("myFormatter", "function() {}")

# Test with leading whitespace
@test TableExplorer.is_js_function("formatter", "  function() {}")
@test TableExplorer.is_js_function("formatter", "\tfunction() {}")

# Test invalid cases
@test !TableExplorer.is_js_function("formatter", "not a function")
@test !TableExplorer.is_js_function("formatter", "func() {}")  # doesn't start with "function"
@test !TableExplorer.is_js_function("title", "function() {}")  # wrong key
@test !TableExplorer.is_js_function("formatter", 123)  # not a string
@test !TableExplorer.is_js_function("myFormat", "function() {}")  # doesn't end with "Formatter"

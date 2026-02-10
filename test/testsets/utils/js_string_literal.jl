using Test
using TableExplorer

# Test basic string
@test TableExplorer.js_string_literal("hello") == "hello"

# Test single quotes
@test TableExplorer.js_string_literal("It's true") == "It\\'s true"

# Test backslashes
@test TableExplorer.js_string_literal("path\\to\\file") == "path\\\\to\\\\file"

# Test newlines
@test TableExplorer.js_string_literal("Line 1\nLine 2") == "Line 1\\nLine 2"

# Test carriage returns
@test TableExplorer.js_string_literal("Line 1\rLine 2") == "Line 1\\rLine 2"

# Test combined escaping
@test TableExplorer.js_string_literal("It's\na test\\file") == "It\\'s\\na test\\\\file"

# Test empty string
@test TableExplorer.js_string_literal("") == ""

# Test multiple quotes
@test TableExplorer.js_string_literal("'quoted' text") == "\\'quoted\\' text"

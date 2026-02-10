using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    id = [1, 2, 3],
    name = ["Alice", "Bob", "Charlie"],
    value = [100.5, 200.75, 300.25]
)

html = table_html(df)

# Test that HTML string is returned
@test html isa String
@test !isempty(html)

# Test that HTML contains expected structure
@test occursin("<html", html)
@test occursin("</html>", html)
@test occursin("<body", html)
@test occursin("</body>", html)

# Test that data is embedded
@test occursin("Alice", html)
@test occursin("Bob", html)
@test occursin("Charlie", html)

# Test that column names are present
@test occursin("id", html)
@test occursin("name", html)
@test occursin("value", html)

# Test that row and column counts are present (in HTML format: "Rows: X / Y")
@test occursin("Rows:", html)
@test occursin("Columns:", html)
@test occursin("/ 3", html)  # Total rows
@test occursin("</span> / 3 |", html)  # Row count format

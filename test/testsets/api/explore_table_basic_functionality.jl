using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    id = [1, 2, 3],
    name = ["Alice", "Bob", "Charlie"]
)

# Test that explore_table creates HTML file
mktempdir() do tmpdir
    # We can't easily test browser opening without side effects,
    # but we can verify the HTML generation works
    html = table_html(df)
    @test html isa String
    @test !isempty(html)
end

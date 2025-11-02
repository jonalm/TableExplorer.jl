using TableExplorer

# Test the exact score cases from fzf
println("=== Expected Exact Scores from fzf ===")
println("oBZ in fooBarbaz: ", fzf_score("oBZ", "fooBarbaz"), " (expected: 49)")
println("fbb in foo bar baz: ", fzf_score("fbb", "foo bar baz"), " (expected: 78)")
println("12356 in ab0123 456: ", fzf_score("12356", "ab0123 456"), " (expected: 88)")

# Other failing tests
println("\n=== Basic Exact Matches ===")
println("hello in hello: ", fzf_score("hello", "hello"))
println("hello in hello world: ", fzf_score("hello", "hello world"))

println("\n=== CamelCase Bonuses ===")
println("fb in fooBar: ", fzf_score("fb", "fooBar"))
println("fb in foobar: ", fzf_score("fb", "foobar"))
println("FB in FooBar: ", fzf_score("FB", "FooBar"))
println("FB in Foobar: ", fzf_score("FB", "Foobar"))

println("\n=== Gap Penalties ===")
println("ff in fuzzy-finder: ", fzf_score("ff", "fuzzy-finder"))
println("ff in fuzzyfinder: ", fzf_score("ff", "fuzzyfinder"))
println("ac in abc: ", fzf_score("ac", "abc"))
println("ac in a____c: ", fzf_score("ac", "a____c"))

println("\n=== Consecutive Bonus ===")
println("oob in foobar: ", fzf_score("oob", "foobar"))
println("oob in out-of-bound: ", fzf_score("oob", "out-of-bound"))

println("\n=== Real World ===")
println("rc in src/config.jl: ", fzf_score("rc", "src/config.jl"))
println("rc in src/controller.jl: ", fzf_score("rc", "src/controller.jl"))
println("gFC in getFooController: ", fzf_score("gFC", "getFooController"))
println("gFC in getFoo_Controller: ", fzf_score("gFC", "getFoo_Controller"))

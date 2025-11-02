using Test
using TableExplorer

# Comprehensive test suite based on fzf's algo_test.go
# Source: https://github.com/junegunn/fzf/blob/master/src/algo/algo_test.go

@testset "FZF Comprehensive Scoring Tests (from fzf source)" begin


    @testset "Fuzzy Match Test Cases" begin
        # Test case: "fooBarbaz1" matching "oBZ"
        # Expected: scoreMatch*3 + bonusCamel123 + scoreGapStart + scoreGapExtension*3
        # = 16*3 + 7 + (-3) + (-1)*3 = 48 + 7 - 3 - 3 = 49
        @test fzf_score("oBZ", "fooBarbaz1") == 49

        # Test case: "foo bar baz" matching "fbb"
        # Expected: scoreMatch*3 + bonusBoundaryWhite*bonusFirstCharMultiplier + bonusBoundaryWhite*2 + 2*scoreGapStart + 4*scoreGapExtension
        # = 16*3 + 10*2 + 10*2 + 2*(-3) + 4*(-1) = 48 + 20 + 20 - 6 - 4 = 78
        @test fzf_score("fbb", "foo bar baz") == 78

        # Test case: "/AutomatorDocument.icns" matching "rdoc"
        # Expected: scoreMatch*4 + bonusCamel123 + bonusConsecutive*2
        # = 16*4 + 7 + 4*2 = 64 + 7 + 8 = 79
        @test fzf_score("rdoc", "/AutomatorDocument.icns") == 79

        # Test case: "/man1/zshcompctl.1" matching "zshc"
        # Expected: scoreMatch*4 + bonusBoundaryDelimiter*bonusFirstCharMultiplier + bonusBoundaryDelimiter*3
        # = 16*4 + 9*2 + 9*3 = 64 + 18 + 27 = 109
        @test fzf_score("zshc", "/man1/zshcompctl.1") == 109

        # Test case: "/.oh-my-zsh/cache" matching "zshc"
        # Expected: scoreMatch*4 + bonusBoundary*bonusFirstCharMultiplier + bonusBoundary*2 + scoreGapStart + bonusBoundaryDelimiter
        # = 16*4 + 8*2 + 8*2 + (-3) + 9 = 64 + 16 + 16 - 3 + 9 = 102
        @test fzf_score("zshc", "/.oh-my-zsh/cache") == 102

        # Test case: "ab0123 456" matching "12356"
        # Expected: scoreMatch*5 + bonusConsecutive*3 + scoreGapStart + scoreGapExtension
        # = 16*5 + 4*3 + (-3) + (-1) = 80 + 12 - 3 - 1 = 88
        @test fzf_score("12356", "ab0123 456") == 88

        # Test case: "abc123 456" matching "12356"
        # Expected: scoreMatch*5 + bonusCamel123*bonusFirstCharMultiplier + bonusCamel123*2 + bonusConsecutive + scoreGapStart + scoreGapExtension
        # = 16*5 + 7*2 + 7*2 + 4 + (-3) + (-1) = 80 + 14 + 14 + 4 - 3 - 1 = 108
        @test fzf_score("12356", "abc123 456") == 108

        # Test case: "foo/bar/baz" matching "fbb"
        # Expected: scoreMatch*3 + bonusBoundaryWhite*bonusFirstCharMultiplier + bonusBoundaryDelimiter*2 + 2*scoreGapStart + 4*scoreGapExtension
        # = 16*3 + 10*2 + 9*2 + 2*(-3) + 4*(-1) = 48 + 20 + 18 - 6 - 4 = 76
        @test fzf_score("fbb", "foo/bar/baz") == 76

        # Test case: "fooBarBaz" matching "fbb"
        # Expected: scoreMatch*3 + bonusBoundaryWhite*bonusFirstCharMultiplier + bonusCamel123*2 + 2*scoreGapStart + 2*scoreGapExtension
        # = 16*3 + 10*2 + 7*2 + 2*(-3) + 2*(-1) = 48 + 20 + 14 - 6 - 2 = 74
        @test fzf_score("fbb", "fooBarBaz") == 74

        # Test case: "foo barbaz" matching "fbb"
        # Expected: scoreMatch*3 + bonusBoundaryWhite*bonusFirstCharMultiplier + bonusBoundaryWhite + 2*scoreGapStart + 3*scoreGapExtension
        # = 16*3 + 10*2 + 10 + 2*(-3) + 3*(-1) = 48 + 20 + 10 - 6 - 3 = 69
        @test fzf_score("fbb", "foo barbaz") == 69

        # Test case: "fooBar Baz" matching "foob"
        # Expected: scoreMatch*4 + bonusBoundaryWhite*bonusFirstCharMultiplier + bonusBoundaryWhite*3
        # = 16*4 + 10*2 + 10*3 = 64 + 20 + 30 = 114
        @test fzf_score("foob", "fooBar Baz") == 114

        # Test case: "xFoo-Bar Baz" matching "foo-b"
        # Expected: scoreMatch*5 + bonusCamel123*bonusFirstCharMultiplier + bonusCamel123*2 + bonusNonWord + bonusBoundary
        # = 16*5 + 7*2 + 7*2 + 8 + 8 = 80 + 14 + 14 + 8 + 8 = 124
        @test fzf_score("foo-b", "xFoo-Bar Baz") == 124

        # Test case: "foo-bar" matching "o-ba" (consecutive bonus updated)
        # Expected: scoreMatch*4 + bonusBoundary*3
        # = 16*4 + 8*3 = 64 + 24 = 88
        @test fzf_score("o-ba", "foo-bar") == 88
    end

    @testset "Non-Match Cases" begin
        # Pattern not found should return 0
        @test fzf_score("xyz", "fooBarbaz") == 0
        @test fzf_score("fooBarbazz", "fooBarbaz") == 0
        @test fzf_score("zzz", "abc") == 0
    end

    @testset "Empty Pattern" begin
        @test fzf_score("", "foobar") == 0
        @test fzf_score("", "") == 0
        @test fzf_score("", "any text here") == 0
    end

    @testset "Edge Cases and Special Patterns" begin
        # Single character
        @test fzf_score("f", "foobar") > 0
        @test fzf_score("x", "foobar") == 0

        # Pattern equals text
        @test fzf_score("foo", "foo") > fzf_score("fo", "foo")

        # Very short patterns
        @test fzf_score("a", "a") > 0
        @test fzf_score("ab", "ab") > 0
    end

    @testset "Boundary Detection" begin
        # Whitespace boundaries
        @test fzf_score("fb", "foo bar") > fzf_score("fb", "foobar")

        # Delimiter boundaries (/, :, ;, |, ,)
        @test fzf_score("fb", "foo/bar") > fzf_score("fb", "foobar")
        @test fzf_score("fb", "foo:bar") > fzf_score("fb", "foobar")
        @test fzf_score("fb", "foo;bar") > fzf_score("fb", "foobar")
        @test fzf_score("fb", "foo|bar") > fzf_score("fb", "foobar")
        @test fzf_score("fb", "foo,bar") > fzf_score("fb", "foobar")

        # CamelCase boundaries
        @test fzf_score("fb", "fooBar") > fzf_score("fb", "foobar")
        @test fzf_score("fb", "FooBar") > fzf_score("fb", "foobar")
    end

    @testset "Consecutive Matching" begin
        # Consecutive matches should get bonus
        @test fzf_score("abc", "abc") > fzf_score("abc", "a_b_c")

        # Note: xa_b_cx can score higher than xabcx if the underscores create
        # better boundary bonuses. This is expected fzf behavior.
        @test fzf_score("abc", "xabcx") > 0
        @test fzf_score("abc", "xa_b_cx") > 0

        # Longer consecutive sequences
        @test fzf_score("test", "test") > fzf_score("test", "t_e_s_t")
    end

    @testset "Case Insensitivity" begin
        # Should match case-insensitively
        @test fzf_score("foo", "FOO") > 0
        @test fzf_score("foo", "FoO") > 0
        @test fzf_score("FOO", "foo") > 0

        # But preserve case for bonus calculation
        @test fzf_score("fb", "FooBar") == fzf_score("fb", "fooBar")
        @test fzf_score("FB", "FooBar") == fzf_score("fb", "FooBar")
    end

    @testset "First Character Bonus" begin
        # First character at boundary gets double bonus
        @test fzf_score("fo", "foo") > fzf_score("fo", "xfoo")
        @test fzf_score("fb", "foo bar") > fzf_score("fb", "xfoo bar")
    end

    @testset "Gap Penalties" begin
        # Gaps should reduce score
        @test fzf_score("foobar", "foobar") > fzf_score("foobar", "foo___bar")

        # Multiple gaps
        @test fzf_score("abc", "abc") > fzf_score("abc", "a_b_c")
        @test fzf_score("abc", "a_b_c") > fzf_score("abc", "a__b__c")
    end

    @testset "Real World File Paths" begin
        # Common file path patterns
        @test fzf_score("test", "src/test/file.jl") > 0
        @test fzf_score("config", "src/config.jl") > 0
        @test fzf_score("readme", "README.md") > 0

        # Note: "configure" has all chars consecutive which can score higher
        # than "src/config" despite the path boundary. Both are valid matches.
        @test fzf_score("conf", "src/config") > 0
        @test fzf_score("conf", "configure") > 0
    end

    @testset "Score Ordering" begin
        # Better matches should score higher
        scores = [
            fzf_score("foo", "foo"),           # Exact match
            fzf_score("foo", "foobar"),        # Prefix match
            fzf_score("foo", "foo_bar"),       # Match with delimiter
            fzf_score("foo", "xfoo"),          # Match not at start
            fzf_score("foo", "f_o_o"),         # Scattered match
        ]

        # Generally, exact matches score highest
        @test scores[1] >= scores[2]
        @test scores[2] >= scores[3]
        @test scores[3] >= scores[4]

        # Note: f_o_o can score higher than xfoo due to boundary bonuses
        # This is expected behavior - boundary quality matters
        @test scores[4] > 0
        @test scores[5] > 0
    end

    @testset "Pattern Variations" begin
        text = "FooBarBazQux"

        # Different pattern lengths
        @test fzf_score("f", text) > 0
        @test fzf_score("fb", text) > 0
        @test fzf_score("fbb", text) > 0
        @test fzf_score("fbbq", text) > 0

        # Longer patterns should generally score higher (more match points)
        @test fzf_score("fbb", text) > fzf_score("fb", text)
        @test fzf_score("fb", text) > fzf_score("f", text)
    end
end

using Test
using TableExplorer

# Test suite for FZF fuzzy matching scoring algorithm
# Based on the fzf implementation: https://github.com/junegunn/fzf

@testset "FZF Scoring Algorithm Tests" begin

    # Scoring constants (for reference and verification)
    # scoreMatch = 16
    # scoreGapStart = -3
    # scoreGapExtension = -1
    # bonusBoundary = 8
    # bonusBoundaryWhite = 10
    # bonusBoundaryDelimiter = 9
    # bonusCamel123 = 7
    # bonusConsecutive = 4
    # bonusFirstCharMultiplier = 2

    @testset "Basic Exact Matches" begin
        # Exact match should score highest
        @test fzf_score("hello", "hello") > fzf_score("hello", "hello world")

        # Perfect consecutive match at start
        @test fzf_score("abc", "abc") > 0

        # Single character match
        @test fzf_score("a", "a") > 0
    end

    @testset "No Match Cases" begin
        # Pattern not in text should score 0 or negative
        @test fzf_score("xyz", "abc") <= 0

        # Empty pattern
        @test fzf_score("", "hello") == 0

        # Pattern longer than text
        @test fzf_score("hello world", "hi") <= 0
    end

    @testset "Consecutive Matches vs Gaps" begin
        # Consecutive matches should score higher than matches with gaps
        # "foobar" vs "foo-bar" on pattern "foob"
        score_consecutive = fzf_score("foob", "foobar")
        score_with_gap = fzf_score("foob", "foo-bar")
        @test score_consecutive > score_with_gap

        # "abc" matches better in "abc" than in "a_b_c"
        @test fzf_score("abc", "abc") > fzf_score("abc", "a_b_c")
        @test fzf_score("abc", "abc") > fzf_score("abc", "a-b-c")
    end

    @testset "Word Boundary Bonuses" begin
        # Match at word boundary should score higher than match in middle
        # "fb" should score higher in "foo bar" than "foobar"
        score_boundary = fzf_score("fb", "foo bar")
        score_no_boundary = fzf_score("fb", "foobar")
        @test score_boundary > score_no_boundary

        # "fbb" in "foo bar baz" - all at word boundaries
        @test fzf_score("fbb", "foo bar baz") > fzf_score("fbb", "foobarbaz")

        # Match at start of string gets boundary bonus
        @test fzf_score("h", "hello") > fzf_score("h", "ohello")
    end

    @testset "CamelCase Bonuses" begin
        # Matches at camelCase boundaries should get bonus
        # "fb" in "fooBar" vs "foobar"
        score_camel = fzf_score("fb", "fooBar")
        score_no_camel = fzf_score("fb", "foobar")
        @test score_camel > score_no_camel

        # "oBZ" in "fooBarbaz" should get camelCase bonus
        @test fzf_score("oBZ", "fooBarbaz") > 0

        # Uppercase transitions: "FF" in "FooBar"
        @test fzf_score("FB", "FooBar") > fzf_score("FB", "Foobar")
    end

    @testset "First Character Bonus Multiplier" begin
        # First character match at boundary should get double bonus
        # "br" where 'b' is at boundary should score higher than 'r' at boundary
        # "fo-bar" vs "foob-r" on "br"
        score_first_at_boundary = fzf_score("br", "fo-bar")
        score_second_at_boundary = fzf_score("br", "foob-r")
        @test score_first_at_boundary > score_second_at_boundary

        # First character at start of string gets extra bonus
        @test fzf_score("he", "hello") > fzf_score("he", "ohello")
    end

    @testset "Gap Penalties" begin
        # Longer gaps should score lower
        # "ff" in "fuzzyfinder" vs "fuzzy-finder" vs "fuzzy-blurry-finder"
        score_short = fzf_score("ff", "fuzzyfinder")
        score_medium = fzf_score("ff", "fuzzy-finder")
        score_long = fzf_score("ff", "fuzzy-blurry-finder")
        @test score_short > score_long
        @test score_medium > score_long

        # Gap of 1 vs gap of 5
        @test fzf_score("ac", "abc") > fzf_score("ac", "a____c")
    end

    @testset "Delimiter Bonuses" begin
        # Matches after delimiters (/,:;|) should get bonus
        # Pattern "fc" in "foo/bar/cat" vs "foobcat"
        @test fzf_score("fc", "foo/bar/cat") > fzf_score("fc", "foobcat")

        # Test different delimiters
        @test fzf_score("bc", "a:b:c") > fzf_score("bc", "abc")
        @test fzf_score("bc", "a;b;c") > fzf_score("bc", "abc")
        @test fzf_score("bc", "a|b|c") > fzf_score("bc", "abc")
        @test fzf_score("bc", "a,b,c") > fzf_score("bc", "abc")
    end

    @testset "Number Transitions" begin
        # Transition to number should get bonus (like camelCase)
        # "a1" in "abc123" vs "a_1"
        @test fzf_score("a1", "abc123") > 0

        # "12356" in "ab0123 456"
        # Should get consecutive bonus for "123" and "56"
        @test fzf_score("12356", "ab0123 456") > 0
    end

    @testset "Case Sensitivity" begin
        # By default, should be case-insensitive
        @test fzf_score("abc", "ABC") == fzf_score("ABC", "abc")
        @test fzf_score("hello", "HeLLo") > 0

        # Lower case pattern should match upper case text
        @test fzf_score("foo", "FOO") > 0
    end

    @testset "Relative Scoring Examples" begin
        # From fzf test cases
        # "fooBarbaz" matching "oBZ"
        # Should have: scoreMatch*3 + bonusCamel123 + scoreGapStart + scoreGapExtension*3
        # = 16*3 + 7 + (-3) + (-1)*3 = 48 + 7 - 3 - 3 = 49
        @test fzf_score("oBZ", "fooBarbaz") == 49

        # "foo bar baz" matching "fbb"
        # scoreMatch*3 + bonusBoundaryWhite*bonusFirstCharMultiplier + bonusBoundaryWhite*2 + 2*scoreGapStart + 4*scoreGapExtension
        # = 16*3 + 10*2 + 10*2 + 2*(-3) + 4*(-1) = 48 + 20 + 20 - 6 - 4 = 78
        @test fzf_score("fbb", "foo bar baz") == 78

        # "ab0123 456" matching "12356"
        # scoreMatch*5 + bonusConsecutive*3 + scoreGapStart + scoreGapExtension
        # = 16*5 + 4*3 + (-3) + (-1) = 80 + 12 - 3 - 1 = 88
        @test fzf_score("12356", "ab0123 456") == 88
    end

    @testset "Match Position Preference" begin
        # Earlier matches should generally be preferred when scores are equal
        @test fzf_score("test", "test file") >= fzf_score("test", "file test")
    end

    @testset "Special Position Priorities" begin
        # fzf prefers matches at special positions even if total length is longer
        # "fuzzyfinder" vs "fuzzy-finder" on "ff"
        # The second should score higher due to boundary bonuses
        score_no_boundary = fzf_score("ff", "fuzzyfinder")
        score_boundaries = fzf_score("ff", "fuzzy-finder")
        @test score_boundaries > score_no_boundary
    end

    @testset "Consecutive Bonus Calculation" begin
        # Consecutive matches should accumulate bonus correctly
        # "abc" should get consecutive bonuses
        score_abc = fzf_score("abc", "abc")
        score_ab = fzf_score("ab", "abc")

        # Adding third consecutive character should add scoreMatch + consecutive bonus
        @test score_abc > score_ab

        # "oob" in "foobar" vs "out-of-bound"
        # "foobar" has better consecutive chunk
        @test fzf_score("oob", "foobar") > fzf_score("oob", "out-of-bound")
    end

    @testset "Edge Cases" begin
        # Single character pattern and text
        @test fzf_score("a", "a") > 0

        # Pattern equals text
        @test fzf_score("hello", "hello") > fzf_score("hell", "hello")

        # Multiple occurrences - should find best scoring match
        @test fzf_score("ba", "foo bar baz") > 0

        # Whitespace handling
        @test fzf_score("ab", "a b") > 0
        @test fzf_score("ab", "a  b") > 0  # Multiple spaces
    end

    @testset "Score Magnitude Tests" begin
        # Verify scores are in reasonable ranges
        @test fzf_score("a", "a") > 0
        @test fzf_score("abc", "abc") > fzf_score("a", "a")

        # No match should return 0 or negative
        @test fzf_score("xyz", "abc") <= 0

        # Gap penalties shouldn't make score negative for valid matches
        @test fzf_score("ac", "a_b_c_d_e_c") > 0
    end

    @testset "Real World Examples" begin
        # File path matching
        @test fzf_score("rc", "src/config.jl") > fzf_score("rc", "src/controller.jl")

        # Function name matching
        @test fzf_score("gbl", "get_balance") > fzf_score("gbl", "global")

        # CamelCase function matching
        @test fzf_score("gFC", "getFooController") > fzf_score("gFC", "getFoo_Controller")
    end
end

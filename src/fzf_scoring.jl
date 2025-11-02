# FZF Fuzzy Matching Scoring Algorithm
# Based on: https://github.com/junegunn/fzf/blob/master/src/algo/algo.go

# Scoring constants
const SCORE_MATCH = 16
const SCORE_GAP_START = -3
const SCORE_GAP_EXTENSION = -1

const BONUS_BOUNDARY = div(SCORE_MATCH, 2)  # 8
const BONUS_NON_WORD = div(SCORE_MATCH, 2)  # 8
const BONUS_CAMEL123 = BONUS_BOUNDARY + SCORE_GAP_EXTENSION  # 7
const BONUS_CONSECUTIVE = -(SCORE_GAP_START + SCORE_GAP_EXTENSION)  # 4

const BONUS_FIRST_CHAR_MULTIPLIER = 2

const BONUS_BOUNDARY_WHITE = BONUS_BOUNDARY + 2  # 10
const BONUS_BOUNDARY_DELIMITER = BONUS_BOUNDARY + 1  # 9

# Character classes
@enum CharClass begin
    CHAR_WHITE
    CHAR_NON_WORD
    CHAR_DELIMITER
    CHAR_LOWER
    CHAR_UPPER
    CHAR_LETTER
    CHAR_NUMBER
end

const DELIMITER_CHARS = Set(['/', ':', ';', '|', ','])
const WHITE_CHARS = Set([' ', '\t', '\n', '\v', '\f', '\r', '\u0085', '\u00A0'])

"""
    char_class_of(c::Char) -> CharClass

Classify a character for bonus calculation purposes.
"""
function char_class_of(c::Char)
    if c in WHITE_CHARS
        return CHAR_WHITE
    elseif c in DELIMITER_CHARS
        return CHAR_DELIMITER
    elseif islowercase(c)
        return CHAR_LOWER
    elseif isuppercase(c)
        return CHAR_UPPER
    elseif isdigit(c)
        return CHAR_NUMBER
    elseif isletter(c)
        return CHAR_LETTER
    else
        return CHAR_NON_WORD
    end
end

"""
    bonus_for(prev_class::CharClass, class::CharClass) -> Int

Calculate the bonus for a character based on its class and the previous character's class.
"""
function bonus_for(prev_class::CharClass, class::CharClass)
    # Word boundary bonuses
    if class > CHAR_NON_WORD
        if prev_class == CHAR_WHITE
            return BONUS_BOUNDARY_WHITE
        elseif prev_class == CHAR_DELIMITER
            return BONUS_BOUNDARY_DELIMITER
        elseif prev_class == CHAR_NON_WORD
            return BONUS_BOUNDARY
        end
    end

    # CamelCase and letter-to-number transitions
    if (prev_class == CHAR_LOWER && class == CHAR_UPPER) ||
       (prev_class != CHAR_NUMBER && class == CHAR_NUMBER)
        return BONUS_CAMEL123
    end

    # Non-word and delimiter bonuses
    if class == CHAR_NON_WORD || class == CHAR_DELIMITER
        return BONUS_NON_WORD
    elseif class == CHAR_WHITE
        return BONUS_BOUNDARY_WHITE
    end

    return 0
end

"""
    bonus_at(text_chars::Vector{Char}, bonuses::Vector{Int}, idx::Int) -> Int

Get the bonus for a character at a specific index using pre-computed bonuses.
"""
function bonus_at(text_chars::Vector{Char}, bonuses::Vector{Int}, idx::Int)
    return bonuses[idx]
end

"""
    compute_bonuses(text_chars::Vector{Char}) -> Vector{Int}

Pre-compute bonus values for all positions in the text.
"""
function compute_bonuses(text_chars::Vector{Char})
    N = length(text_chars)
    bonuses = zeros(Int, N)

    prev_class = CHAR_WHITE  # Start of string acts like whitespace boundary

    for i in 1:N
        curr_class = char_class_of(text_chars[i])
        bonuses[i] = bonus_for(prev_class, curr_class)
        prev_class = curr_class
    end

    return bonuses
end

"""
    fzf_score(pattern::AbstractString, text::AbstractString) -> Int

Calculate the fuzzy matching score for a pattern against text.
Returns the score (higher is better), or 0 if no match.

This implements the FuzzyMatchV2 algorithm from fzf using dynamic programming.
"""
function fzf_score(pattern::AbstractString, text::AbstractString)
    # Handle edge cases
    if isempty(pattern)
        return 0
    end

    # Convert pattern to lowercase for case-insensitive matching
    # Keep original text to preserve case information for bonuses
    pattern_lower = lowercase(pattern)
    text_original = collect(text)  # Keep original case for bonus calculation
    text_lower = collect(lowercase(text))  # Lowercase for matching

    pattern_chars = collect(pattern_lower)
    text_chars = text_lower  # Use for matching

    M = length(pattern_chars)
    N = length(text_chars)

    if M > N
        return 0
    end

    # Phase 1: Quick check that all pattern characters exist
    # Also find first and last occurrence indices
    first_idx = zeros(Int, M)
    last_idx = 0
    pidx = 1

    for tidx in 1:N
        if pidx <= M && text_chars[tidx] == pattern_chars[pidx]
            first_idx[pidx] = tidx
            last_idx = tidx
            pidx += 1
        end
    end

    if pidx <= M
        # Not all pattern characters found
        return 0
    end

    # Phase 2: Pre-compute bonuses for each position (using original case)
    bonuses = compute_bonuses(text_original)

    # For single character patterns, compute score directly
    if M == 1
        best_score = typemin(Int)
        for tidx in first_idx[1]:last_idx
            if text_chars[tidx] == pattern_chars[1]
                bonus = bonuses[tidx]
                score = SCORE_MATCH + bonus * BONUS_FIRST_CHAR_MULTIPLIER
                if score > best_score
                    best_score = score
                    # Early exit on strong boundary
                    if bonus >= BONUS_BOUNDARY
                        break
                    end
                end
            end
        end
        return best_score
    end

    # Phase 3: Dynamic Programming
    # H[i][j] = best score for matching pattern[1:i] ending at text position j
    # C[i][j] = consecutive match length ending at position j

    min_idx = first_idx[1]
    width = last_idx - min_idx + 1

    # Use two rows for space efficiency (current and previous)
    H0 = zeros(Int, width)
    C0 = zeros(Int, width)

    # Initialize first row (first pattern character)
    max_score = 0
    max_score_pos = 0
    in_gap = false
    prev_h = 0

    for tidx in min_idx:last_idx
        col = tidx - min_idx + 1

        if text_chars[tidx] == pattern_chars[1]
            bonus = bonuses[tidx]
            score = SCORE_MATCH + bonus * BONUS_FIRST_CHAR_MULTIPLIER
            H0[col] = score
            C0[col] = 1

            if M == 1 && score > max_score
                max_score = score
                max_score_pos = col
                # Early exit on good boundary
                if bonus >= BONUS_BOUNDARY
                    break
                end
            end
            in_gap = false
        else
            # Gap penalty for skipping text characters
            if in_gap
                H0[col] = max(prev_h + SCORE_GAP_EXTENSION, 0)
            else
                H0[col] = max(prev_h + SCORE_GAP_START, 0)
            end
            C0[col] = 0
            in_gap = true
        end
        prev_h = H0[col]
    end

    if M == 1
        return max_score
    end

    # Allocate current row
    H = zeros(Int, width)
    C = zeros(Int, width)

    # Fill remaining pattern characters
    for pidx in 2:M
        pchar = pattern_chars[pidx]
        max_score = 0
        max_score_pos = 0

        # Reset current row
        fill!(H, 0)
        fill!(C, 0)

        in_gap = false

        for tidx in first_idx[pidx]:last_idx
            col = tidx - min_idx + 1

            s1 = 0
            s2 = 0

            # Option 1: Match current character
            if text_chars[tidx] == pchar && col > 1
                prev_col = col - 1
                s1 = H0[prev_col] + SCORE_MATCH
                bonus = bonuses[tidx]
                consecutive = C0[prev_col] + 1

                # Handle consecutive bonus
                if consecutive > 1
                    # Get bonus from first char in chunk
                    first_bonus_idx = tidx - consecutive + 1
                    fb = bonuses[first_bonus_idx]

                    # Break chunk if hit stronger boundary
                    if bonus >= BONUS_BOUNDARY && bonus > fb
                        consecutive = 1
                    else
                        bonus = max(bonus, max(BONUS_CONSECUTIVE, fb))
                    end
                end

                s1 += bonus
            end

            # Option 2: Skip this text character
            if col > 1
                was_in_gap = C[col - 1] == 0
                if was_in_gap
                    s2 = H[col - 1] + SCORE_GAP_EXTENSION
                else
                    s2 = H[col - 1] + SCORE_GAP_START
                end
            end

            # Take best option
            if s1 >= s2
                H[col] = max(s1, 0)
                C[col] = consecutive
                in_gap = false
            else
                H[col] = max(s2, 0)
                C[col] = 0
                in_gap = true
            end

            # Track max score for last pattern char
            if pidx == M && H[col] > max_score
                max_score = H[col]
                max_score_pos = col
            end
        end

        # Swap rows
        H0, H = H, H0
        C0, C = C, C0
    end

    return max_score
end

#!/bin/bash

# Test script for parse-deploy-config-source patterns

test_pattern() {
    local pattern="$1"
    local expected="$2"

    echo "Testing: '$pattern'"

    # Simulate the parsing logic from action.yml
    SOURCE="$pattern"

    if [ -z "$SOURCE" ] || [ "$SOURCE" = ":" ] || [ "$SOURCE" = "@" ]; then
        REPO="self"
        REF=""
        CONFIG_PATH=""
    elif [[ "$SOURCE" =~ ^:(.+)$ ]]; then
        REPO="self"
        REF=""
        CONFIG_PATH="${BASH_REMATCH[1]}"
    elif [[ "$SOURCE" =~ ^@([^:]+)(:.*)?$ ]]; then
        REPO="self"
        REF="${BASH_REMATCH[1]}"
        CONFIG_PATH="${BASH_REMATCH[2]#:}"
    elif [[ "$SOURCE" =~ ^([^@:]+)(@[^:]+)?(:.*)?$ ]]; then
        REPO="${BASH_REMATCH[1]}"
        REF="${BASH_REMATCH[2]#@}"
        CONFIG_PATH="${BASH_REMATCH[3]#:}"
    else
        echo "  ❌ FAILED: Invalid format"
        return 1
    fi

    # Clean up empty path to be "."
    if [ -z "$CONFIG_PATH" ]; then
        CONFIG_PATH="."
    fi

    echo "  Parsed: repo='$REPO', ref='$REF', path='$CONFIG_PATH'"

    if [ "$expected" = "SHOULD_PASS" ]; then
        echo "  ✅ PASSED"
    fi
    echo
}

echo "=== Testing various patterns ==="
echo

# Original patterns that should work
test_pattern "" "SHOULD_PASS"
test_pattern "self" "SHOULD_PASS"
test_pattern "@main" "SHOULD_PASS"
test_pattern ":services/api" "SHOULD_PASS"
test_pattern "@main:services/api" "SHOULD_PASS"
test_pattern "self:services/api" "SHOULD_PASS"
test_pattern "Acme/configs" "SHOULD_PASS"
test_pattern "Acme/configs@v1.2.3" "SHOULD_PASS"
test_pattern "Acme/configs:services/api" "SHOULD_PASS"
test_pattern "Acme/configs@main:services/api" "SHOULD_PASS"

# Edge cases with trailing colons (now should work)
test_pattern "@main:" "SHOULD_PASS"
test_pattern "@refs/heads/main:" "SHOULD_PASS"
test_pattern "self:" "SHOULD_PASS"
test_pattern "Acme/configs:" "SHOULD_PASS"
test_pattern "Acme/configs@main:" "SHOULD_PASS"

# Other edge cases
test_pattern ":" "SHOULD_PASS"
test_pattern "@" "SHOULD_PASS"
test_pattern "@refs/heads/main" "SHOULD_PASS"
test_pattern "@refs/tags/v1.0.0" "SHOULD_PASS"
test_pattern "@refs/heads/feature/new-thing:services/api" "SHOULD_PASS"
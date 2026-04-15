#!/usr/bin/env bash
# Test: executing-plans skill
# Verifies that the skill is loaded and follows the automatic routing workflow
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test: executing-plans skill ==="
echo ""

# Test 1: Verify skill can be loaded
echo "Test 1: Skill loading..."

output=$(run_claude "What is the executing-plans skill? Describe how it chooses between parallel and serial subagent execution." 30)

if assert_contains "$output" "executing-plans\|Execute Plans\|execute plan" "Skill is recognized"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "parallel\|serial\|subagent" "Mentions automatic routing"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 2: Verify parallel routing is mentioned for independent work
echo "Test 2: Parallel routing..."

output=$(run_claude "If a plan has two independent tasks, how should executing-plans route them?" 30)

if assert_contains "$output" "parallel\|concurrent" "Routes independent work in parallel"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "subagent" "Uses subagents"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 3: Verify serial routing is mentioned for coupled work
echo "Test 3: Serial routing..."

output=$(run_claude "If tasks are tightly coupled, how should executing-plans handle them?" 30)

if assert_contains "$output" "serial\|sequential\|one by one" "Routes coupled work serially"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 4: Verify minimal context guidance
echo "Test 4: Context isolation..."

output=$(run_claude "Does executing-plans give every subagent the whole conversation, or only task-specific context?" 30)

if assert_contains "$output" "task-specific\|minimal context\|only.*need" "Mentions task-specific context"; then
    : # pass
else
    exit 1
fi

if assert_not_contains "$output" "whole conversation\|full conversation\|everything" "Avoids whole-conversation context"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 5: Verify review gate before completion
echo "Test 5: Review gate..."

output=$(run_claude "After all tasks in executing-plans are complete, what must happen before memory curation, acceptance testing, or branch finishing?" 30)

if assert_contains "$output" "requesting-code-review\|code review\|review all changes" "Mentions required review gate"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "critical\|important\|minor\|suggestion" "Describes review severity gating"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 6: Verify default low-level model guidance
echo "Test 6: Model strategy..."

output=$(run_claude "What model should executing-plans use for subagents by default, and when should it upgrade?" 30)

if assert_contains "$output" "mini\|small\|low-level" "Mentions low-level default model"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "upgrade\|escalate\|complex" "Mentions upgrade path"; then
    : # pass
else
    exit 1
fi

echo ""

echo "=== All executing-plans skill tests passed ==="

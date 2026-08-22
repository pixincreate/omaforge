#!/bin/bash
section "libexec split: workers in libexec, bin holds only rig"

for platform in fedora macos; do
  bin_dir="$RIG_REPO/unix/$platform/bin"
  libexec_dir="$RIG_REPO/unix/$platform/libexec"

  # bin/ contains only the rig dispatcher
  for f in "$bin_dir"/*; do
    [[ -f "$f" ]] || continue
    assert_success "$platform bin/$(basename "$f") is the rig dispatcher" \
      test "$(basename "$f")" = "rig"
  done

  # no rig-* workers left in bin/
  assert_failure "$platform bin/ has no rig-* workers" \
    ls "$bin_dir"/rig-* 2>/dev/null

  # libexec/ holds rig-* workers
  assert_success "$platform libexec/ has rig-* workers" \
    ls "$libexec_dir"/rig-* >/dev/null 2>&1

  # dispatcher resolves libexec
  assert_success "$platform dispatcher resolves libexec" \
    grep -q 'libexec' "$bin_dir/rig"
done

# common libexec holds shared workers
assert_success "common libexec/ has rig-* workers" \
  ls "$RIG_REPO"/unix/common/libexec/rig-* >/dev/null 2>&1

section "rig-ocr / rig-llama metadata on both platforms"

for platform in fedora macos; do
  for cmd in rig-ocr rig-llama; do
    script="$RIG_REPO/unix/$platform/libexec/$cmd"
    assert_success "$platform $cmd has summary" grep -q 'rig:summary=' "$script"
    assert_success "$platform $cmd has usage" grep -q 'rig:usage=' "$script"
  done
done

section "rig-llama defaults come from config.json"

for platform in fedora macos; do
  assert_success "$platform config.json sets .llama.model" \
    jq -e '.llama.model | length > 0' "$RIG_REPO/unix/$platform/config.json"
  assert_success "$platform config.json sets .llama.port" \
    jq -e '.llama.port | length > 0' "$RIG_REPO/unix/$platform/config.json"
  assert_success "$platform rig-llama reads config.json" \
    grep -q 'config.json' "$RIG_REPO/unix/$platform/libexec/rig-llama"
done

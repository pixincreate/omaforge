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

section "rig-ocr metadata on both platforms"

for platform in fedora macos; do
  script="$RIG_REPO/unix/$platform/libexec/rig-ocr"
  assert_success "$platform rig-ocr has summary" grep -q 'rig:summary=' "$script"
  assert_success "$platform rig-ocr has usage" grep -q 'rig:usage=' "$script"
done

section "rig-llama lives in common libexec with metadata"

assert_success "common rig-llama exists" \
  test -x "$RIG_REPO/unix/common/libexec/rig-llama"
assert_success "common rig-llama has summary" \
  grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-llama"
assert_success "common rig-llama has usage" \
  grep -q 'rig:usage=' "$RIG_REPO/unix/common/libexec/rig-llama"
assert_failure "no platform copies of rig-llama remain" \
  ls "$RIG_REPO/unix/fedora/libexec/rig-llama" "$RIG_REPO/unix/macos/libexec/rig-llama" 2>/dev/null

section "rig-llama defaults come from config.json"

for platform in fedora macos; do
  assert_success "$platform config.json sets .llama.model" \
    jq -e '.llama.model | length > 0' "$RIG_REPO/unix/$platform/config.json"
  assert_success "$platform config.json sets .llama.port" \
    jq -e '.llama.port | length > 0' "$RIG_REPO/unix/$platform/config.json"
done
assert_success "common rig-llama reads platform config.json" \
  grep -q 'unix/\$RIG_PLATFORM/config.json' "$RIG_REPO/unix/common/libexec/rig-llama"

section "rig-llama forwards flags regardless of position"

stub_dir=$(mktemp -d)
printf '#!/bin/bash\nprintf "%%s\\n" "$@"\n' > "$stub_dir/llama-cli"
chmod +x "$stub_dir/llama-cli"

PATH="$stub_dir:$PATH" LLAMA_MODELS_DIR="$stub_dir/models" \
  "$RIG_REPO/unix/common/libexec/rig-llama" chat --interactive ggml-org/test-model:Q4_0 > "$stub_dir/flag-first.out"
PATH="$stub_dir:$PATH" LLAMA_MODELS_DIR="$stub_dir/models" \
  "$RIG_REPO/unix/common/libexec/rig-llama" chat ggml-org/test-model:Q4_0 --interactive > "$stub_dir/flag-last.out"

assert_success "leading flag does not swallow model" \
  grep -q 'ggml-org/test-model:Q4_0' "$stub_dir/flag-first.out"
assert_success "-hf used with leading flag" \
  grep -q -e '-hf' "$stub_dir/flag-first.out"
assert_success "--interactive forwarded (leading flag)" \
  grep -q -- '--interactive' "$stub_dir/flag-first.out"
assert_success "--interactive forwarded (trailing flag)" \
  grep -q -- '--interactive' "$stub_dir/flag-last.out"
assert_success "model resolved when given first" \
  grep -q 'ggml-org/test-model:Q4_0' "$stub_dir/flag-last.out"

rm -rf "$stub_dir"

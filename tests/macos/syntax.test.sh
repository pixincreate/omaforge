#!/bin/bash
section "macOS setup script"
assert_bash_syntax "macos-setup" "$RIG_REPO/unix/macos/macos-setup"
assert_success "config.json is valid JSON" bash -c "jq empty '$RIG_REPO/unix/macos/config.json'"

section "macOS install scripts"
for dir in preflight packaging config dotfiles external post-install; do
    dir_path="$RIG_REPO/unix/macos/install/$dir"
    [[ -d "$dir_path" ]] || continue
    while IFS= read -r -d '' f; do
        assert_bash_syntax "$dir/$(basename "$f")" "$f"
    done < <(find "$dir_path" -name '*.sh' -print0)
done

section "macOS helpers"
assert_bash_syntax "helpers/all.sh" "$RIG_REPO/unix/macos/install/helpers/all.sh"
assert_bash_syntax "helpers/common.sh" "$RIG_REPO/unix/macos/install/helpers/common.sh"
assert_bash_syntax "helpers/logging.sh" "$RIG_REPO/unix/macos/install/helpers/logging.sh"

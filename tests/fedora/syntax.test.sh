section "Fedora setup script"
assert_bash_syntax "fedora-setup" "$RIG_REPO/unix/fedora/fedora-setup"
assert_success "config.json is valid JSON" bash -c "jq empty '$RIG_REPO/unix/fedora/config.json'"

section "Fedora install scripts"
for dir in preflight repositories packaging config dotfiles external post-install; do
    dir_path="$RIG_REPO/unix/fedora/install/$dir"
    [[ -d "$dir_path" ]] || continue
    while IFS= read -r -d '' f; do
        assert_bash_syntax "$dir/$(basename "$f")" "$f"
    done < <(find "$dir_path" -name '*.sh' -print0)
done

section "Fedora helpers"
assert_bash_syntax "helpers/all.sh" "$RIG_REPO/unix/fedora/install/helpers/all.sh"
assert_bash_syntax "helpers/common.sh" "$RIG_REPO/unix/fedora/install/helpers/common.sh"
assert_bash_syntax "helpers/logging.sh" "$RIG_REPO/unix/fedora/install/helpers/logging.sh"
assert_bash_syntax "helpers/presentation.sh" "$RIG_REPO/unix/fedora/install/helpers/presentation.sh"

section "Fedora health check"
assert_bash_syntax "health-check.sh" "$RIG_REPO/unix/fedora/health-check.sh"

section "Fedora migration scripts"
for f in "$RIG_REPO/unix/fedora/migrations/"*.sh; do
    [[ -f "$f" ]] && assert_bash_syntax "migrations/$(basename "$f")" "$f"
done

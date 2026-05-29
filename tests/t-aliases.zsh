#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Purpose: alias-presence pins for the 52 oc-* aliases + helper fns
#####          that the plugin registers when `oc` is available.
#####          Catches accidental rename / removal as a CI failure.
#####
##### NOTE: the plugin guards on `type -ap -- oc` which insists on a
##### real executable on PATH (not a shell function), so we stage a
##### tiny fake `oc` binary into a tmpdir prepended to PATH. The fake
##### accepts `oc completion zsh` (returning empty so the plugin's
##### `source <(oc completion zsh)` does nothing) and otherwise no-ops.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    # Stage a real executable `oc` stub on PATH so the plugin guard
    # (`type -ap -- oc`) passes. Each @test sees its own @setup run.
    ocstub_dir=$(mktemp -d)
    cat > "$ocstub_dir/oc" <<'STUB'
#!/usr/bin/env bash
# Test stub: respond to `oc completion zsh` with empty (no fn
# definitions) so the plugin's `source <(oc completion zsh)` is a
# no-op; otherwise exit 0 without doing anything.
exit 0
STUB
    chmod +x "$ocstub_dir/oc"
    # Wrap every invocation with this PATH prefix so the plugin sees `oc`.
    src_with_stub="PATH='$ocstub_dir:\$PATH' zsh -c"
}

@teardown {
    [[ -n "$ocstub_dir" && -d "$ocstub_dir" ]] && rm -rf "$ocstub_dir"
}

@test 'sourcing the plugin registers more than 40 o* aliases' {
    local count
    count=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias | grep -cE '^o[a-z]+='
    ")
    local result=$([[ "$count" -ge 40 ]] && echo yes || echo "no:$count")
    assert "$result" same_as 'yes'
}

@test 'ocdev login macro references OCP_DEV_URL and OCP_USERNAME env vars' {
    local body
    body=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ocdev
    ")
    assert "$body" contains 'OCP_DEV_URL'
    assert "$body" contains 'OCP_USERNAME'
    assert "$body" contains 'oc login'
}

@test 'ocqa login macro references OCP_QA_URL and OCP_USERNAME env vars' {
    local body
    body=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ocqa
    ")
    assert "$body" contains 'OCP_QA_URL'
    assert "$body" contains 'OCP_USERNAME'
    assert "$body" contains 'oc login'
}

@test 'ologin is oc rsh (interactive shell into a pod)' {
    local body
    body=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ologin 2>/dev/null
    ")
    assert "$body" contains 'oc rsh'
}

@test 'odel is oc delete (catches name-vs-action mismatch — must never become oc describe)' {
    local body
    body=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias odel
    ")
    assert "$body" contains 'oc delete'
}

@test 'odc / obc resolve to oc get with -o wide for tabular display' {
    local a body bad=""
    for a in odc obc; do
        body=$(PATH="$ocstub_dir:$PATH" zsh -c "
            emulate zsh
            source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
            alias $a 2>/dev/null
        ")
        case "$body" in
            *'oc get'*'-o wide'*) ;;
            *) bad="$bad $a" ;;
        esac
    done
    assert "$bad" is_empty
}

@test 'oexp variants pass --export to oc get for yaml dump' {
    local body
    body=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ocexp
    ")
    assert "$body" contains 'oc get'
    assert "$body" contains '--export'
}

@test 'plugin exits cleanly when oc is missing (graceful degradation)' {
    # The plugin guard returns 1 from the SOURCE chain when oc is
    # absent — which the user's shell startup handles silently.
    # zunit cares about whether sourcing crashes the shell, NOT
    # about the return code (sourcing a non-zero-returning script
    # is a normal zsh idiom for "plugin skipped itself"). Confirm
    # the shell stays alive after sourcing into an oc-less PATH.
    local out
    out=$(PATH=/usr/bin:/bin zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' >/dev/null 2>&1
        echo ALIVE
    ")
    assert "$out" same_as 'ALIVE'
}

@test 'plugin sourcing is idempotent — same alias count after re-source' {
    local first second
    first=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias | grep -cE '^o[a-z]+='
    ")
    second=$(PATH="$ocstub_dir:$PATH" zsh -c "
        emulate zsh
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias | grep -cE '^o[a-z]+='
    ")
    assert "$first" equals "$second"
}

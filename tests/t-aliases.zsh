#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Purpose: alias-presence pins for the 52 oc-* aliases + helper fns
#####          that the plugin registers when `oc` is available.
#####          Catches accidental rename / removal as a CI failure.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    # The plugin no-ops when `oc` isn't on PATH. Fake it for tests so
    # the alias batch always loads.
    fake_oc='function oc { true }'
}

@test 'sourcing the plugin registers more than 40 o* aliases' {
    local count
    count=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias | grep -cE '^o[a-z]+='
    ")
    local result=$([[ "$count" -ge 40 ]] && echo yes || echo "no:$count")
    assert "$result" same_as 'yes'
}

@test 'ocdev login macro references OCP_DEV_URL and OCP_USERNAME env vars' {
    local body
    body=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ocdev
    ")
    assert "$body" contains 'OCP_DEV_URL'
    assert "$body" contains 'OCP_USERNAME'
    assert "$body" contains 'oc login'
}

@test 'ocqa login macro references OCP_QA_URL and OCP_USERNAME env vars' {
    local body
    body=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ocqa
    ")
    assert "$body" contains 'OCP_QA_URL'
    assert "$body" contains 'OCP_USERNAME'
    assert "$body" contains 'oc login'
}

@test 'ologin is oc rsh (interactive shell into a pod)' {
    local body
    body=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ologin 2>/dev/null
    ")
    assert "$body" contains 'oc rsh'
}

@test 'odel is oc delete (catches name-vs-action mismatch — must never become oc describe)' {
    local body
    body=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias odel
    ")
    assert "$body" contains 'oc delete'
}

@test 'odc / obc / odp resolve to oc get with -o wide for tabular display' {
    for a in odc obc; do
        local body
        body=$(zsh -c "
            emulate zsh
            $fake_oc
            source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
            alias $a 2>/dev/null
        ")
        assert "$body" contains 'oc get'
        assert "$body" contains '-o wide'
    done
}

@test 'oexp variants pass --export to oc get for yaml dump' {
    local body
    body=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias ocexp
    ")
    assert "$body" contains 'oc get'
    assert "$body" contains '--export'
}

@test 'plugin sources cleanly even when oc is missing (graceful degradation)' {
    # The aliases reference `oc` lazily inside the alias body, so the
    # plugin must SOURCE without error even on hosts where oc isn't
    # installed — the alias bodies just fail at invocation time.
    local exit
    exit=$(zsh -c "
        emulate zsh
        # NO fake_oc.
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' >/dev/null 2>&1
        echo \$?
    ")
    assert "$exit" equals '0'
}

@test 'plugin sourcing is idempotent — same alias count after re-source' {
    local first second
    first=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias | grep -cE '^o[a-z]+='
    ")
    second=$(zsh -c "
        emulate zsh
        $fake_oc
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        source '$pluginDir/zsh-openshift-aliases.plugin.zsh' 2>/dev/null
        alias | grep -cE '^o[a-z]+='
    ")
    assert "$first" equals "$second"
}

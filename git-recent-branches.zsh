function __git_recent_branches()
{
    local reflog
    local -a branches branches_without_current unique_branches
    reflog=$(git reflog --pretty='%gs' | grep -E "checkout: moving from [^[:space:]]+" | awk '{ print $4 }')
    branches=(${(f)reflog})
    branches_without_current=("${(@)branches:#$current_branch}")
    unique_branches=(${(u)branches_without_current})
    print -l $unique_branches
}

_git-rb() {
    local -a branches descriptions
    local branch description
    local -i current
    integer branch_limit

    zstyle -s ":completion:${curcontext}:recent-branches" 'limit' branch_limit || branch_limit=10
    current=0
    for branch in $(__git_recent_branches)
    do
        description=$(git log -1 --pretty=%s ${branch} -- 2>/dev/null)
        if [[ -n "$description" ]]; then
          branches+=$branch
          descriptions+="${branch}:${description/:/\:/}"
          (( current++ ))
          if [[ $current == $branch_limit ]]; then
            break
          fi
        fi
    done

    _describe "recent branches" descriptions -V branches
}
compdef _git-rb git-rb

# If you define an alias in ~/.gitconfig for    rb = checkout  then you can test
# using  git rb BRANCH<enter> and it should checkout the appropriate branch

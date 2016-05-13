function __git_recent_branches()
{
  local branch
  local -A branches
  integer n branch_limit

  branch_limit=1000

  n=1
  while true;
  do

    if branch="$(git rev-parse --abbrev-ref @{-$n} 2>/dev/null)"
    then
      if [[ -n "$branch" ]]
      then
        branches[$branch]=$branch
      fi
    else
      break
    fi

    if (( $#branches == $branch_limit ));
    then
      break
    fi

    (( n++ ))
  done

  reply=(${(v)branches})
}

_git-rb()
{
  local -a descriptions
  local branch

  local reply
  __git_recent_branches

  for branch in $reply;
  do
    descriptions+="${branch}:$(git log -1 --pretty=%s $branch --)"
  done

  _describe -V "recent branches" descriptions
}
compdef _git-rb git-rb

# If you define an alias in ~/.gitconfig for    rb = checkout  then you can test
# using  git rb BRANCH<enter> and it should checkout the appropriate branch

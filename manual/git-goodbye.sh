#!/bin/sh

set -e

panic() {
  >&2 echo "$1"
  exit 2
}

while [[ $# -gt 0 ]]; do
  arg="$1"
  shift

  case $arg in
    --branch)
      CREATE_BRANCH=true
      ;;
    --push)
      PUSH=true
      ;;
    --ALL)
      CREATE_BRANCH=true
      PUSH=true
      ;;
    *)
      cat 1>&2 <<EOF
error: unknown option '$arg'.

USAGE: #{arg[0]} [<options>]

OPTIONS:
  --branch: create a new orphan branch
  --push: push new orphan branch
  --all: all of the above"
EOF
      exit 1
      ;;
  esac
done

if [ -n "$PUSH" ] && [ -z "$CREATE_BRANCH" ]; then
  panic "--push is pointless without --branch"
fi

USER_RE="s\-ol"
NEW_REMOTE_RE="git\.s\-ol.nu"
NEW_SLUG_RE=".*git\.s\-ol.nu[:/]public/(.*)"
NEW_HTTP="git.s-ol.nu"

REMOTES=$(git remote -v)

TMP=$(git remote -v | grep "github\.com[:/]$GITHUB_USER_RE.*(push)$" | awk '{print $1 " " $2}')
read OLD_REMOTE OLD_URL <<<$TMP
OLD_SLUG=$(sed -E "s|.*github\.com[:/]($GITHUB_USER_RE/.*)|\1|" <<<$OLD_URL)

TMP=$(git remote -v | grep "$NEW_REMOTE_RE.*(push)$" | awk '{print $1 " " $2}')
echo $TMP
read NEW_REMOTE NEW_URL <<<$TMP
NEW_SLUG=$(sed -E "s|$NEW_SLUG_RE$|\1|" <<<$NEW_URL)

echo "moving github.com/$OLD_SLUG [$OLD_REMOTE] -> $NEW_HTTP/$NEW_SLUG [$NEW_REMOTE]"

# print "- repos detected:"
# print "  moving #{gh_url} [#{gh_remote}] -> #{new_url} [#{new_remote}]"
# 
# if CREATE_BRANCH
  # execute 'git diff-index --quiet HEAD', 'working directory is dirty!'
# 
  # execute 'git checkout --orphan goodbye'
  # print "- branch created"
# 
# content = if file = io.open 'README.md', 'r'
  # trim file\read '*all'
# else if file = io.open 'README', 'r'
  # prefix_with '    ', trim file\read '*all'
# 
# with io.open 'README.md', 'w'
  # \write "this project has moved to a new home: [`#{new_url}`](//#{new_url})
# 
# this github archive will however be kept up-to-date.
# If you want to browse it here, switch on over to the [`master`](//#{gh_url}/tree/master/) branch."
  # if content
    # \write '\n\n***\n\n'
    # \write prefix_with '> ', content
    # \write '\n'
  # \close!
  # print "- README written"
# 
# if CREATE_BRANCH
  # execute 'git add README.md'
  # execute 'git commit -m "add goodbye message" README.md'
  # print "- README committed"
# 
# if PUSH
  # execute 'git push -u #{gh_remote}'
  # print "- branch pushed"
# 
# print "please go to https://#{gh_url}/settings/branches and set 'goodbye' as the default branch."

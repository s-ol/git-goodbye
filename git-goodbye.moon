#!/usr/bin/env moon

error = (msg) ->
  print msg
  os.exit 1

local CREATE_BRANCH, PUSH
for a in *arg
  switch a
    when '--branch'
      CREATE_BRANCH = true
    when '--push'
      PUSH = true
    when '--all'
      CREATE_BRANCH = true
      PUSH = true
    else
      error "unknown argument: '#{a}'.
USAGE: #{arg[0]} [<options>]

OPTIONS:
  --branch: create a new orphan branch
  --push: push new orphan branch
  --all: all of the above"

if PUSH and not CREATE_BRANCH
  error "--push is pointless without --branch"

execute = (cmd, msg="error executing '#{cmd}'") ->
  assert (os.execute cmd), msg

run_lines = (cmd) -> coroutine.wrap ->
  file = assert (io.popen cmd, 'r'), "error running '#{cmd}'"

  for line in file\lines!
    coroutine.yield line

  file\close!
  nil

trim = (str) -> str\gsub '\n$', ''
prefix_with = (prefix, str) ->
  str = str\gsub '\n', '\n' .. prefix
  prefix .. str

local gh_remote, gh_slug, gh_url
local new_remote, new_url
for line in run_lines 'git remote -v'
  name, url = line\match '^([a-z]+)%s+([^%s]+)%s+%(push%)'
  if not name
    continue

  if url\match 'github%.com'
    slug = url\match 'github%.com[:/](.*)%.git$'
    slug or= url\match 'github%.com[:/](.*)'
    assert slug, "couldn't find github slug"

    gh_remote = name
    gh_slug = slug
    gh_url = "github.com/#{slug}"
  else if slug = url\match 'git%.s%-ol%.nu[:/]public/(.*)%.git$'
    new_remote = name
    new_url = "git.s-ol.nu/#{slug}"

assert gh_remote and gh_url, "couldn't find github remote and url"
assert new_url, "couldn't find new url"

print "- repos detected:"
print "  moving #{gh_url} [#{gh_remote}] -> #{new_url} [#{new_remote}]"

if CREATE_BRANCH
  execute 'git diff-index --quiet HEAD', 'working directory is dirty!'

  execute 'git checkout --orphan goodbye'
  print "- branch created"

content = if file = io.open 'README.md', 'r'
  trim file\read '*all'
else if file = io.open 'README', 'r'
  prefix_with '    ', trim file\read '*all'

with io.open 'README.md', 'w'
  \write "this project has moved to a new home: [`#{new_url}`](//#{new_url})

this github archive will however be kept up-to-date.
If you want to browse it here, switch on over to the [`master`](//#{gh_url}/tree/master/) branch."
  if content
    \write '\n\n***\n\n'
    \write prefix_with '> ', content
    \write '\n'
  \close!
  print "- README written"

if CREATE_BRANCH
  execute 'git add README.md'
  execute 'git commit -m "add goodbye message" README.md'
  print "- README committed"

if PUSH
  execute 'git push -u #{gh_remote}'
  print "- branch pushed"

print "please go to https://#{gh_url}/settings/branches and set 'goodbye' as the default branch."

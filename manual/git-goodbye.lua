#!/usr/bin/env lua5.3
local error
error = function(msg)
  print(msg)
  return os.exit(1)
end
local CREATE_BRANCH, PUSH
local _list_0 = arg
for _index_0 = 1, #_list_0 do
  local a = _list_0[_index_0]
  local _exp_0 = a
  if '--branch' == _exp_0 then
    CREATE_BRANCH = true
  elseif '--push' == _exp_0 then
    PUSH = true
  elseif '--all' == _exp_0 then
    CREATE_BRANCH = true
    PUSH = true
  else
    error("unknown argument: '" .. tostring(a) .. "'.\nUSAGE: " .. tostring(arg[0]) .. " [<options>]\n\nOPTIONS:\n  --branch: create a new orphan branch\n  --push: push new orphan branch\n  --all: all of the above")
  end
end
if PUSH and not CREATE_BRANCH then
  error("--push is pointless without --branch")
end
local execute
execute = function(cmd, msg)
  if msg == nil then
    msg = "error executing '" .. tostring(cmd) .. "'"
  end
  return assert((os.execute(cmd)), msg)
end
local run_lines
run_lines = function(cmd)
  return coroutine.wrap(function()
    local file = assert((io.popen(cmd, 'r')), "error running '" .. tostring(cmd) .. "'")
    for line in file:lines() do
      coroutine.yield(line)
    end
    file:close()
    return nil
  end)
end
local trim
trim = function(str)
  return str:gsub('\n$', '')
end
local prefix_with
prefix_with = function(prefix, str)
  str = str:gsub('\n', '\n' .. prefix)
  return prefix .. str
end
local gh_remote, gh_slug, gh_url
local new_remote, new_url
for line in run_lines('git remote -v') do
  local _continue_0 = false
  repeat
    local name, url = line:match('^([a-z]+)%s+([^%s]+)%s+%(push%)')
    if not name then
      _continue_0 = true
      break
    end
    if url:match('github%.com') then
      local slug = url:match('github%.com[:/](.*)%.git$')
      slug = slug or url:match('github%.com[:/](.*)')
      assert(slug, "couldn't find github slug")
      gh_remote = name
      gh_slug = slug
      gh_url = "github.com/" .. tostring(slug)
    else
      do
        local slug = url:match('git%.s%-ol%.nu[:/]public/(.*)%.git$')
        if slug then
          new_remote = name
          new_url = "git.s-ol.nu/" .. tostring(slug)
        end
      end
    end
    _continue_0 = true
  until true
  if not _continue_0 then
    break
  end
end
assert(gh_remote and gh_url, "couldn't find github remote and url")
assert(new_url, "couldn't find new url")
print("- repos detected:")
print("  moving " .. tostring(gh_url) .. " [" .. tostring(gh_remote) .. "] -> " .. tostring(new_url) .. " [" .. tostring(new_remote) .. "]")
if CREATE_BRANCH then
  execute('git diff-index --quiet HEAD', 'working directory is dirty!')
  execute('git checkout --orphan goodbye')
  print("- branch created")
end
local content
do
  local file = io.open('README.md', 'r')
  if file then
    content = trim(file:read('*all'))
  else
    do
      file = io.open('README', 'r')
      if file then
        content = prefix_with('    ', trim(file:read('*all')))
      end
    end
  end
end
do
  local _with_0 = io.open('README.md', 'w')
  _with_0:write("this project has moved to a new home: [`" .. tostring(new_url) .. "`](//" .. tostring(new_url) .. ")\n\nthis github archive will however be kept up-to-date.\nIf you want to browse it here, switch on over to the [`master`](//" .. tostring(gh_url) .. "/tree/master/) branch.")
  if content then
    _with_0:write('\n\n***\n\n')
    _with_0:write(prefix_with('> ', content))
    _with_0:write('\n')
  end
  _with_0:close()
  print("- README written")
end
if CREATE_BRANCH then
  execute('git add README.md')
  execute('git commit -m "add goodbye message" README.md')
  print("- README committed")
end
if PUSH then
  execute('git push -u #{gh_remote}')
  print("- branch pushed")
end
return print("please go to https://" .. tostring(gh_url) .. "/settings/branches and set 'goodbye' as the default branch.")

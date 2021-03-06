
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local debug  = require("debug")

local capi   = { timer = (type(timer) == 'table' and timer or require ("gears.timer")) }
local io     = { open  = io.open,
                 lines = io.lines,
                 popen = io.popen }
local rawget = rawget
local table  = { sort   = table.sort }

-- Lain helper functions for internal use
-- lain.helpers
local helpers = {}

helpers.lain_dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
helpers.icons_dir   = helpers.lain_dir .. 'icons/'
helpers.scripts_dir = helpers.lain_dir .. 'scripts/'

-- {{{ Modules loader

function helpers.wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. '.' .. key)
end

-- }}}

-- {{{ File operations

-- see if the file exists and is readable
function helpers.file_exists(file)
  local f = io.open(file)
  if f then
      local s = f:read()
      f:close()
      f = s
  end
  return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function helpers.lines_from(file)
  if not helpers.file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

-- get first line of a file, return nil if
-- the file does not exist
function helpers.first_line(file)
    return helpers.lines_from(file)[1]
end

-- get first non empty line from a file,
-- returns nil otherwise
function helpers.first_nonempty_line(file)
  for k,v in pairs(helpers.lines_from(file)) do
    if #v then return v end
  end
  return nil
end

-- }}}

-- {{{ Timer maker

helpers.timer_table = {}

function helpers.newtimer(name, timeout, fun, nostart)
    helpers.timer_table[name] = capi.timer({ timeout = timeout })
    helpers.timer_table[name]:connect_signal("timeout", fun)
    helpers.timer_table[name]:start()
    if not nostart then
        helpers.timer_table[name]:emit_signal("timeout")
    end
end

-- }}}

-- {{{ Pipe operations

-- read the full output of a pipe (command)
function helpers.read_pipe(cmd)
   local f = assert(io.popen(cmd))
   local output = f:read("*all")
   f:close()
   return output
end

-- }}}

-- {{{ A map utility

helpers.map_table = {}

function helpers.set_map(element, value)
    helpers.map_table[element] = value
end

function helpers.get_map(element)
    return helpers.map_table[element]
end

-- }}}

--{{{ Iterate over table of records sorted by keys
function helpers.spairs(t)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    table.sort(keys)

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
--}}}

return helpers

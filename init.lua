----------------------------------------------------------------------
--- Autostart module for awesome
--
-- Start programs only once, not on restart. It is fast, works
-- every time, takes a single string with command and arguments,
-- and matches only the base command name for running processes. 
--
-- Use like so:
--   local autostart = require("autostart")
--   autostart("...")
--   autostart("...")
--   
-- This module is based upon a piece of code from the old AwesomeWM
-- wiki, which is not online anymore. The original author and license
-- are unknown.
--
-- @author warptozero
-- @website https://github.com/warptozero/awesome-autostart
-- @license MIT
----------------------------------------------------------------------

local awful = require("awful")
local lfs = require("lfs")
local naughty = require("naughty")
local dump = require("dump")

--- Return all current processes
-- All directories in /proc containing a number represent a process.
local function processwalker()
  local function yieldprocess()
    for dir in lfs.dir("/proc") do
      if tonumber(dir) ~= nil then
        local f, err = io.open("/proc/"..dir.."/cmdline")
        if f then
          local cmdline = f:read("*all")
          f:close()
          if cmdline ~= "" then
            coroutine.yield(cmdline)
          end
        end
      end
    end
  end
  return coroutine.wrap(yieldprocess)
end

-- Replace NUL-separation with spaces
local function denull(str)
   return str:sub( 0, string.len( str) - 1 );
end

-- Extract core command name
local function extract(string)
  return string.match(string.match(string, "^%S*"), "[^/]-$") or ""
end

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

--- Run command if there is no existing process
-- Takes a command with arguments as a single string
local function run(command, fluid_command )
  assert(type(command) == "string")
  local command_name = extract(command)
  local processes = processwalker()
  for process in processes do
    local process_name = extract(denull(process))
    if process_name == command_name then
      return
    end
    if fluid_command ~= nil then
	if starts_with( process_name, fluid_command ) then
	   return
	end
    end
  end
  return awful.util.spawn(command)
end

return run

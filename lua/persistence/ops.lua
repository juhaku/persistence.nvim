local Config = require("persistence.config")

local M = {}

local uv = vim.uv or vim.loop

--- get current branch name
---@return string?
function M.git_branch()
  if uv.fs_stat(".git") then
    local ret = vim.fn.systemlist("git branch --show-current")[1]
    return vim.v.shell_error == 0 and ret or nil
  end
end

---Convert session line to display line
---@param file string persistence session file to convert to display line
---@return string
function M.to_display_line(file)
  local show_branch = Config.options.branch

  local dir, branch = unpack(vim.split(file, "%%", { plain = true }))
  dir = dir:gsub("%%", "/")
  if jit.os:find("Windows") then
    dir = dir:gsub("^(%w)/", "%1:/")
  end
  dir = dir:gsub(vim.env.HOME, "~")
  if show_branch and branch ~= nil then
    local icon = ""
    local branch_ext = " " .. icon .. " " .. branch
    dir = dir .. branch_ext
  end
  return dir
end

---Convert display line to session folder
---@param line string display line to convert to fully qualified persistence session file name
---@return string
function M.to_session_file_name(line)
  local name = line:gsub("~", vim.env.HOME):gsub("[\\/:]+", "%%")

  if Config.options.branch then
    local branch = M.git_branch()
    if branch and branch ~= "main" and branch ~= "master" then
      name = name .. "%%" .. branch:gsub("[\\/:]+", "%%")
    end
  end

  return Config.options.dir .. name .. ".vim"
end

return M

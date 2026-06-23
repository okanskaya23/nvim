local M = {}

local function find_project_root()
  local file_name = vim.api.nvim_buf_get_name(0)
  local start_dir = vim.fs.dirname(file_name)
  if not start_dir then
    return nil
  end

  local matches = vim.fs.find(function(name)
    return name == '.git' or name:match '%.sln$' or name:match '%.csproj$'
  end, { path = start_dir, upward = true, limit = 1 })

  return matches[1] and vim.fs.dirname(matches[1]) or nil
end

function M.create_cs_template()
  -- Get the current buffer's file path
  local file_path = vim.fn.expand '%:p'

  -- Find project root
  local project_root = find_project_root()
  if not project_root then
    print "Couldn't determine project root. Using file directory as namespace."
    project_root = vim.fn.expand '%:p:h'
  end

  -- Generate namespace from file path relative to project root
  local relative_path = file_path:sub(#project_root + 2) -- +2 to remove leading slash
  local namespace = relative_path:gsub('[\\/]', '.'):match '(.+)%..+$' -- remove file extension
  if not namespace or namespace == '' then
    namespace = 'DefaultNamespace'
  end

  -- Extract the file name without extension
  local file_name = vim.fn.fnamemodify(file_path, ':t:r')

  -- Create the template
  local template = string.format(
    [[
using System;

namespace %s
{
    public class %s
    {
    }
}
]],
    namespace,
    file_name
  )

  -- Insert the template into the current buffer
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, '\n'))
  -- Save the file
  vim.cmd 'write'
end

return M

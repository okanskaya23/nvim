local M = {}

local function find_project_root()
  -- List of common root indicators
  local root_indicators = { '.git', '.sln', '.csproj' }

  local current_dir = vim.fn.expand '%:p:h'
  while current_dir ~= '/' do
    for _, indicator in ipairs(root_indicators) do
      if vim.fn.filereadable(current_dir .. '/' .. indicator) == 1 or vim.fn.isdirectory(current_dir .. '/' .. indicator) == 1 then
        return current_dir
      end
    end
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end
  return nil
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
    file_name,
    file_name
  )

  -- Insert the template into the current buffer
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, '\n'))
end

return M

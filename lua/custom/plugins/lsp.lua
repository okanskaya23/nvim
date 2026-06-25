return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    {
      'williamboman/mason.nvim',
      opts = {
        registries = {
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',
        },
      },
    },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    {
      'seblyng/roslyn.nvim',
      cond = function()
        local dotnet_paths = {
          vim.fn.exepath 'dotnet',
          '/opt/homebrew/bin/dotnet',
          '/usr/local/bin/dotnet',
        }
        local roslyn_path = vim.fn.stdpath 'data' .. '/mason/bin/roslyn-language-server'
        local has_dotnet = vim.iter(dotnet_paths):any(function(path)
          return path ~= nil and path ~= '' and vim.fn.executable(path) == 1
        end)
        return has_dotnet and (vim.fn.executable(roslyn_path) == 1 or vim.fn.executable 'roslyn-language-server' == 1)
      end,
      opts = {
        filewatching = 'roslyn',
        broad_search = true,
        silent = true,
      },
    },
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
  },
  config = function()
    local diagnostic_signs = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    }

    vim.diagnostic.config {
      virtual_text = {
        prefix = '',
      },
      signs = {
        text = diagnostic_signs,
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    }

    local function telescope_picker(name)
      return function()
        require('telescope.builtin')[name]()
      end
    end

    local lsp_attach_augroup = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true })
    local lsp_highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = true })
    local lsp_detach_augroup = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = lsp_attach_augroup,
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local is_roslyn = client and client.name == 'roslyn'

        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        if is_roslyn then
          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('grr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        else
          map('gd', telescope_picker 'lsp_definitions', '[G]oto [D]efinition')
          map('grr', telescope_picker 'lsp_references', '[G]oto [R]eferences')
          map('gI', telescope_picker 'lsp_implementations', '[G]oto [I]mplementation')
          map('<leader>D', telescope_picker 'lsp_type_definitions', 'Type [D]efinition')
        end

        map('<leader>ds', telescope_picker 'lsp_document_symbols', '[D]ocument [S]ymbols')
        map('<leader>ws', telescope_picker 'lsp_dynamic_workspace_symbols', '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_clear_autocmds { group = lsp_highlight_augroup, buffer = event.buf }
          vim.api.nvim_create_autocmd('CursorHold', {
            buffer = event.buf,
            group = lsp_highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd('CursorMoved', {
            buffer = event.buf,
            group = lsp_highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_clear_autocmds { group = lsp_detach_augroup, buffer = event.buf }
          vim.api.nvim_create_autocmd('LspDetach', {
            buffer = event.buf,
            group = lsp_detach_augroup,
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = lsp_highlight_augroup, buffer = event2.buf }
            end,
          })
        end

        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>th', function()
            local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

    local function executable(name)
      local mason_path = vim.fn.stdpath 'data' .. '/mason/bin/' .. name
      if vim.fn.executable(mason_path) == 1 then
        return mason_path
      end

      local path = vim.fn.exepath(name)
      return path ~= '' and path or name
    end

    local function executable_path(name)
      local mason_path = vim.fn.stdpath 'data' .. '/mason/bin/' .. name
      if vim.fn.executable(mason_path) == 1 then
        return mason_path
      end

      for _, bin_dir in ipairs { '/opt/homebrew/bin', '/usr/local/bin' } do
        local absolute_path = bin_dir .. '/' .. name
        if vim.fn.executable(absolute_path) == 1 then
          return absolute_path
        end
      end

      local path = vim.fn.exepath(name)
      return path ~= '' and path or nil
    end

    local dotnet_cmd = executable_path 'dotnet'
    local has_dotnet = dotnet_cmd ~= nil
    local roslyn_cmd = executable_path 'roslyn-language-server'
    local has_roslyn = has_dotnet and roslyn_cmd ~= nil
    local dotnet_root = vim.env.DOTNET_ROOT
    if not dotnet_root or dotnet_root == '' then
      for _, candidate in ipairs { '/opt/homebrew/opt/dotnet/libexec', '/usr/local/share/dotnet' } do
        if vim.fn.isdirectory(candidate) == 1 then
          dotnet_root = candidate
          break
        end
      end
    end

    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }

    if has_roslyn then
      servers.roslyn = {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = false,
            },
          },
        },
        cmd_env = {
          Configuration = vim.env.Configuration or 'Debug',
          DOTNET_ROOT = dotnet_root,
          DOTNET_ROOT_ARM64 = dotnet_root,
          TMPDIR = vim.env.TMPDIR and vim.fn.resolve(vim.env.TMPDIR) or nil,
        },
        settings = {
          ['csharp|background_analysis'] = {
            dotnet_analyzer_diagnostics_scope = 'openFiles',
            dotnet_compiler_diagnostics_scope = 'openFiles',
          },
          ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = false,
            dotnet_enable_tests_code_lens = false,
          },
          ['csharp|completion'] = {
            dotnet_provide_regex_completions = false,
            dotnet_show_completion_items_from_unimported_namespaces = true,
          },
          ['csharp|formatting'] = {
            dotnet_organize_imports_on_format = true,
          },
          ['csharp|symbol_search'] = {
            dotnet_search_reference_assemblies = false,
          },
        },
      }
    end

    for server_name, server in pairs(servers) do
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      vim.lsp.config(server_name, server)
    end

    local ensure_installed = { 'stylua' }
    if has_dotnet then
      table.insert(ensure_installed, 'roslyn')
      table.insert(ensure_installed, 'netcoredbg')
    end

    require('mason-tool-installer').setup {
      ensure_installed = ensure_installed,
    }

    require('mason-lspconfig').setup {
      ensure_installed = {
        'lua_ls',
      },
      automatic_enable = false,
    }

    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}

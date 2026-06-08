return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    {
      'Hoffs/omnisharp-extended-lsp.nvim',
      lazy = true,
    },
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} },
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

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_clear_autocmds { group = highlight_augroup, buffer = event.buf }
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = highlight_augroup, buffer = event2.buf }
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

    local has_dotnet = vim.fn.executable 'dotnet' == 1
    local omnisharp_cmd = has_dotnet and 'OmniSharp' or 'omnisharp-mono'
    local omnisharp_package = has_dotnet and 'omnisharp' or 'omnisharp-mono'
    local omnisharp_args = {
      executable(omnisharp_cmd),
      '-z',
      '--hostPID',
      tostring(vim.fn.getpid()),
      'DotNet:enablePackageRestore=false',
    }

    if has_dotnet then
      vim.list_extend(omnisharp_args, { '--encoding', 'utf-8' })
    end

    vim.list_extend(omnisharp_args, { '--languageserver' })

    local servers = {
      omnisharp = {
        cmd = omnisharp_args,
        handlers = {
          ['textDocument/definition'] = require('omnisharp_extended').handler,
        },
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
          MsBuild = {
            LoadProjectsOnDemand = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableDecompilationSupport = true,
            EnableImportCompletion = true,
            AnalyzeOpenDocumentsOnly = false,
          },
          RenameOptions = {
            RenameInComments = true,
            RenameInStrings = true,
            RenameOverloads = true,
          },
          Sdk = {
            IncludePrereleases = true,
          },
        },
      },
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

    for server_name, server in pairs(servers) do
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      vim.lsp.config(server_name, server)
    end

    require('mason-tool-installer').setup {
      ensure_installed = {
        omnisharp_package,
        'stylua',
      },
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

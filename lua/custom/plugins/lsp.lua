return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
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

    local function omnisharp_get_client(bufnr)
      local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'omnisharp' }
      return clients[1]
    end

    local function omnisharp_file_name(bufnr, uri)
      local ok, file_name = pcall(vim.api.nvim_buf_get_var, bufnr, 'omnisharp_extended_file_name')
      if ok then
        return file_name
      end

      return vim.uri_to_fname(uri)
    end

    local function omnisharp_position_params(client, bufnr)
      local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      return {
        fileName = omnisharp_file_name(bufnr, params.textDocument.uri),
        column = params.position.character,
        line = params.position.line,
      }
    end

    local function omnisharp_definition_params(client, bufnr)
      return vim.tbl_extend('force', omnisharp_position_params(client, bufnr), {
        timeout = 10000,
        wantMetadata = true,
      })
    end

    local omnisharp_utils_loaded = false
    local omnisharp_utils = nil

    local function get_omnisharp_utils()
      if omnisharp_utils_loaded then
        return omnisharp_utils
      end

      omnisharp_utils_loaded = true
      local ok, utils = pcall(require, 'omnisharp_utils')
      if ok then
        omnisharp_utils = utils
      end

      return omnisharp_utils
    end

    local function omnisharp_load_virtual_definition(definition, client)
      if type(definition.MetadataSource) ~= 'table' and type(definition.SourceGeneratedFileInfo) ~= 'table' then
        return definition.Location.FileName
      end

      local utils = get_omnisharp_utils()
      if not utils then
        return definition.Location.FileName
      end

      if type(definition.MetadataSource) == 'table' then
        local metadata_params = vim.tbl_extend('force', { timeout = 5000 }, definition.MetadataSource)
        local metadata_ok, _, metadata_file = pcall(utils.load_metadata_doc, metadata_params, client)
        if metadata_ok then
          return metadata_file
        end
      end

      if type(definition.SourceGeneratedFileInfo) == 'table' then
        local source_params = vim.tbl_extend('force', { timeout = 5000 }, definition.SourceGeneratedFileInfo)
        local source_ok, _, source_file = pcall(utils.load_sourcegen_doc, source_params, client)
        if source_ok then
          return source_file
        end
      end

      return definition.Location.FileName
    end

    local function omnisharp_definition_locations(result, client)
      local definitions = result and result.Definitions
      if type(definitions) ~= 'table' then
        return {}
      end

      local locations = {}
      for _, definition in ipairs(definitions) do
        if type(definition) == 'table' and type(definition.Location) == 'table' then
          local file_name = omnisharp_load_virtual_definition(definition, client)
          local range = definition.Location.Range
          if file_name and type(range) == 'table' then
            table.insert(locations, {
              uri = vim.uri_from_fname(file_name),
              range = {
                start = {
                  line = range.Start.Line,
                  character = range.Start.Column,
                },
                ['end'] = {
                  line = range.End.Line,
                  character = range.End.Column,
                },
              },
            })
          end
        end
      end

      return locations
    end

    local function omnisharp_show_locations(locations, client)
      if #locations == 0 then
        vim.notify 'No locations found'
        return
      end

      if #locations == 1 then
        vim.lsp.util.show_document(locations[1], client.offset_encoding, { reuse_win = true })
        return
      end

      local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
      vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = items })
      vim.cmd.copen()
    end

    local function omnisharp_location_uri(location)
      return location.uri or location.targetUri
    end

    local function omnisharp_location_needs_extended(location)
      local uri = omnisharp_location_uri(location)
      if not uri then
        return true
      end

      local ok, file_name = pcall(vim.uri_to_fname, uri)
      if not ok or not file_name then
        return true
      end

      return file_name:find '%$metadata%$' ~= nil or vim.uv.fs_stat(file_name) == nil
    end

    local function omnisharp_normalize_locations(result)
      if not result then
        return {}
      end

      if vim.islist(result) then
        return result
      end

      return { result }
    end

    local function omnisharp_goto_definition()
      local bufnr = vim.api.nvim_get_current_buf()
      local client = omnisharp_get_client(bufnr)
      if not client then
        vim.notify 'OmniSharp is not attached'
        return
      end

      client.request('o#/v2/gotodefinition', omnisharp_definition_params(client, bufnr), function(err, result)
        if err then
          vim.notify('OmniSharp definition failed: ' .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
          return
        end

        omnisharp_show_locations(omnisharp_definition_locations(result, client), client)
      end, bufnr)
    end

    local function omnisharp_fast_definition()
      local bufnr = vim.api.nvim_get_current_buf()
      local client = omnisharp_get_client(bufnr)
      if not client then
        vim.notify 'OmniSharp is not attached'
        return
      end

      local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      client.request('textDocument/definition', params, function(err, result)
        if err then
          vim.notify('OmniSharp definition failed: ' .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
          return
        end

        local locations = omnisharp_normalize_locations(result)
        if #locations == 0 or vim.iter(locations):any(omnisharp_location_needs_extended) then
          omnisharp_goto_definition()
          return
        end

        omnisharp_show_locations(locations, client)
      end, bufnr)
    end

    local function omnisharp_references()
      local bufnr = vim.api.nvim_get_current_buf()
      local client = omnisharp_get_client(bufnr)
      if not client then
        vim.notify 'OmniSharp is not attached'
        return
      end

      client.request('o#/findusages', vim.tbl_extend('force', omnisharp_position_params(client, bufnr), { excludeDefinition = true }), function(err, result)
        if err then
          vim.notify('OmniSharp references failed: ' .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
          return
        end

        local quickfixes = result and result.QuickFixes
        if type(quickfixes) ~= 'table' or vim.tbl_isempty(quickfixes) then
          vim.notify 'No references found'
          return
        end

        local items = {}
        for _, quickfix in ipairs(quickfixes) do
          if type(quickfix) == 'table' and quickfix.FileName then
            table.insert(items, {
              filename = quickfix.FileName,
              lnum = (quickfix.Line or 0) + 1,
              col = (quickfix.Column or 0) + 1,
              end_lnum = quickfix.EndLine and (quickfix.EndLine + 1) or nil,
              end_col = quickfix.EndColumn and (quickfix.EndColumn + 1) or nil,
              text = quickfix.Text or '',
            })
          end
        end

        if vim.tbl_isempty(items) then
          vim.notify 'No references found'
          return
        end

        vim.fn.setqflist({}, ' ', { title = 'LSP References', items = items })
        vim.cmd.copen()
      end, bufnr)
    end

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
        local is_omnisharp = client and client.name == 'omnisharp'

        if is_omnisharp then
          client.server_capabilities.semanticTokensProvider = nil
        end

        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        if is_omnisharp then
          map('gd', omnisharp_fast_definition, '[G]oto [D]efinition')
          map('<leader>cD', omnisharp_goto_definition, '[C]# Metadata [D]efinition')
          map('gr', omnisharp_references, '[G]oto [R]eferences')
          map('grr', omnisharp_references, '[G]oto [R]eferences')
          map('gI', function()
            require('omnisharp_extended').lsp_implementation()
          end, '[G]oto [I]mplementation')
          map('<leader>D', function()
            require('omnisharp_extended').lsp_type_definition()
          end, 'Type [D]efinition')
        else
          map('gd', telescope_picker 'lsp_definitions', '[G]oto [D]efinition')
          map('gr', telescope_picker 'lsp_references', '[G]oto [R]eferences')
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

    local function omnisharp_start_target(root_dir)
      if not root_dir then
        return nil
      end

      local solutions = vim.fn.glob(root_dir .. '/*.sln', false, true)
      if #solutions == 0 then
        return root_dir
      end

      table.sort(solutions, function(a, b)
        local a_stat = vim.uv.fs_stat(a)
        local b_stat = vim.uv.fs_stat(b)
        local a_mtime = a_stat and a_stat.mtime.sec or 0
        local b_mtime = b_stat and b_stat.mtime.sec or 0
        if a_mtime == b_mtime then
          return a < b
        end

        return a_mtime > b_mtime
      end)

      return solutions[1]
    end

    local function with_start_target(cmd, target)
      if not target then
        return cmd
      end

      for index, arg in ipairs(cmd) do
        if arg == '--languageserver' then
          table.insert(cmd, index, '-s')
          table.insert(cmd, index + 1, target)
          return cmd
        end
      end

      vim.list_extend(cmd, { '-s', target })
      return cmd
    end

    local function flatten_settings(settings)
      local flattened = {}

      local function flatten(table_value, prefix)
        for key, value in pairs(table_value) do
          local setting_name = prefix and (prefix .. ':' .. key) or key
          if type(value) == 'table' then
            flatten(value, setting_name)
          else
            table.insert(flattened, setting_name .. '=' .. vim.inspect(value))
          end
        end
      end

      flatten(settings)
      table.sort(flattened)
      return flattened
    end

    local function start_omnisharp(dispatchers, config)
      local target = omnisharp_start_target(config.root_dir)
      local cmd = with_start_target(vim.deepcopy(omnisharp_args), target)
      vim.list_extend(cmd, flatten_settings(config.settings or {}))
      config.cmd = cmd
      config.cmd_cwd = config.root_dir

      return vim.lsp.rpc.start(cmd, dispatchers, {
        cwd = config.root_dir,
        env = config.cmd_env,
        detached = config.detached,
      })
    end

    local servers = {
      omnisharp = {
        cmd = start_omnisharp,
        capabilities = {
          workspace = {
            workspaceFolders = false,
          },
        },
        root_dir = function(bufnr, on_dir)
          local name = vim.api.nvim_buf_get_name(bufnr)
          local start_dir = vim.fs.dirname(name)
          local project_markers = vim.fs.find(function(marker)
            return marker:match '%.sln$' ~= nil or marker:match '%.csproj$' ~= nil
          end, { path = start_dir, upward = true, limit = 1 })
          local unity_markers = vim.fs.find(function(marker)
            return marker == 'ProjectSettings' or marker == 'Packages' or marker == 'Assets'
          end, { path = start_dir, upward = true, limit = 1 })
          local root = project_markers[1] and vim.fs.dirname(project_markers[1]) or unity_markers[1] and vim.fs.dirname(unity_markers[1]) or nil
          if root then
            on_dir(root)
          end
        end,
        workspace_required = true,
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
          MsBuild = {
            LoadProjectsOnDemand = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = false,
            EnableDecompilationSupport = true,
            EnableImportCompletion = false,
            AnalyzeOpenDocumentsOnly = true,
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

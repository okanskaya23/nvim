return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  branch = '0.1.x',
  keys = function()
    local function builtin(name, opts)
      return function()
        require('telescope.builtin')[name](opts)
      end
    end

    return {
      { '<leader>fh', builtin 'help_tags', desc = ' Find [H]elp' },
      { '<leader>fk', builtin 'keymaps', desc = ' Find [K]eymaps' },
      { '<leader>bb', builtin 'buffers', desc = ' Find [F]iles' },
      { '<leader>fs', builtin 'builtin', desc = ' Find [S]elect Telescope' },
      { '<leader>fw', builtin 'grep_string', desc = ' Find current [W]ord' },
      { '<leader>ff', builtin 'live_grep', desc = ' Find by [G]rep' },
      { '<leader>fd', builtin 'diagnostics', desc = ' Find [D]iagnostics' },
      { '<leader>fc', builtin 'resume', desc = ' Find [R]esume' },
      { '<leader>fr', builtin 'oldfiles', desc = ' Find Recent Files ("." for repeat)' },
      { '<leader>fg', builtin 'git_status', desc = ' Git [S]tatus' },
      {
        '<leader><leader>',
        function()
          require('telescope.builtin').find_files {
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/*.{prefab,meta}' },
          }
        end,
        desc = '[ ] Find files (ignoring .prefab and .meta)',
      },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        desc = ' Find [/] in Open Files',
      },
      {
        '<leader>sn',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = ' Find [N]eovim files',
      },
    }
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      pickers = {
        buffers = {
          mappings = {
            i = {
              ['<C-d>'] = 'delete_buffer',
            },
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
  end,
}

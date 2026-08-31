---@module 'lazy'
---@type LazySpec

return {
  {
    'HiPhish/rainbow-delimiters.nvim',
    submodules = false,
    config = function()
      local apply_oasis_rainbow = function()
        local palette = require('oasis.palette').terminal
        local groups = {
          RainbowDelimiterRed = palette.red,
          RainbowDelimiterOrange = palette.bright_yellow,
          RainbowDelimiterYellow = palette.yellow,
          RainbowDelimiterGreen = palette.green,
          RainbowDelimiterCyan = palette.cyan,
          RainbowDelimiterBlue = palette.blue,
          RainbowDelimiterViolet = palette.magenta,
        }

        for group, color in pairs(groups) do
          vim.api.nvim_set_hl(0, group, { fg = color })
        end
      end

      apply_oasis_rainbow()
      vim.api.nvim_create_autocmd('ColorScheme', {
        desc = 'Re-apply oasis colors to rainbow-delimiters',
        callback = apply_oasis_rainbow,
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'oasis',
        icons_enabled = true,
        component_separators = '',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          {
            function()
              local root = vim.fs.root(0, '.git')
              return root and vim.fn.fnamemodify(root, ':t') or ''
            end,
            icon = '',
            color = { fg = require('oasis.palette').terminal.magenta, gui = 'bold' },
            padding = { left = 0, right = 0 },
          },
          'branch',
          'diff',
          'diagnostics',
        },
        lualine_c = {
          { 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
          { 'filename', path = 1 },
        },
        lualine_x = {
          {
            function()
              local tools = {}
              for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
                tools[#tools + 1] = client.name
              end
              local ok, lint = pcall(require, 'lint')
              if ok then
                for _, linter in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
                  tools[#tools + 1] = linter
                end
              end
              return #tools > 0 and (' ' .. table.concat(tools, ',')) or ''
            end,
          },
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },
  {
    'dlyongemallo/diffview-plus.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewDiffFiles', 'DiffviewMergeFiles', 'DiffviewDiffDirs' },
    opts = {
      view = {
        merge_tool = {
          layout = 'diff3_mixed',
        },
      },
    },
    config = function(_, opts)
      require('diffview').setup(opts)

      -- Workaround for `$`-prefixed filenames failing to expand
      local PathLib = require('diffview.path').PathLib
      PathLib.expand = function(self, path)
        local segments = self:explode(path)
        local idx = 1
        if segments[1] == '~' then
          segments[1] = vim.uv.os_homedir()
          idx = 2
        end
        for i = idx, #segments do
          local env_var = segments[i]:match '^%$(%S+)$'
          if env_var then
            local value = os.getenv(env_var)
            if value ~= nil then segments[i] = value end
          end
        end
        return self:join((table.unpack or unpack)(segments))
      end
    end,
  },
}

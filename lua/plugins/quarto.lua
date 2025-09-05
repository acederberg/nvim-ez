return {
  --[[ { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
    -- for complete functionality (language features)
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dev = false,
    opts = {
      lspFeatures = {
        languages = {
          "r",
          "python",
          "julia",
          "bash",
          "lua",
          "html",
          "dot",
          "c_sharp",
          -- "mermaid",
          "javascript",
          "typescript",
          "ojs",
          "yaml",
          "json",
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua and
      -- added as a nvim-cmp source in lua/plugins/completion.lua
      "jmbuhr/otter.nvim",
    },
  }, ]]
  {
    -- directly open ipynb files as quarto docuements
    -- and convert back behind the scenes
    -- needs:
    -- pip install jupytext
    "GCBallesteros/jupytext.nvim",
    opts = {
      custom_language_formatting = {
        python = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto", -- you can set whatever filetype you want here
        },
        r = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto", -- you can set whatever filetype you want here
        },
      },
    },
  },
  { -- paste an image from the clipboard or drag-and-drop
    "HakonHarnes/img-clip.nvim",
    event = "BufEnter",
    ft = { "markdown", "quarto", "latex" },
    opts = {
      default = {
        dir_path = "img",
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(_, opts)
      require("img-clip").setup(opts)
      local wk = require("which-key")

      wk.add({
        { "@@i", group = "[i]mage." },
        { "@@ii", ":PasteImage<cr>", desc = "[i]mage [i]nsert from clipboard", mode = "n" },
      })
    end,
  },

  { -- preview equations
    "jbyuki/nabla.nvim",
    ft = { "markdown", "quarto", "latex" },
    config = function()
      local wk = require("which-key")
      local nabla = require("nabla")

      wk.add({
        { "@@n", group = "[n]abla" },
        {
          "@@nr",
          function()
            nabla.toggle_virt()
          end,
          desc = "Render TeX [eq]uations",
        },
      })
    end,
  },
  {
    "3rd/image.nvim",
    enabled = true,
    dev = false,
    ft = { "markdown", "quarto", "vimwiki" },
    cond = function()
      -- Disable on Windows system
      return vim.fn.has("win32") ~= 1
    end,
    dependencies = {
      "leafo/magick", -- that's a lua rock
      "folke/which-key.nvim",
    },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt install lua5.1
      -- sudo apt install luajit

      local wk = require("which-key")
      local image = require("image")

      image.setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            -- only_render_image_at_cursor_mode = "popup",
            filetypes = { "markdown", "vimwiki", "quarto" },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        tmux_show_only_in_active_window = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "scrollview", "scrollview_sign" },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 30,
        kitty_method = "normal",
      })

      local function clear_all_images()
        local bufnr = vim.api.nvim_get_current_buf()
        local images = image.get_images({ buffer = bufnr })
        for _, img in ipairs(images) do
          img:clear()
        end
      end

      local function get_image_at_cursor(buf)
        local images = image.get_images({ buffer = buf })
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, img in ipairs(images) do
          if img.geometry ~= nil and img.geometry.y == row then
            local og_max_height = img.global_state.options.max_height_window_percentage
            img.global_state.options.max_height_window_percentage = nil
            return img, og_max_height
          end
        end
        return nil
      end

      local create_preview_window = function(img, og_max_height)
        local buf = vim.api.nvim_create_buf(false, true)
        local win_width = vim.api.nvim_get_option_value("columns", {})
        local win_height = vim.api.nvim_get_option_value("lines", {})
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          style = "minimal",
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          zindex = 1000,
        })

        wk.add({
          "@@ix",
          function()
            vim.api.nvim_win_close(win, true)
            img.global_state.options.max_height_window_percentage = og_max_height
          end,
          buffer = buf,
          desc = "[i]mage e[x]it.",
        })

        return { buf = buf, win = win }
      end

      local handle_zoom = function(bufnr)
        local img, og_max_height = get_image_at_cursor(bufnr)
        if img == nil then
          return
        end

        local preview = create_preview_window(img, og_max_height)
        image.hijack_buffer(img.path, preview.win, preview.buf)
      end

      wk.add({
        { "@@i", group = "[i]mage." },
        {
          "@@io",
          function()
            local bufnr = vim.api.nvim_get_current_buf()
            handle_zoom(bufnr)
          end,
          desc = "[i]mage [o]pen.",
        },
        { "@@ic", clear_all_images, desc = "[i]mages [c]lear." },
      })
    end,
  },
  {
    "benlubas/molten-nvim",
    dependencies = {
      "folke/which-key.nvim",
    },
    lazy = false,
    enabled = true,
    build = ":UpdateRemotePlugins",
    init = function()
      local wk = require("which-key")
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.print("Initializing molten.")

      wk.add({
        { "@@m", group = "[m]olten" },
        {
          "@@mi",
          function()
            local venv = os.getenv("VIRTUAL_ENV") -- or os.getenv("CONDA_PREFIX")
            vim.print("Found venv at " .. venv)

            if venv ~= nil then
              -- NOTE: In the docs, this is done by matching the final path segment.
              --       However, I tend to name my virtual envs `.venv` in their
              --       respective project folders and generate the kernal
              --       like `python -m ipykernal install --name "<name-of project folder>".
              --       As a result, this pattern tries to capture the folder so that
              --       the rest can find the kernal matching it.
              venv = string.match(venv, "/.+/(.+)/.venv")

              vim.print("Matched `venv=" .. venv .. "`.")
              vim.cmd(("MoltenInit %s"):format(venv))
            else
              vim.cmd("MoltenInit python3")
            end
          end,
          mode = "n",
          desc = "[m]olten [i]nitialize for python3.",
        },
        {
          "@@mv",
          ":<C-u>MoltenEvaluateVisual<cr>",
          mode = "v",
          desc = "[m]olten eval [v]isual.",
        },
        {
          "@@mo",
          ":MoltenEvaluateOperator<CR>",
          desc = "[m]olten [o]perator evaluate.",
        },
        {
          "@@ml",
          ":MoltenEvaluateLine<CR>",
          desc = "[m]olten [l]ine eval.",
        },
        {
          "@@mr",
          ":MoltenReevaluateCell<CR>",
          desc = "[m]olten [r]e-evaluate cell.",
        },
        {
          "@@mx",
          ":MoltenDeinit<CR>",
          desc = "[m]olten e[x]it.",
        },
        {
          "@@mk",
          group = "[m]olten [k]ernal",
          {
            "@@mks",
            ":MoltenSave<CR>",
            desc = "[m]olten [k]ernal [s]ave",
          },
          {
            "@@mkl",
            ":MoltenLoad<CR>",
            desc = "[m]olten [k]ernal [l]oad",
          },
        },
      })
    end,
  },
  { -- show tree of symbols in the current file
    "hedyhli/outline.nvim",
    dependencies = { "folke/which-key.nvim" },
    -- cmd = "Outline",
    config = function()
      local wk = require("which-key")
      local outline = require("outline")

      outline.setup()
      wk.add({
        { "@@o", group = "[o]utline." },
        {
          "@@os",
          function()
            outline.toggle()
          end,
          desc = "[o]utline [s]how/unshow.",
        },
        {
          { "@@of", desc = "[o]utline [f]ocus." },
          { "@@ofo", ":OutlineFocusOutline<cr>", desc = "[o]utline [f]ocus [o]utline." },
          { "@@ofc", ":OutlineFocusCode<cr>>", desc = "[o]utline [f]ocus [c]ode" },
        },
      })
    end,
    opts = {
      providers = {
        priority = { "markdown", "lsp", "norg" },
        -- Configuration for each provider (3rd party providers are supported)
        lsp = {
          -- Lsp client names to ignore
          blacklist_clients = {},
        },
        markdown = {
          -- List of supported ft's to use the markdown provider
          filetypes = { "markdown", "quarto" },
        },
      },
    },
  },
}

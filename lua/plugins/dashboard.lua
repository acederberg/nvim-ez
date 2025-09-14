return {
  {
    "goolord/alpha-nvim",
    -- dependencies = { 'echasnovski/mini.icons' },
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      local dashboard = require("alpha.themes.dashboard")

      -- NOTE: These should match the keymaps without the leaders (when keymaps exist).
      dashboard.section.buttons.val = {
        dashboard.button("pf", "󱑛 > Load a Session", ':lua require("persistence").select()<cr>'),
        dashboard.button("r", " > Recent", ":Telescope oldfiles<CR>"),
        dashboard.button("e", " > New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "󰈞 > Find file", ":Telescope find_files<CR>"),
        dashboard.button("s", " > Settings", ":e ~/.config/nvim/lua | :cd %:p:h<cr>"),
        dashboard.button("ze", "󱆃 > ZSH Settings", ":e ~/.zshrc<CR>"),
        dashboard.button("zo", " > Open a Terminal", ":e term://zsh<cr>"),
        dashboard.button("zs", " > Open a Terminal (Split)", ":split term://zsh<cr>"),
        dashboard.button("zv", " > Open a Terminal (Vertical)", ":vsplit term://zsh<cr>"),
        dashboard.button("gdo", " > Open Diffview", ":DiffviewOpen<CR>"),
        dashboard.button("gc", "󰜘 > Make a Commit", ":DiffviewOpen<CR>:Neogit commit<CR>ic"),
        dashboard.button("aa", "󱇯 Ask GPT", ":AvanteAsk<CR>"),
        dashboard.button("q", "󰅚 > Quit NVIM", ":qa<CR>"),
      }

      require("alpha").setup(dashboard.config)
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Extensions
      "nvim-neotest/neotest-python",
      "Issafalcon/neotest-dotnet",
    },
    config = function()
      local neotest = require("neotest")
      local neotestLogging = require("neotest.logging")

      local neotestDotnet = require("neotest-dotnet")
      local wk = require("which-key")

      local neotestPython = require("neotest-python")
      neotestPython({
        --- @param file_path string
        --- @return boolean
        is_test_file = function(file_path)
          vim.print("Check if is test file")
          local fileIsTestFile = file_path:match("^test_")
          vim.print(fileIsTestFile)
          return fileIsTestFile
        end,
      })

      neotest.setup({
        icons = {
          running_animated = {
            "⠋",
            "⠙",
            "⠚",
            "⠒",
            "⠂",
            "⠂",
            "⠒",
            "⠲",
            "⠴",
            "⠦",
            "⠖",
            "⠒",
            "⠐",
            "⠐",
            "⠒",
            "⠓",
            "⠋",
          },
        },
        log_level = vim.log.levels.DEBUG,
        adapters = {
          neotestDotnet,
          neotestPython,
        },
      })

      wk.add({
        { "@@t", group = "[t]est" },
        {
          {
            { "@@tl", group = "[t]est [l]ogs." },
            {
              "@@tls",
              function()
                -- vim.print(neotestLogging._filename)
                vim.cmd(([[
                  vsplit %s
                ]]):format(neotestLogging._filename))
              end,
              mode = "n",
              desc = "[t]est [l]ogs [s]how.",
            },
            {
              "@@tlx",
              function()
                os.remove(neotestLogging._filename)
              end,
              mode = "n",
              desc = "[t]est [l]ogs clear.",
            },
          },
          {
            { "@@tc", group = "[t]est [c]lostest" },
            {
              "@@tcr",
              function()
                neotest.run.run()
              end,
              group = "[t]est [c]losest [r]un.",
              mode = "n",
            },
            {
              "@@tcd",
              function()
                neotest.run.run({ strategy = "dap" })
                neotest.summary.open()
                neotest.jump.next({ status = "failed" })
              end,
              mode = "n",
              desc = "[t]est [c]losest [d]ebug.",
            },
          },
          {
            { "@@tf", "[t]est [f]file." },
            {
              "@@tfr",
              function()
                neotest.output_panel.clear()

                neotest.run.run(vim.fn.expand("%"))
                neotest.summary.open()
                -- neotest.output_panel.open()
              end,
              group = "[t]est [f]ile [r]un.",
              mode = "n",
            },
            {
              "@@tfd",
              function()
                neotest.run.run({ vim.fn.expand("%"), strategy = "dap" })
                neotest.summary.open()
                -- neotest.output_panel.open()
              end,
              mode = "n",
              desc = "[t]est [f]ile [d]ebug.",
            },
          },
          {
            { "@@tw", desc = "[t]est [w]atch." },
            {
              "@@twe",
              function()
                -- neotest.output_panel.clear()

                -- neotest.watch.watch()
                neotest.watch.watch(vim.fn.expand("%"))
                -- neotest.output_panel.open()
                neotest.summary.open()
              end,
              mode = "n",
              desc = "[t]est [w]atch [e]nter.",
            },
            {
              "@@twx",
              function()
                neotest.watch.stop(vim.fn.expand("%"))
                neotest.output_panel.close()
                neotest.summary.close()
              end,
              mode = "n",
              desc = "[t]est [w]atch e[x]it.",
            },
            {
              "@@tws",
              function()
                neotest.watch.toggle()
              end,
              mode = "n",
              desc = "[t]est [w]atch [s]how.",
            },
            {
              "@@tw?",
              function()
                local is
                local filename = vim.fn.expand("%")
                if neotest.watch.is_watching(filename) then
                  is = "is"
                else
                  is = "is not"
                end

                local msg = "Neotest %s watching `%s`."
                vim.print(msg:format(is, filename))
              end,
              mode = "n",
              desc = "[t]est [w]atch is running?",
            },
          },
          {
            { "@@tg", group = "[t]est [g]oto" },
            {
              "@@tgn",
              function()
                neotest.jump.next()
              end,
              mode = "n",
              desc = "[t]est [g]oto [n]ext.",
            },
            {
              "@@tgp",
              function()
                neotest.jump.prev()
              end,
              mode = "n",
              desc = "[t]est [g]oto [p]revious.",
            },
            {
              {
                "@@tgf",
                group = "[t]est [g]oto [f]ailed.",
              },
              {
                "@@tgfn",
                function()
                  neotest.jump.next({ status = "failed" })
                  neotest.output.open()
                end,
                mode = "n",
                desc = "[t]est [g]oto [f]ailed [n]ext.",
              },
              {
                "@@tgfp",
                function()
                  neotest.jump.prev({ status = "failed" })
                  neotest.output.open()
                end,
                mode = "n",
                desc = "[t]est [g]oto [f]ailed [p]revious.",
              },
            },
          },
          {
            { "@@to", group = "[t]est [o]utput." },
            {
              "@@tot",
              function()
                neotest.output.open({ enter = true })
              end,
              desc = "[t]est [o]utput for [t]est.",
              mode = "n",
            },
            {
              "@@too",
              function()
                neotest.output_panel.toggle()
              end,
              desc = "[t]est [o]utput [o]pen/close.",
              mode = "n",
            },
            {
              "@@toc",
              function()
                neotest.output_panel.clear()
              end,
              desc = "[t]est [o]utput [c]lear.",
            },
          },
          {
            "@@tx",
            function()
              neotest.run.stop()
              neotest.output_panel.close()
              neotest.summary.close()
            end,
            desc = "[t]est e[x]it.",
            mode = "n",
          },
          {
            "@@ta",
            function()
              neotest.run.attach()
            end,
            desc = "[t]est [a]ttach.",
            mode = "n",
          },
          {
            "@@ts",
            function()
              neotest.summary.toggle()
            end,
            desc = "[t]est [s]ummary toggle.",
            mode = "n",
          },
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "williamboam/mason.nvim",
      "folke/which-key.nvim",
      "theHamsta/nvim-dap-virtual-text"
    },
    config = function()
      local dap = require("dap")
      local dap_python = require("dap-python")
      local wk = require("which-key")
      local mason= require("mason-registry")
      require("nvim-dap-virtual-text").setup({
        commented = true, -- Show virtual text alongside comment
      })



      -- Python
      local pkg = mason.get_package("debugpy")
      dap_python.test_runner = "pytest"
      dap_python.setup("python3") -- pkg:get_install_path() .. "/debugpy")

      -- Dotnet
      -- See https://aaronbos.dev/posts/debugging-csharp-neovim-nvim-dap
      -- Assumes netcoredbg was installed by mason.
      -- local mason_reg = require("mason-registry")
      -- local netcoredbg = mason_reg.get_package("netcoredbg")
      -- if (!netcoredbg) throw error();

      -- dap.adapters.netcoredbg = {
      --   type = "executable",
      --   command = "/home/adrian/.netcoredbg/netcoredbg",
      --   args = { "--interpreter=vscode" },
      -- }
      -- dap.configurations.cs = {
      --   {
      --     type = "netcoredbg",
      --     name = "NetCoreDBG",
      --     request = "launch",
      --     program = function()
      --       return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
      --     end,
      --   },
      -- }

      -- Stand-alone
      wk.add({
        {
          { "@@D", group = "[D]ebug." },
          {
            "@@Db",
            function()
              dap.toggle_breakpoint()
            end,
            desc = "[D]ebug [b]reakpoint toggle.",
            mode = "n",
          },
          {
            "@@De", ":DapNew<CR>",
            desc="[D]ebug [e]nter.",
            mode="n"
          },
          {
            "@@Dx", ":DapTerminate<CR>",
            desc="[D]ebug e[x]it.",
            mode="n"
          },
          {
            "@@Dn", ":DapStepOver<CR>",
            desc="[D]ebug [n]ext breakpoint.",
            mode="n"
          },
          {
            "@@Ds", ":DapStepInto<CR>",
            desc="[D]ebug [s]tep to next line.",
            mode="n"
          },
          {
            "@@Dc", ":DapContinue<CR>",
            desc = "[D]ebug [c]ontinue.",
            mode = "n",
          },
          {
            "@@Dx", ":DapTerminate<CR>",
            desc = "[D]ebug e[x]it.",
            mode = "n",
          },
          {
            "@@Di",
            ":DapToggleRepl<cr><c-w><c-j>i",
            desc = "[D]ebug [i]nteractive",
            mode = "n",
          },
        },
      })

      -- Integrations with neotest.
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = function()
      local dapui = require("dapui")
      local dap = require("dap")
      local wk = require("which-key")

      dapui.setup{}

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      wk.add({
        {
          { "@@D", group = "[D]ebug." },
          {
            "@@DU", function() dapui.toggle() end,  desc="[D]ebug [U]I toggle."
          }
        }
      })

    end
  },
  {
    "folke/which-key.nvim",
    dependencies = {},
    config = function()
      local wk = require("which-key")
      wk.setup({
        triggers = {
          { "@@", mode = { "n", "v" } },
        },
      })

      wk.add({
        -- Helpful
        {
          { "@@z", group = "[z]sh" },
          { "@@zs", ":split term://zsh<CR>i", desc = "[z]sh [s]plit.", mode = "n" },
          { "@@zv", ":vsplit term://zsh<CR>i", desc = "[z]sh [v]split.", mode = "n" },
          { "@@zo", ":e term://zsh<CR>i", desc = "[z]sh [o]pen.", mode = "n" },
          { "@@ze", ":e ~/.zshrc", desc = "[z]shrc [e]dit.", mode = "n" },
        },
        {
          { "@@w", desc = "[w]indow" },
          {
            { "@@ws", group = "[w]indow [s]plit" },
            { "@@wsh", ":split .<CR>:Telescope oldfiles<CR>", desc = "[s]plit horizontal.", mode = "n" },
            { "@@wsv", ":vsplit .<CR>:Telescope oldfiles<CR>", desc = "[s]plit vertical.", mode = "n" },
          },
          {
            { "@@wm", group = "[w]indow [m]ove" },
            { "@@wml", ":wincmd H<CR>", desc = "[w]indow [m]ove [l]eft.", mode = "n" },
            { "@@wmr", ":wincmd L<CR>", desc = "[w]indow [m]ove [r]ight.", mode = "n" },
            { "@@wmu", ":wincmd K<CR>", desc = "[w]indow [m]ove [u]p.", mode = "n" },
            { "@@wmd", ":wincmd J<CR>", desc = "[w]indow [m]ove [d]own.", mode = "n" },
          },
        },
        {
          { "@@T", group = "[T]ab" },
          { "@@Tn", ":tabnext<cr>", desc = "[T]ab [n]ext.", mode = "n" },
          { "@@Tp", ":tabnext<cr>", desc = "[T]ab [p]revious.", mode = "n" },
          { "@@Tx", ":tabclose<cr>", desc = "[T]ab e[x]it.", mode = "n" },
        },
        {
          { "@@C", group = "[C]olors" },
          {
            "@@Ct",
            function()
              vim.cmd([[
                hi! Normal ctermbg=NONE guibg=NONE
                hi! NonText ctermbg=NONE guibg=NONE
              ]])
            end,
            desc = "[C]olors [t]ransparent bg.",
            mode = "n",
          },
          { "@@Cd", ":set bg=dark<cr>", desc = "[C]olors [d]ark mode.", mode = "n" },
          { "@@Cl", ":set bg=light<cr>", desc = "[C]olors [l]ight mode.", mode = "n" },
        },
      })

      -- https://neovim.io/doc/user/api.html#nvim_set_keymap()
    end,
  },
  {
    "folke/persistence.nvim",
    dependencies = {},
    config = function()
      local persistence = require("persistence")
      local wk = require("which-key")

      persistence.setup()

      wk.add({
        { "@@p", group = "[p]ersistence" },
        {
          "@@pl",
          function()
            persistence.load()
          end,
          desc = "[p]ersistence [l]oad",
          mode = "n",
        },
        {
          "@@pf",

          function()
            persistence.select()
          end,
          desc = "[p]ersistence [f]ind",
          mode = "n",
        },
        {
          "@@pp",
          function()
            persistence.load({ last = true })
          end,
          desc = "[p]ersistence [p]revious",
          mode = "n",
        },
        {
          "@@pS",
          function()
            if persistence.active() then
              vim.print("`persistence` is running.")
            else
              vim.print("`persistence` is not running.")
            end
          end,
          desc = "[p]ersistence [S]tatus",
          mode = "n",
        },
        {
          "@@pe",
          function()
            persistence.start()
          end,
          desc = "[p]ersistence [e]nter.",
          mode = "n",
        },
        {
          "@@ps",
          function()
            persistence.save()
          end,
          desc = "[p]ersistence [s]ave.",
          mode = "n",
        },
        {
          "@@px",
          function()
            persistence.save()
            persistence.stop()
          end,
          desc = "[p]ersistence e[x]it.",
          mode = "n",
        },
      })
    end,
  },
}

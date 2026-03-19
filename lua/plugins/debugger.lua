return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "williamboam/mason.nvim",
      "folke/which-key.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dap_python = require("dap-python")
      local wk = require("which-key")
      local mason = require("mason-registry")
      require("nvim-dap-virtual-text").setup({
        commented = true, -- Show virtual text alongside comment
      })

      -- Python
      local pkg = mason.get_package("debugpy")
      dap_python.test_runner = "pytest"
      dap_python.setup("python3") -- pkg:get_install_path() .. "/debugpy")

      dap.adapters.python = {
        type = "server",
        host = "127.0.0.1",
        port = 5678,
      }

      dap.configurations.python[5] = {
        type = "python",
        request = "attach",
        name = "Attach to Docker",
        connect = {
          host = "127.0.0.1",
          port = 5678,
        },
        mode = "remote",
        justMyCode = false,
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(), -- or the root of your project on the host
            remoteRoot = "/home/docker/app", -- path inside the container
          },
        },
      }

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
            "@@De",
            ":DapNew<CR>",
            desc = "[D]ebug [e]nter.",
            mode = "n",
          },
          {
            "@@Dx",
            ":DapTerminate<CR>",
            desc = "[D]ebug e[x]it.",
            mode = "n",
          },
          {
            "@@Dn",
            ":DapStepOver<CR>",
            desc = "[D]ebug [n]ext breakpoint.",
            mode = "n",
          },
          {
            "@@Ds",
            ":DapStepInto<CR>",
            desc = "[D]ebug [s]tep to next line.",
            mode = "n",
          },
          {
            "@@Dc",
            ":DapContinue<CR>",
            desc = "[D]ebug [c]ontinue.",
            mode = "n",
          },
          {
            "@@Dx",
            ":DapTerminate<CR>",
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
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dapui = require("dapui")
      local dap = require("dap")
      local wk = require("which-key")

      dapui.setup({})

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
            "@@DU",
            function()
              dapui.toggle()
            end,
            desc = "[D]ebug [U]I toggle.",
          },
        },
      })
    end,
  },
}

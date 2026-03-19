return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
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
}

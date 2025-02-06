require("conf.global")
local keymap_helpers = require("conf.keymap")

-- NOTE: These must occur in this specific order since changing the colorscheme
--       cancles out any existing transperency.
require("lazy").setup("plugins", {})

vim.cmd.colorscheme("gruvbox-material")

-- vim.treesitter.language.add(
keymap_helpers.background_transp()

-- NOTE: See ``../../queries/python/highlights.scm
-- https://github.com/morhetz/gruvbox?tab=readme-ov-file
--
vim.api.nvim_set_hl(0, "@comment.python.quarto_metadata", { fg = "#d3869b" })
vim.api.nvim_set_hl(0, "@quarto_in_quarto", { bg = "#7c6f64", fg = "#fbf1c7" })
vim.opt.colorcolumn = "80"

---Tack on extra characters to reach `80` character of background using
---some highlight group.
---
---This is used to fill out the background of the `@quarto_in_quarto` capture.
---
---@param ns number - Namespace number.
---@param bufnr number - Buffer number.
---@param start number - Begining of range.
---@param stop number - end of range.
---
function AddBGVirtualText(ns, bufnr, start, stop)
  -- vim.print("====================")
  -- vim.print(string.format("highlighting for %s to %s", start, stop))

  -- NOTE: The line below keeps lines from accumulating.
  vim.api.nvim_buf_clear_namespace(bufnr, ns, start, stop)

  local lines = vim.api.nvim_buf_get_lines(bufnr, start, stop, false)
  for index, line in ipairs(lines) do
    local line_len = string.len(line)
    local line_remainder = 80 - line_len
    local spacer = string.rep(" ", line_remainder)

    -- vim.print("-------------------")
    -- vim.print("remainder", line_remainder, "length", line_len, "index", index)
    -- vim.print("spacer:", string.len(spacer))

    vim.api.nvim_buf_set_extmark(bufnr, ns, start + index - 1, -1, {
      hl_group = "@quarto_in_quarto",
      virt_text = { { spacer, "@quarto_in_quarto" } }, -- Extend bg
      virt_text_pos = "inline",
    })
  end
end

local function _helper(ns, bufnr, root)
  for node in root:iter_children() do
    if node:type() == "fenced_code_block" then
      -- vim.print("====================")
      local node_info_string = nil
      local node_code_fence_content = nil

      -- NOTE: Look for the info string.
      for child in node:iter_children() do
        local ttt = child:type()
        if ttt == "info_string" then
          node_info_string = child
        end

        if ttt == "code_fence_content" then
          node_code_fence_content = child
        end
      end

      if not node_info_string then
        -- vim.print("No info string for code block")
        return
      end

      if not node_code_fence_content then
        return
      end

      local node_language = nil
      for child in node_info_string:iter_children() do
        if child:type() == "language" then
          node_language = child
        end
      end

      if node_language == nil then
        -- print("No language for code block.")
        return
      end

      local row_start, col_start, _ = node_language:start()
      local row_end, col_end, _ = node_language:end_()

      local lines = vim.api.nvim_buf_get_lines(bufnr, row_start, row_end + 1, false)
      if not lines then
        return
      end

      vim.print(row_start, col_start, row_end, col_end)
      local language = nil
      for index, line in ipairs(lines) do
        vim.print(line)
        language = string.sub(line, col_start + 1, col_end)
        vim.print(language)
      end

      if language ~= "quarto" then
        return
      end

      local start, _, stop, _ = node_code_fence_content:range()
      AddBGVirtualText(ns, bufnr, start, stop)

      -- if node_language ~= "quarto" then
      --   print(node_language:sexpr())
      --   print("language is not quarto.")
      --   return
      -- end

      -- print("-------------------------")
      -- for child in node_language:iter_children() do
      --   print(child:sexpr())
      -- end

      -- NOTE: Look for the language
      -- local node_language = node_info_string:child(0)
      --
      -- vim.print(start, stop, node_language.sexpr())
    else
      _helper(ns, bufnr, node)
    end
  end
end

function AddQuartoInQuartoVirtualText()
  local ns = vim.api.nvim_create_namespace("quarto_code_bg")
  local bufnr = vim.api.nvim_get_current_buf()

  local parser = vim.treesitter.get_parser(bufnr, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()

  _helper(ns, bufnr, root)
end

vim.keymap.set("n", "@@k", AddQuartoInQuartoVirtualText)
vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
  pattern = "*.qmd",
  callback = AddQuartoInQuartoVirtualText,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = "*.qmd",
--   callback = highlight_quarto_code,
-- })

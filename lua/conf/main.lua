require("conf.global")
local keymap_helpers = require("conf.keymap")

-- NOTE: These must occur in this specific order since changing the colorscheme
--       cancles out any existing transperency.
require("lazy").setup("plugins", {})
vim.cmd.colorscheme("gruvbox-material")
keymap_helpers.background_transp()
vim.opt.colorcolumn = "80"

---@alias CodeFenceHLData {language: string, start: number, stop: number, }
---@alias CodeFenceHLOptions {hl_group: string, codefence_language: string, include_delim: boolean, hl: table}

---If a node is a fenced code block, then return the language name if it can
---be determined.
---
---@param bufnr number - Buffer number.
---@param node TSNode -- Treesitter node
---@param options CodeFenceHLOptions
---
---@return CodeFenceHLData?
---
local function get_code_fence_data(bufnr, node, options)
  if node:type() ~= "fenced_code_block" then
    return
  end

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

  local start, stop
  if options.include_delim then
    start, _, stop, _ = node:range()
  else
    start, _, stop, _ = node_code_fence_content:range()
  end

  for _, line in ipairs(lines) do
    return { language = string.sub(line, col_start + 1, col_end), start = start, stop = stop }
  end
end

---Tack on extra characters to reach `80` character of background using
---some highlight group.
---
---This is used to fill out the background of the `@fenced_code_block.quarto` capture.
---
---@param ns number - Namespace number.
---@param bufnr number - Buffer number.
---@param data CodeFenceHLData
---@param options CodeFenceHLOptions
---@return nil
---
local function append_code_fence_virtual_text(ns, bufnr, data, options)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, data.start, data.stop)

  local lines = vim.api.nvim_buf_get_lines(bufnr, data.start, data.stop, false)
  for index, line in ipairs(lines) do
    local line_len = string.len(line)
    local line_remainder = 80 - line_len
    local spacer = string.rep(" ", line_remainder)

    vim.api.nvim_buf_set_extmark(bufnr, ns, data.start + index - 1, -1, {
      hl_group = options.hl_group,
      virt_text = { { spacer, options.hl_group } }, -- Extend bg
      virt_text_pos = "inline",
    })
  end
end

---Recursively look for code fences.
---
---@param ns number - Namespace number.
---@param bufnr number - Buffer number.
---@param root TSNode - Node to inspect.
---@param options CodeFenceHLOptions
---@return nil
---
local function update_code_fence(ns, bufnr, root, options)
  for node in root:iter_children() do
    local code_fence_data = get_code_fence_data(bufnr, node, options)

    if code_fence_data ~= nil then
      -- vim.print(code_fence_data)
      if code_fence_data.language ~= options.codefence_language then
        return
      end

      append_code_fence_virtual_text(ns, bufnr, code_fence_data, options)
    else
      update_code_fence(ns, bufnr, node, options)
    end
  end
end

---Used to make codeblocks look like full pages by adding virual text.
---Otherwise background only appears behind text.
---
---Using `options.include_delim` will require highlighting the entire code fence.
---
---@param options CodeFenceHLOptions
---@return nil
---
local function add_codefence_virtual_text(options)
  local ns = vim.api.nvim_create_namespace("quarto_code_bg")
  local bufnr = vim.api.nvim_get_current_buf()

  local parser = vim.treesitter.get_parser(bufnr, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()

  -- vim.print(options)
  update_code_fence(ns, bufnr, root, options)
end

---@param options CodeFenceHLOptions
---@return nil
local function _codefence(options)
  vim.api.nvim_set_hl(0, options.hl_group, options.hl)
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
    pattern = "*.qmd",
    callback = function()
      return add_codefence_virtual_text(options)
    end,
  })
end

---@param options_list CodeFenceHLOptions[]
local function codefence(options_list)
  for _, options in ipairs(options_list) do
    _codefence(options)
  end
end

-- NOTE: Colors from solarized pallete: https://en.wikipedia.org/wiki/Solarized
vim.api.nvim_set_hl(0, "@comment.python.quarto_metadata", { fg = "#d3869b" })
vim.api.nvim_set_hl(0, "@comment.mermaid.quarto_metadata", { fg = "#d3869b" })
vim.api.nvim_set_hl(0, "@fence", { fg = "#dc322f", italic = true })
codefence({
  {
    codefence_language = "quarto",
    hl_group = "@fenced_code_block.quarto",
    include_delim = true,
    hl = { bg = "#002b36", fg = "#268bd2" },
  },
  {
    codefence_language = "python",
    hl_group = "@fenced_code_block.python",
    include_delim = true,
    hl = { bg = "#073642", fg = "#268bd2" },
  },
  {
    codefence_language = "default",
    hl_group = "@fenced_code_block.default",
    include_delim = true,
    hl = { bg = "#002b36", fg = "#268bd2" },
  },
  {
    codefence_language = "=html",
    hl_group = "@fenced_code_block.html",
    include_delim = true,
    hl = { bg = "#002b36", fg = "#268bd2" },
  },
  {
    hl = { bg = "#002b36", fg = "#268bd2" },
    hl_group = "@fenced_code_block.mermaid",
    include_delim = true,
    codefence_language = "mermaid",
  },
})

return {
  {'sindrets/diffview.nvim'},
  {'nvim-tree/nvim-web-devicons'},
  {
    'NeogitOrg/neogit',
    lazy = true,
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', ':Neogit<cr>', desc = 'neo[g]it' },
    },
    config = function()
      require('neogit').setup {
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
        },
      }
    end,
  },
}

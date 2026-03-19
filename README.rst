Nvim Configuration
===============================================================================

.. _quarto-nvim-kickstarter: https://github.com/jmbuhr/quarto-nvim-kickstarter
.. _quarto:  https://github.com/quarto-dev/quarto-nvim

This was made upon the integration of some pieces from the 
quarto-nvim-kickstarter_ into my existing neovim configuration. I did not want
to use the full configuration since I could learn a little about lua and keep 
certain keybindings, lsp support, colorschemes, etc.


I did this so that I could mess around with quarto_ documents in vim. 


Installation
===============================================================================

The following instructions assume that you have successfully installed a recent
version of nvim. If you want to use this in entirety and want to do nothing 
else do 

.. code:: sh

   # TODO: Test these steps.
   mdkir ~/.config/nvim
   git clone <repo_url> ~/.config/nvim
   echo "source ~/.config/nvim/<repo-name>/init.lua" >> init.lua


Dotnet
===============================================================================

Configuring dotnet to work nicely can be a pain. A few things work very well:

- LSP Omnisharp
- Neotest

A few things are not quite working yet:

- charp.nvim
- xunit.nvim

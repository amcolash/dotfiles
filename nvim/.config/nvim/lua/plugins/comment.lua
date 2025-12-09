return {
  'numToStr/Comment.nvim',
  -- 1. Map '/' in Visual Mode to trigger the comment toggle.
  -- The key is: when '/' is pressed in Visual mode (v), 
  -- it internally switches to Line-Visual mode (V) before executing.
  keys = {
    { '/', mode = 'v', desc = 'Comment toggle entire selected lines', rhs = "V/", noremap = false },
  },
  config = function()
    require('Comment').setup({
      -- 2. Tell Comment.nvim to use the '/' key as its operator leader
      opleader = {
        line = '/',  -- This is the key the plugin watches for
      },
      -- 3. You can set the block leader to a different key if you like, e.g., 'gb'
      -- blockleader = 'gb',
    })

    -- 4. Keep Normal Mode '/' as the search function
    -- We use a raw / to maintain the default search behavior.
    vim.api.nvim_set_keymap('n', '/', '/', { noremap = false, silent = false, desc = 'Forward Search' })

  end,
}

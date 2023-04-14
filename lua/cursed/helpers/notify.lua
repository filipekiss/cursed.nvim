local M = {}

M.notify = function(msg, opts)
  vim.notify(msg, opts.level or vim.log.levels.INFO, {
    title = opts.title or "cursed.nvim",
  })
end

M.warn = function(msg)
	M.notify(msg, { level = vim.log.levels.WARN })
end


return M

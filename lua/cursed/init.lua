local M = {}
local IDLE = "IDLE"
local MOVING = "MOVING"
M.timer_id = nil
M.defaults = {
	delay = vim.o.updatetime,
	ignore_filetype = { "neo-tree", "starter" },
}

local function run_user_autocmd(pattern, opts)
	opts.pattern = pattern
	return vim.api.nvim_exec_autocmds("User", opts)
end

local buffer_table = require("cursed.helpers.table").buffer_table

local Cursed = buffer_table({
	is_ex_mode = "cursed_ex_mode",
	disabled = "cursed_disabled",
	status = "cursed_cursor_status",
})

local function should_activate(status)
	-- if the current buffer matches one of the ignored file types
	if vim.tbl_contains(M.options.ignore_filetype, vim.bo.filetype) then
		return false
	end
	-- if the cursed is disabled for the current buffer
	if Cursed.disabled == true then
		return false
	end

	-- if this is an ex cmd buffer
	if Cursed.is_ex_mode then
		return false
	end

	-- check against the current status
	if status ~= nil and Cursed.status ~= nil then
		-- if status match, activate
		if Cursed.status == status then
			return true
		else
			-- otherwise, don't
			return false
		end
	end

	-- otherwise always activate
	return true
end

local function cursed_callback()
	if not should_activate(MOVING) then
		return
	end
	run_user_autocmd("CursedStop", { modeline = false })
	Cursed.status = IDLE
	M.timer:stop()
	M.timer = nil
end

local function cursor_moved(delay)
	if not should_activate() then
		return
	end

	if M.timer then
		M.timer:stop()
		M.timer:close()
	end

	M.timer = vim.loop.new_timer()
	M.timer:start(delay, delay, vim.schedule_wrap(cursed_callback))
	if should_activate(IDLE) then
		run_user_autocmd("CursedStart", { modeline = false })
		Cursed.status = MOVING
	end
end

local function setup_smart_cursorline()
	local autocmd = vim.api.nvim_create_autocmd
	local augroup = vim.api.nvim_create_augroup

	-- enable cursorline when moving windows
	autocmd({ "WinEnter" }, {
		group = augroup("cursed_smart_cursorline", { clear = true }),
		pattern = "*",
		callback = function()
			if should_activate() then
				vim.wo.cursorline = true
			end
		end,
	})

	-- setup the smart cursorline events
	autocmd("User", {
		group = augroup("cursed_smart_cursorline", { clear = false }),
		pattern = "CursedStart",
		callback = function()
			vim.wo.cursorline = false
		end,
	})

	autocmd("User", {
		group = augroup("cursed_smart_cursorline", { clear = false }),
		pattern = "CursedStop",
		callback = function()
			vim.wo.cursorline = true
		end,
	})
end

function M.setup(opts)
	if vim.g.cursed_loaded then
		return
	end
	vim.g.cursed_loaded = true
	local augroup = vim.api.nvim_create_augroup
	local autocmd = vim.api.nvim_create_autocmd
	M.options = vim.tbl_deep_extend("force", M.defaults, opts)

	autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = augroup("cursed", { clear = true }),
		pattern = { "*" },
		callback = function()
			cursor_moved(M.options.delay)
		end,
	})

	autocmd({ "CmdWinEnter", "CmdWinLeave" }, {
		group = augroup("cursed_cmdmode", { clear = true }),
		pattern = { "*" },
		callback = function(autocommand)
			if autocommand.event == "CmdWinEnter" then
				Cursed.is_ex_mode = true
			else
				Cursed.is_ex_mode = false
			end
		end,
	})

	if opts.smart_cursorline then
		setup_smart_cursorline()
	end
end

return M

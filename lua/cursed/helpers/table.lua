local Notify = require("cursed.helpers.notify")

local M = {}

function M.get_table_keys(t)
	local keys = {}
	for key, _ in pairs(t) do
		table.insert(keys, key)
	end
	return keys
end

function M.buffer_table(it)
	return setmetatable({}, {
		__index = function(_, key)
			if it[key] == nil then
				Notify.warn(
					"attempting to access non-existing key ["
						.. key
						.. "]. Valid keys are ["
						.. table.concat(M.get_table_keys(it), ", ")
						.. "]"
				)
				return nil
			end
			local status_ok, buffer_var_value = pcall(
				vim.api.nvim_buf_get_var,
				0,
				it[key]
			)
			return status_ok and buffer_var_value or nil
		end,
		__newindex = function(_, key, value)
			-- if key is not set, we have no business acessing these variables
			if it[key] == nil then
				Notify.warn(
					"attempting to write to non-existing key ["
						.. key
						.. "]. Valid keys are ["
						.. table.concat(M.get_table_keys(it), ", ")
						.. "]"
				)
				return nil
			end
			vim.api.nvim_buf_set_var(0, it[key], value)
			return value
		end,
	})
end

return M

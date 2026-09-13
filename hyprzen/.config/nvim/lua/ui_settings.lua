local M = {}

local state = require("settings_state")

local function bool_to_text(value)
  return value and "on" or "off"
end

function M.init()
  vim.opt.wrap = state.get("wrap", false)
  vim.opt.spell = state.get("spell", false)

  local group = vim.api.nvim_create_augroup("ui-settings-persist", { clear = true })

  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "wrap",
    callback = function()
      state.set("wrap", vim.opt.wrap:get())
    end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "spell",
    callback = function()
      state.set("spell", vim.opt.spell:get())
    end,
  })
end

function M.toggle_markview_preview()
  local next_value = not state.get("markview_preview", true)
  state.set("markview_preview", next_value)
  vim.cmd("Markview Toggle")
  vim.notify("Markview preview: " .. bool_to_text(next_value), vim.log.levels.INFO)
end

function M.toggle_markview_hybrid()
  local next_value = not state.get("markview_hybrid", true)
  state.set("markview_hybrid", next_value)
  vim.cmd("Markview HybridToggle")
  vim.notify("Markview hybrid: " .. bool_to_text(next_value), vim.log.levels.INFO)
end

return M
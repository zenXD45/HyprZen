local M = {}

local state_file = vim.fn.stdpath("state") .. "/settings_state.json"
local cache = nil

local function read_file(path)
  local fd = vim.uv.fs_open(path, "r", 420)
  if not fd then
    return nil
  end
  local stat = vim.uv.fs_fstat(fd)
  if not stat or stat.size <= 0 then
    vim.uv.fs_close(fd)
    return "{}"
  end
  local data = vim.uv.fs_read(fd, stat.size, 0)
  vim.uv.fs_close(fd)
  return data
end

local function load()
  if cache ~= nil then
    return cache
  end

  local raw = read_file(state_file)
  if not raw or raw == "" then
    cache = {}
    return cache
  end

  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= "table" then
    cache = {}
    return cache
  end

  cache = decoded
  return cache
end

local function persist(data)
  local encoded = vim.json.encode(data)
  vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")

  local fd = vim.uv.fs_open(state_file, "w", 420)
  if not fd then
    return false
  end
  vim.uv.fs_write(fd, encoded, 0)
  vim.uv.fs_close(fd)
  return true
end

function M.get(key, default)
  local data = load()
  local value = data[key]
  if value == nil then
    return default
  end
  return value
end

function M.set(key, value)
  local data = load()
  data[key] = value
  return persist(data)
end

return M
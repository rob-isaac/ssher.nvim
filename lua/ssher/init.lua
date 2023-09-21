local M = {}

M.known_schemes = {"scp", "sftp", "oil-ssh"}

M._prefix_translations = {}

M.get_host_and_port_and_scheme = function (path)
  for _,scheme in ipairs(M.known_schemes) do
    local host, port = string.match(path, "^" .. scheme:gsub("%W", "%%%1") .. "://([^/:]-):(%d-)/")
    if host and port then
      return host, port, scheme
    end
    host = string.match(path, "^" .. scheme .. "://([^/:]-)/")
    if host then
      return host, nil, scheme
    end
  end
end

M.setup = function(user_config)
  M.config = user_config or {}
  M.config.translations = M.config.translations or {}

  -- Hack into uri_from_bufnr, which vim.lsp uses to create RPC requests to the LSP
  local old_uri_from_bufnr = vim.uri_from_bufnr
  vim.uri_from_bufnr = function(bufnr)
    local orig = old_uri_from_bufnr(bufnr)
    for prefix, translation in pairs(M.config.translations) do
      if orig:sub(1,prefix:len()) == prefix then
        local host, port, scheme = M.get_host_and_port_and_scheme(prefix)
        if not host then
          vim.notify("couldn't resolve host for prefix " .. prefix .. ". Removing it...")
          M.config.translations[prefix] = nil
        else
          return translation .. orig:sub(prefix:len()+1)
        end
      end
    end
    return orig
  end

  -- local augroup = vim.api.nvim_create_augroup("ssher_augroup", {clear = true})
  -- for prefix, _ in pairs(M.config.translations) do
  --   vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  --     pattern = {prefix .. ".*"},
  --     callback = function ()
  --
  --     end
  --   })
  -- end
  -- TODO: Setup an autocmd for the remote filetypes that wraps the normal LSP
  -- on-attach functionality to go through ssh instead
end


return M

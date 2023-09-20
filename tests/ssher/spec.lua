local ssher = require("ssher")

describe("get_host_and_port_and_scheme", function()
  it("works with just host", function()
    host, port, scheme = ssher.get_host_and_port_and_scheme("scp://google.com/main.cpp")
    assert.equals("google.com", host)
    assert.equals(nil, port)
    assert.equals("scp", scheme)
  end)
  it("works with host and port", function()
    host, port, scheme = ssher.get_host_and_port_and_scheme("scp://google.com:123/main.cpp")
    assert.equals("google.com", host)
    assert.equals("123", port)
    assert.equals("scp", scheme)
  end)
  it("works with host and port long path", function()
    host, port, scheme = ssher.get_host_and_port_and_scheme("scp://google.com:123/a/long/path/main.cpp")
    assert.equals("google.com", host)
    assert.equals("123", port)
    assert.equals("scp", scheme)
  end)
  it("works with all schemes", function()
    for _,known_scheme in ipairs(ssher.known_schemes) do
      host, port, scheme = ssher.get_host_and_port_and_scheme(known_scheme .. "://google.com:123/a/long/path/main.cpp")
      assert.equals("google.com", host)
      assert.equals("123", port)
      assert.equals(known_scheme, scheme)
    end
  end)
  it("fails with local file uri", function()
    host, port, scheme = ssher.get_host_and_port_and_scheme("file://a/long/path/main.cpp")
    assert.equals(nil, host)
    assert.equals(nil, port)
    assert.equals(nil, scheme)
  end)
  it("fails with no scheme", function()
    host, port, scheme = ssher.get_host_and_port_and_scheme("/a/long/path/main.cpp")
    assert.equals(nil, host)
    assert.equals(nil, port)
    assert.equals(nil, scheme)
  end)
end)

describe("setup hijacks vim.uri_from_bufnr", function ()
  it("doesn't change normal paths", function ()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "path/to/file.cpp")
    local old = vim.uri_from_bufnr
    ssher.setup()
    assert.equal(old(buf), vim.uri_from_bufnr(buf))
  end)
  it("doesn't change file URI", function ()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "file://path/to/file.cpp")
    local old = vim.uri_from_bufnr
    ssher.setup()
    assert.equal(old(buf), vim.uri_from_bufnr(buf))
  end)
end)

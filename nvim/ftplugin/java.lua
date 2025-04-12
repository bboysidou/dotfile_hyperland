local jdtls = require("jdtls")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local home = vim.env.HOME
local keymap = vim.keymap -- for conciseness
local system_os = ""

if vim.fn.has("mac") == 1 then
  system_os = "mac"
elseif vim.fn.has("unix") == 1 then
  system_os = "linux"
elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  system_os = "win"
else
  print("OS not found, defaulting to 'linux'")
  system_os = "linux"
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
capabilities.offsetEncoding = { "utf-16" }

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar",
    "-configuration",
    home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. system_os,
    "-data",
    home .. "/.cache/jdtls_workdir/" .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h:t"),
  },

  root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),
  settings = {
    java = {},
  },

  init_options = {
    bundles = {},
  },
  signatureHelp = { enabled = true },
  contentProvider = { preferred = "fernflower" },
  completion = {
    favoriteStaticMembers = {
      "org.hamcrest.MatcherAssert.assertThat",
      "org.hamcrest.Matchers.*",
      "org.hamcrest.CoreMatchers.*",
      "org.junit.jupiter.api.Assertions.*",
      "java.util.Objects.requireNonNull",
      "java.util.Objects.requireNonNullElse",
      "org.mockito.Mockito.*",
    },
    filteredTypes = {
      "com.sun.*",
      "io.micrometer.shaded.*",
      "java.awt.*",
      "jdk.*",
      "sun.*",
    },
  },
  sources = {
    organizeImports = {
      starThreshold = 9999,
      staticStarThreshold = 9999,
    },
  },
  codeGeneration = {
    toString = {
      template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
    },
    hashCodeEquals = {
      useJava7Objects = true,
    },
    useBlocks = true,
  },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local opts = { silent = true, buffer = bufnr }
    opts.desc = "Show LSP definitions"
    keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

    keymap.set("n", "<A-o>", jdtls.organize_imports, opts)
    keymap.set("n", "<leader>df", jdtls.test_class, opts)
    keymap.set("n", "<leader>dn", jdtls.test_nearest_method, opts)
    keymap.set("n", "crv", jdtls.extract_variable, opts)
    keymap.set("v", "crm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)
    keymap.set("n", "crc", jdtls.extract_constant, opts)
  end,
}
jdtls.start_or_attach(config)

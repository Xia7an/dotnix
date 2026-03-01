-- LSP configuration
local lspconfig = require('lspconfig')

-- Neodev must be setup before lspconfig
require('neodev').setup()

-- Setup mason
require('mason').setup({
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require('mason-lspconfig').setup({
  ensure_installed = {},
  automatic_installation = false,
})

-- Global LSP settings
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  severity_sort = true,
  signs = true,
  float = {
    border = "rounded",
  },
})

-- LSP keymaps
local on_attach = function(client, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map('n', 'gd', vim.lsp.buf.definition, 'Goto Definition')
  map('n', 'gr', vim.lsp.buf.references, 'Goto References')
  map('n', 'gI', vim.lsp.buf.implementation, 'Goto Implementation')
  map('n', 'gy', vim.lsp.buf.type_definition, 'Goto Type Definition')
  map('n', 'gD', vim.lsp.buf.declaration, 'Goto Declaration')
  map('n', 'K', vim.lsp.buf.hover, 'Hover')
  map('n', 'gK', vim.lsp.buf.signature_help, 'Signature Help')
  map('i', '<c-k>', vim.lsp.buf.signature_help, 'Signature Help')
  map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  map('n', '<leader>cr', vim.lsp.buf.rename, 'Rename')
  map('n', '<leader>cf', function() vim.lsp.buf.format({ async = true }) end, 'Format')
  map('n', '<leader>cd', vim.diagnostic.open_float, 'Line Diagnostics')
  map('n', ']d', vim.diagnostic.goto_next, 'Next Diagnostic')
  map('n', '[d', vim.diagnostic.goto_prev, 'Prev Diagnostic')
  
  -- Highlight symbol under cursor
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = "lsp_document_highlight" })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

-- Setup capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Lua LSP
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' }
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      },
    }
  }
})

-- Nix LSP
lspconfig.nil_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixpkgs-fmt" },
      },
    },
  },
})


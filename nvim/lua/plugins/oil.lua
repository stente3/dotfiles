return {
  "stevearc/oil.nvim",
  opts = {}, -- Configuración opcional para oil.nvim
  dependencies = { "echasnovski/mini.icons" }, -- Dependencia opcional
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" }, -- Mapeo de teclas
  },
}

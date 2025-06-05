return {
  "ThePrimeagen/harpoon",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    -- Configuración de Harpoon
    require("harpoon").setup({
      menu = {
        width = 60, -- Ancho del menú de Harpoon
      },
    })
  end,
  keys = (function()
    local keys = {
      -- Añadir un archivo actual a Harpoon
      {
        "<leader>a",
        function()
          require("harpoon.mark").add_file()
          vim.notify("Archivo añadido a Harpoon")
        end,
        desc = "Añadir archivo a Harpoon",
      },

      -- Abrir la interfaz de usuario de Harpoon
      {
        "<leader>m",
        function()
          require("harpoon.ui").toggle_quick_menu()
          vim.notify("Menú de Harpoon abierto")
        end,
        desc = "Abrir menú de Harpoon",
      },

      -- Navegar al archivo siguiente en Harpoon
      {
        "<leader>l",
        function()
          require("harpoon.ui").nav_next()
          vim.notify("Navegando al archivo siguiente en Harpoon")
        end,
        desc = "Archivo siguiente",
      },

      -- Navegar al archivo anterior en Harpoon
      {
        "<leader>h",
        function()
          require("harpoon.ui").nav_prev()
          vim.notify("Navegando al archivo anterior en Harpoon")
        end,
        desc = "Archivo anterior",
      },
    }

    -- Añadir navegación dinámica para <leader>1 a <leader>9
    for i = 1, 9 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon.ui").nav_file(i)
        end,
        desc = "Navegar al archivo " .. i,
      })
    end

    return keys
  end)(),
}

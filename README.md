> Translate this file into your native language using `Google Translate` or a [similar service](https://immersivetranslate.com).

# CSSVarHighlight

Este plugin para **Neovim** es una herramienta que te ayudará a identificar los colores definidos en las variables CSS de tus archivos de estilo. El plugin analizará una hoja de estilo específica, como `main.css` o `style.css`, que debe contener todas las variables CSS necesarias. Cuando el plugin detecta un color en una variable CSS, resalta su aparición, lo que facilita su visualización desde otros archivos.

## 🗒️ Requerimientos

* [`Neovim`](https://github.com/neovim/neovim): Versión 0.7 o superior.
* [`Mini.hipatterns`](https://github.com/echasnovski/mini.hipatterns): El resaltador de colores.

### Instalación

Usando [`folke/lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
    'farias-hecdin/CSSVarHighlight',
    ft = "css",
    dependencies = {"echasnovski/mini.hipatterns"},
    config = true,
    -- If you want to configure some options, replace the previous line with:
    -- config = function()
    -- end,
}
```

Posteriormente, en la configuración del plugin `mini.hipatterns`:

```lua
local hipatterns = require("mini.hipatterns")

hipatterns.setup({
    -- Your other settings...
    highlighters = {
        -- Your other settings...
        css_variables = require("CSSVarHighlight").get_settings()
    }
})
```

## 🗒️ Configuración

Estas son las opciones de configuración predeterminadas:

```lua
require('CSSVarHighlight').setup({
  -- <number> Parent search limit (number of levels to search upwards)
  parent_search_limit = 5,
  -- <string> Name of the file to track (e.g. "main" for main.lua)
  filename_to_track = "main",
  -- <string> Pattern to search for variables containing "color"
  variable_pattern = "%-%-[-_%w]*color[-_%w]*",
  -- <string> Initial color for variables (in hexadecimal format, e.g. "#000000" for black)
  initial_variable_color = "#000000",
  -- <boolean> Indicates whether keymaps are disabled
  disable_keymaps = false,
})
```

### Comandos y atajos de teclado

| Comandos           | Atajos de teclado | Descripción                         |
| -------------------|------------------ | ----------------------------------- |
| `CSSVarHighlight`  | `<leader>ch`      | Activa el plugin y/o actualiza el resaltado de colores |

> Si deseas desactivar los atajos de teclado predeterminados, puedes establecer la opción  `disable_keymaps` en `true`.

Puedes ampliar la búsqueda de archivos hacia un directorio específico o analizar otro archivo utilizando el comando `:CSSVarHighlight`.

<details>
<summary>Más información:</summary>

* Para buscar hacia arriba, utiliza la sintaxis `:CSSVarHighlight <filename> <attempt_limit>`, donde `<attempt_limit>` es el número de niveles que deseas buscar hacia arriba, comenzando desde el directorio actual, y `<filename>` es el nombre del archivo (sin incluir la extensión `*.css`). El plugin analizará cada nivel hasta encontrar el archivo deseado. Por ejemplo:

```sh
#-- Good
:CSSVarHighlight my_stylesheet 9

#-- Bad
:CSSVarHighlight my_stylesheet.css 9
:CSSVarHighlight "my_stylesheet.css" 9
```

* Para buscar en un directorio específico, utiliza la sintaxis `:CSSVarHighlight <filename> <path>`, donde `<path>` es la ruta del directorio en el que deseas realizar la búsqueda. Por ejemplo:

```sh
#-- Good
:CSSVarHighlight my_Stylesheet file/path/to/search
:CSSVarHighlight my_Stylesheet ../../file/path/to/search

#-- Bad
:CSSVarHighlight "my_Stylesheet" "file/path/to/search"
:CSSVarHighlight "my_Stylesheet" "file/path/to/search.css"
```

</details>

## 🛡️ Licencia

CSSVarHighlight está bajo la licencia MIT. Consulta el archivo `LICENSE` para obtener más información.

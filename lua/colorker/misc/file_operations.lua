local M = {}

-- Buscar el archivo "*.css" en el directorios actual y superiores.
M.find_file = function(filename, directory, attempt, limit)
  if not attempt or attempt > limit then
    vim.print("[Colorker.nvim] Attempt limit reached. Operation cancelled.")
    return
  end

  directory = directory or "."
  local command = "ls -1 " ..directory
  local result = {}

  local handle = io.popen(command)
  if not handle then
    return false
  end

  for file in handle:lines() do
    if file == filename then
      return directory .. filename
    end
    table.insert(result, file)
  end
  handle:close()

  directory = ""
  for i = 1, attempt do
    directory = directory .. "../"
  end

  return M.find_file(filename, directory, attempt + 1, limit)
end

-- Abrir un archivo y retornar su contenido.
M.open_file = function(filename, variable_pattern, color_pattern)
  local data = {}
  local file = assert(io.open(filename, "r"), "[Colorker.nvim] Error: Could not open file " .. filename)

  for line in file:lines() do
    local variable = string.match(line, variable_pattern)
    if variable then
      for _, pattern in pairs(color_pattern) do
        local color = string.match(line, pattern)
        if color then
          data[variable] = color
          break
        end
      end
    end
  end

  file:close()
  return data
end

return M

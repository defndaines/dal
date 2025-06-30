-- Get the file size without changing its current position.
function fsize (file)
  local current = file:seek()
  local size = file:seek("end")
  file:seek("set", current)
  return size
end

local syl = {}

function syl.get_os()
  return package.config:sub(1, 1) == "\\" and "win" or "unix"
end

function syl.is_windows()
  return package.config:sub(1, 1) == "\\"
end

function syl.is_unix()
  return package.config:sub(1, 1) == "/"
end

function syl.path_exists(path)
  local ok, err = os.rename(path, path)
  if ok then
    return true
  else
    return false, err
  end
end

function syl.escape_path(path)
  if syl.is_windows() then
    return '"' .. path:gsub('"', "") .. '"'
  else
    return '"' .. path:gsub('"', '\\"') .. '"'
  end
end

function syl.create_file(path)
  local f, err = io.open(path, "w")
  if f then
    f:close()
    return true
  else
    return false, err
  end
end

function syl.create_dir(path)
  local command = string.format('mkdir -p "%s"', syl.escape_path(path))

  local ok, _, code = os.execute(command)
  if ok then
    return true
  else
    return false, code
  end
end

return syl

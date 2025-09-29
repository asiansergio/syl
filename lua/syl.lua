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

function syl.path_exists(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
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
  if syl.path_exists(path) then
    return true
  end

  local mkdir_cmd
  if syl.is_windows() then
    mkdir_cmd = "mkdir " .. syl.escape_path(path)
  else
    mkdir_cmd = "mkdir -p " .. syl.escape_path(path)
  end

  local ok, _, code = os.execute(mkdir_cmd)
  if ok then
    return true
  else
    return false, code
  end
end

return syl

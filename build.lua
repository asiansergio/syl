#!/usr/bin/env lua

local function is_windows()
    return package.config:sub(1,1) == '\\'
end

local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function directory_exists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then -- Permission denied, but it exists
            return true
        end
    end
    return ok
end

local function find_c_files(dir)
    local files = {}
    local cmd

    if is_windows() then
        cmd = 'dir "' .. dir .. '\\*.c" /b 2>nul'
    else
        cmd = 'find "' .. dir .. '" -name "*.c" -type f 2>/dev/null'
    end

    local handle = io.popen(cmd)
    if handle then
        for line in handle:lines() do
            if is_windows() then
                table.insert(files, dir .. '\\' .. line)
            else
                table.insert(files, line)
            end
        end
        handle:close()
    end

    return files
end

local function get_compiler()
    if is_windows() then
        -- Try cl first, then gcc
        local handle = io.popen("cl 2>nul")
        if handle then
            handle:close()
            return "cl"
        end

        handle = io.popen("gcc --version 2>nul")
        if handle then
            handle:close()
            return "gcc"
        end

        return nil
    else
        -- Try gcc first, then clang
        local handle = io.popen("gcc --version 2>/dev/null")
        if handle then
            handle:close()
            return "gcc"
        end

        handle = io.popen("clang --version 2>/dev/null")
        if handle then
            handle:close()
            return "clang"
        end

        return nil
    end
end

local function create_build_dir()
    if not directory_exists("build") then
        local cmd = is_windows() and "mkdir build" or "mkdir -p build"
        os.execute(cmd)
    end
end

local function get_modules()
    local modules = {}
    local cmd

    if is_windows() then
        cmd = 'dir modules /ad /b 2>nul'
    else
        cmd = 'ls -1 modules 2>/dev/null'
    end

    local handle = io.popen(cmd)
    if handle then
        for line in handle:lines() do
            table.insert(modules, line)
        end
        handle:close()
    end

    return modules
end

local function build_module(module_name)
    local module_dir = "modules/" .. module_name

    -- Check if module directory exists
    if not directory_exists(module_dir) then
        print("Error: Module '" .. module_name .. "' not found in modules/")
        return false
    end

    -- Find C files in the module
    local c_files = find_c_files(module_dir)
    if #c_files == 0 then
        print("Warning: No .c files found in " .. module_dir .. ", skipping...")
        return true  -- Not an error, just skip
    end

    -- Get compiler
    local compiler = get_compiler()
    if not compiler then
        print("Error: No suitable compiler found (tried cl, gcc, clang)")
        return false
    end

    -- Create build directory
    create_build_dir()

    print("Building module '" .. module_name .. "' with " .. compiler .. "...")

    -- Build command
    local cmd
    local output_name = "build/test_" .. module_name

    if compiler == "cl" then
        -- MSVC - redirect obj files to build dir
        output_name = output_name .. ".exe"
        cmd = "cl /Fe:" .. output_name .. " /Fo:build/ " .. table.concat(c_files, " ")
    else
        -- GCC/Clang - compile in build directory
        if is_windows() then
            output_name = output_name .. ".exe"
        end
        -- Change to build dir and compile there to keep obj files contained
        local file_args = table.concat(c_files, " ")
        -- Convert relative paths to absolute from build dir perspective
        local abs_files = {}
        for _, file in ipairs(c_files) do
            table.insert(abs_files, "../" .. file)
        end
        cmd = "cd build && " .. compiler .. " -o " .. string.match(output_name, "build/(.+)") .. " " .. table.concat(abs_files, " ")
    end

    print("Running: " .. cmd)
    local result = os.execute(cmd)

    if result == 0 or result == true then
        print("Build successful: " .. output_name)
        return true
    else
        print("Build failed for module: " .. module_name)
        return false
    end
end

local function build_all_modules()
    local modules = get_modules()
    if #modules == 0 then
        print("No modules found in modules/")
        return false
    end

    print("Building all modules...")
    local success_count = 0
    local total_count = 0

    for _, module in ipairs(modules) do
        total_count = total_count + 1
        if build_module(module) then
            success_count = success_count + 1
        end
        print("") -- Empty line between modules
    end

    print("Build summary: " .. success_count .. "/" .. total_count .. " modules built successfully")
    return success_count == total_count
end

-- Main
local module_name = arg and arg[1]

if not module_name then
    -- Build all modules if no argument provided
    local success = build_all_modules()
    os.exit(success and 0 or 1)
else
    -- Build specific module
    local success = build_module(module_name)
    os.exit(success and 0 or 1)
end
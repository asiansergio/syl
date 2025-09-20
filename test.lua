#!/usr/bin/env lua

local function is_windows()
	return package.config:sub(1, 1) == "\\"
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

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function find_executables()
	local executables = {}
	local cmd

	if is_windows() then
		cmd = "dir build\\*.exe /b 2>nul"
	else
		cmd = 'find build -type f -executable -name "test_*" 2>/dev/null'
	end

	local handle = io.popen(cmd)
	if handle then
		for line in handle:lines() do
			if is_windows() then
				-- line is just filename, add build/ prefix
				table.insert(executables, "build\\" .. line)
			else
				-- line is full path from find
				table.insert(executables, line)
			end
		end
		handle:close()
	end

	return executables
end

local function run_executable(exe_path)
	print("\nRunning: " .. exe_path)
	local cmd = is_windows() and exe_path or "./" .. exe_path
	local result = os.execute(cmd)

	if result == 0 or result == true then
		print("✓ Test passed: " .. exe_path)
		return true
	else
		print("✗ Test failed: " .. exe_path)
		return false
	end
end

local function run_all_tests()
	if not directory_exists("build") then
		print("Build directory not found. Running build first...")
		local build_result = os.execute("lua build.lua")
		if not (build_result == 0 or build_result == true) then
			print("Build failed, cannot run tests")
			return false
		end
	end

	local executables = find_executables()
	if #executables == 0 then
		print("No test executables found in build/")
		print("Try running: lua build.lua")
		return false
	end

	print("\nRunning all tests...")
	local success_count = 0
	local total_count = #executables

	for _, exe in ipairs(executables) do
		if run_executable(exe) then
			success_count = success_count + 1
		end
		print("") -- Empty line between tests
	end

	print("Test summary: " .. success_count .. "/" .. total_count .. " tests passed")
	return success_count == total_count
end

local function run_module_test(module_name)
	local exe_name = "test_" .. module_name
	local exe_path

	if is_windows() then
		exe_path = "build\\" .. exe_name .. ".exe"
	else
		exe_path = "build/" .. exe_name
	end

	-- Check if executable exists
	if not file_exists(exe_path) then
		print("Executable not found: " .. exe_path)
		print("Building module '" .. module_name .. "' first...")

		local build_result = os.execute("lua build.lua " .. module_name)
		if not (build_result == 0 or build_result == true) then
			print("Build failed for module: " .. module_name)
			return false
		end

		-- Check again after build
		if not file_exists(exe_path) then
			print("Build completed but executable still not found: " .. exe_path)
			return false
		end
	end

	return run_executable(exe_path)
end

-- Main
local module_name = arg and arg[1]

if not module_name then
	-- Run all tests if no argument provided
	local success = run_all_tests()
	os.exit(success and 0 or 1)
else
	-- Run specific module test
	local success = run_module_test(module_name)
	os.exit(success and 0 or 1)
end

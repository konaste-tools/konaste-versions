-- Set the executable name
local exeName = "sv6c.exe"

-- Configuration
local moduleName = "sv6c.exe"
local knownBytes = "00 00 00 00 00 00 00 00 14 00 00 00 0A 00 00 00 14 00 00 00 ?? 00 00 00"
local pointerOffsets = {  }
local finalOffset = -0x14

-- Store results
local foundAddresses = {}

-- Attempt to open the process
if openProcess(exeName) then
  print("Successfully opened process: " .. exeName)
else
  print("Failed to open process: " .. exeName)
end

-- Step 2: Scan for byte pattern
local function scanForKnownBytes()
  foundAddresses = {}
  local scan = AOBScan(knownBytes, "*X*C+W") -- scan all memory regions
  if scan then
    for i = 0, scan.Count - 1 do
      local address = tonumber(scan[i], 16)
      if finalOffset and finalOffset ~= 0 then
        address = address - finalOffset
      end
      table.insert(foundAddresses, address)
    end
    scan.destroy()
    print("Found " .. #foundAddresses .. " matches after applying offset.")
  else
    print("No matches found for: " .. knownBytes)
  end
end
scanForKnownBytes()

for _, addr in ipairs(foundAddresses) do
  print(string.format("0x%X", addr))
end

local moduleBase = getAddress(moduleName)
local moduleSize = getModuleSize(moduleName)
print("Target module " .. moduleName .. string.format(" 0x%X-0x%X", moduleBase, moduleBase+moduleSize))

local function findPointersTo(targetAddress)
  local matches = {}
  local memRegions = enumMemoryRegions()
  for _, region in ipairs(memRegions) do
    for addr = region.BaseAddress, region.BaseAddress + region.RegionSize - 4, 4 do
      if isReadable(addr) then
        local val = readInteger(addr)
        if val == targetAddress then
          table.insert(matches, addr)
        end
      end
    end
  end

  return matches
end

local function reverseWalk(startAddresses, offsets)
  local current = startAddresses

  for i, offset in ipairs(offsets) do
    local nextLevel = {}

    for _, addr in ipairs(current) do
      local matches = findPointersTo(addr)
      for _, m in ipairs(matches) do
        table.insert(nextLevel, m+offset)
      end

      -- Option B: Something points to a pointer whose value == (addr - offset)
      local middleMatches = findPointersTo(nil)  -- find pointers to anything
      for _, mid in ipairs(middleMatches) do
        if isReadable(mid) then
          local midval = readInteger(mid)
          if midval and isReadable(midval) then
            local deepval = readInteger(midval)
            if deepval == adjusted then
              table.insert(nextLevel, mid)
            end
          end
        end
      end
    end

    current = nextLevel
    print(string.format("After offset 0x%X: %d candidates", offset, #current))

    if #current == 0 then
      break
    end
  end

  return current
end
local finalCandidates = reverseWalk(foundAddresses, pointerOffsets)

for i, candidate in ipairs(finalCandidates) do
  if moduleBase <= candidate and candidate <= moduleBase+moduleSize then
    print(string.format("%s+0x%X", moduleName, candidate-moduleBase))
  else
    for addr = moduleBase, moduleBase + moduleSize - 4, 4 do
      local val = readInteger(addr)
      if  val == candidate then
        print(string.format("%s+0x%X", moduleName, addr-moduleBase))
      end
    end
  end
end
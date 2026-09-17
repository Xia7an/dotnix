-- Run inside Hammerspoon (with hs.ipc temporarily loaded):
-- hs -c 'dofile("/absolute/path/to/tests/aerospace-window-grid-memory.lua")'
-- Then: hs -c 'print(hs.inspect(gridMemoryCheck))'
-- Real native timers/images, synthetic windows, no input injection or focus changes.
local real = hs
local check = { samples = {}, cycles = 0, snapshots = 0 }
gridMemoryCheck = check
local images, timers = setmetatable({}, { __mode = "k" }), setmetatable({}, { __mode = "k" })
local pending, input = {}, nil
local proxy = setmetatable({}, { __index = real })
proxy.timer = setmetatable({ doAfter = function(delay, fn)
    local t = real.timer.doAfter(delay, fn)
    timers[t] = true
    return t
end }, { __index = real.timer })
local seed = assert(real.image.imageFromName("NSApplicationIcon"))
proxy.screenRecordingState = function() return true end
proxy.window = {
    focusedWindow = function() return nil end,
    snapshotForID = function()
        local img = seed:bitmapRepresentation({ w = 1024, h = 1024 })
        images[img] = true
        check.snapshots = check.snapshots + 1
        return img
    end,
}
proxy.task = { new = function(_, callback)
    local t = { callback = callback }
    function t:start() pending[#pending + 1] = self; return self end
    function t:terminate() end
    function t:setCallback(fn) self.callback = fn; return self end
    return t
end }
proxy.canvas = { new = function()
    local canvas = {}
    for _, method in ipairs({ "level", "behaviorAsLabels", "replaceElements", "show", "delete" }) do
        canvas[method] = function(self) return self end
    end
    return canvas
end }
-- Optional integration mode exercises real CLI tasks, window snapshots and
-- native canvas elements. The canvas stays hidden; no screenshots are saved.
if GRID_MEMORY_NATIVE then
    proxy.task = real.task
    proxy.window = setmetatable({ snapshotForID = function(id)
        local img = real.window.snapshotForID(id)
        if img then images[img] = true; check.snapshots = check.snapshots + 1 end
        return img
    end }, { __index = real.window })
    proxy.screenRecordingState = real.screenRecordingState
    proxy.canvas = { new = function(frame)
        local native = real.canvas.new(frame)
        local wrapper = {}
        for _, method in ipairs({ "level", "behaviorAsLabels", "replaceElements" }) do
            wrapper[method] = function(self, ...) native[method](native, ...); return self end
        end
        function wrapper:show() return self end
        function wrapper:delete() native:delete(); native = nil end
        return wrapper
    end }
end
proxy.eventtap = setmetatable({
    new = function(_, callback)
        input = callback
        return { start = function(self) return self end, stop = function() end,
            isEnabled = function() return true end }
    end,
    checkKeyboardModifiers = function() return { alt = true } end,
    isSecureInputEnabled = function() return false end,
}, { __index = real.eventtap })
local source = GRID_MEMORY_MODULE or hs.configdir .. "/aerospace-window-grid.lua"
local module = assert(loadfile(source, "t", setmetatable({ hs = proxy }, { __index = _G })))()
local controller = module.start()
local function event(kind, key)
    input({ getType = function() return real.eventtap.event.types[kind] end,
        getKeyCode = function() return real.keycodes.map[key] end,
        getFlags = function() return { alt = true } end })
end
local function count(t) local n = 0; for _ in pairs(t) do n = n + 1 end; return n end
local opened, held = false, 0
check.runner = real.timer.doEvery(0.05, function()
    if not opened then
        event("keyDown", "tab")
        local jobs = pending
        pending = {}
        for _, job in ipairs(jobs) do
            if job.callback then job.callback(0, real.json.encode({
                { ["window-id"] = 1, ["app-name"] = "Fixture", ["window-title"] = "Memory test", workspace = "1" },
            }), "") end
        end
        opened = true
        held = 0
    else
        held = held + 1
        if held < (GRID_MEMORY_HOLD_TICKS or 1) then return end
        event("keyDown", "escape"); event("keyUp", "escape"); event("keyUp", "tab")
        opened = false
        check.cycles = check.cycles + 1
        collectgarbage("collect"); collectgarbage("collect")
        if check.cycles % 10 == 0 then
            check.samples[#check.samples + 1] = {
                cycles = check.cycles, retainedImages = count(images), retainedTimers = count(timers),
                luaKB = math.floor(collectgarbage("count")),
            }
        end
        if check.cycles >= (GRID_MEMORY_CYCLES or 20) then
            check.runner:stop(); check.runner = nil
            controller.stop(); controller = nil; input = nil
            collectgarbage("collect"); collectgarbage("collect")
            check.retainedImages, check.retainedTimers = count(images), count(timers)
            check.passed = check.retainedImages == 0 and check.retainedTimers == 0 and check.snapshots > 0
            check.done = true
        end
    end
end)

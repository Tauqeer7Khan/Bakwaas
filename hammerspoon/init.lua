-- ============================================
-- Bakwaas Dictation Engine - Hammerspoon Config
-- Wispr Flow-style Fn key + Floating Pill UI
-- ============================================

local projectPath = os.getenv("HOME") .. "/Documents/Projects/BAKWAAS"
local pythonBin = projectPath .. "/venv/bin/python3"
local bakwaasScript = projectPath .. "/bakwaas.py"
local stopFile = projectPath .. "/.stop_bakwaas"

local isRecording = false
local isContinuousMode = false
local fnIsDown = false
local lastFnTapTime = 0
local doubleTapThreshold = 0.3
local holdThreshold = 0.3
local fnDownTimer = nil
local recordingTask = nil

-- ============================================
-- FLOATING PILL UI (Phase 5.5)
-- Wispr-style visual indicator
-- ============================================

local pill = nil
local PILL_W = 260
local PILL_H = 44
local PILL_RADIUS = 22
local PILL_MARGIN_BOTTOM = 60
local WAVE_BAR_COUNT = 16
local WAVE_BAR_W = 4
local WAVE_BAR_GAP = 4
local SPINNER_FRAMES = {"⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"}

-- Canvas element indices
local ELEM_DOT = 2
local ELEM_WAVE_START = 3
local ELEM_TEXT = 3 + WAVE_BAR_COUNT  -- 19

local pillAnimTimer = nil
local pillHideTimer = nil
local pillState = "idle"
local waveBarXPositions = {}

local function pillBuild()
    local screen = hs.screen.mainScreen()
    local frame = screen:fullFrame()
    local x = frame.x + (frame.w - PILL_W) / 2
    local y = frame.y + frame.h - PILL_H - PILL_MARGIN_BOTTOM

    local c = hs.canvas.new({x=x, y=y, w=PILL_W, h=PILL_H})
    c:level(hs.drawing.windowLevels.floating)
    c:clickActivating(false)
    c:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

    -- [1] Background pill
    c:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = {red=0.1, green=0.1, blue=0.1, alpha=0.92},
        roundedRectRadii = {xRadius=PILL_RADIUS, yRadius=PILL_RADIUS},
        frame = {x=0, y=0, w=PILL_W, h=PILL_H},
    })

    -- [2] Indicator dot (hold / done / error)
    c:appendElements({
        type = "circle",
        action = "fill",
        fillColor = {red=1, green=0.25, blue=0.25, alpha=1},
        radius = 6,
        center = {x=24, y=PILL_H/2},
    })

    -- [3..18] Wave bars (continuous mode)
    local waveTotalW = WAVE_BAR_COUNT * WAVE_BAR_W + (WAVE_BAR_COUNT - 1) * WAVE_BAR_GAP
    local waveStartX = (PILL_W - waveTotalW) / 2
    for i = 1, WAVE_BAR_COUNT do
        local bx = waveStartX + (i - 1) * (WAVE_BAR_W + WAVE_BAR_GAP)
        waveBarXPositions[i] = bx
        c:appendElements({
            type = "rectangle",
            action = "skip",
            fillColor = {red=1, green=0.35, blue=0.35, alpha=0.9},
            roundedRectRadii = {xRadius=2, yRadius=2},
            frame = {x=bx, y=PILL_H/2 - 4, w=WAVE_BAR_W, h=8},
        })
    end

    -- [19] Status text
    c:appendElements({
        type = "text",
        text = hs.styledtext.new("", {
            font = {name="SF Pro Rounded", size=14},
            color = {red=1, green=1, blue=1, alpha=1},
        }),
        frame = {x=40, y=0, w=PILL_W - 56, h=PILL_H},
        textAlignment = "left",
        textVerticalAlignment = "center",
    })

    c:alpha(0)
    c:show()
    return c
end

local function pillStopAnims()
    if pillAnimTimer then pillAnimTimer:stop(); pillAnimTimer = nil end
    if pillHideTimer then pillHideTimer:stop(); pillHideTimer = nil end
end

local function pillSetState(state)
    if not pill then return end
    pillStopAnims()
    pillState = state

    -- ---- HOLD-TO-TALK: Red pulsing dot + "Listening..." ----
    if state == "listening_hold" then
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=1, green=0.25, blue=0.25, alpha=1}
        pill[ELEM_DOT].radius = 6
        for i = 1, WAVE_BAR_COUNT do
            pill[ELEM_WAVE_START + i - 1].action = "skip"
        end
        pill[ELEM_TEXT].text = hs.styledtext.new("Listening...", {
            font = {name="SF Pro Rounded", size=14},
            color = {red=1, green=1, blue=1, alpha=1},
        })
        pill[ELEM_TEXT].frame = {x=40, y=0, w=PILL_W-56, h=PILL_H}
        pill[ELEM_TEXT].textAlignment = "left"
        pill:alpha(1)

        local phase = 0
        pillAnimTimer = hs.timer.doEvery(0.05, function()
            if pillState ~= "listening_hold" then return end
            phase = phase + 0.1
            local s = 0.5 + 0.5 * math.abs(math.sin(phase))
            pill[ELEM_DOT].radius = 4 + 4 * s
            pill[ELEM_DOT].fillColor = {red=1, green=0.25, blue=0.25, alpha=0.4 + 0.6*s}
        end)

    -- ---- CONTINUOUS: Animated wave bars only ----
    elseif state == "listening_continuous" then
        pill[ELEM_DOT].action = "skip"
        for i = 1, WAVE_BAR_COUNT do
            pill[ELEM_WAVE_START + i - 1].action = "fill"
            pill[ELEM_WAVE_START + i - 1].fillColor = {red=1, green=0.35, blue=0.35, alpha=0.9}
        end
        pill[ELEM_TEXT].text = hs.styledtext.new("", {
            font = {name="SF Pro Rounded", size=14},
            color = {red=1, green=1, blue=1, alpha=0},
        })
        pill:alpha(1)

        local phase = 0
        pillAnimTimer = hs.timer.doEvery(0.04, function()
            if pillState ~= "listening_continuous" then return end
            phase = phase + 0.15
            for i = 1, WAVE_BAR_COUNT do
                local h = 6 + 18 * math.abs(math.sin(phase + i * 0.5))
                local barY = (PILL_H - h) / 2
                pill[ELEM_WAVE_START + i - 1].frame = {
                    x = waveBarXPositions[i], y = barY, w = WAVE_BAR_W, h = h
                }
            end
        end)

    -- ---- PROCESSING: Spinner + "Transcribing..." ----
    elseif state == "processing" then
        pill[ELEM_DOT].action = "skip"
        for i = 1, WAVE_BAR_COUNT do
            pill[ELEM_WAVE_START + i - 1].action = "skip"
        end
        pill[ELEM_TEXT].frame = {x=0, y=0, w=PILL_W, h=PILL_H}
        pill[ELEM_TEXT].textAlignment = "center"
        pill[ELEM_TEXT].text = hs.styledtext.new("⠋  Transcribing...", {
            font = {name="SF Pro Rounded", size=14},
            color = {red=1, green=0.85, blue=0.3, alpha=1},
        })
        pill:alpha(1)

        local idx = 1
        pillAnimTimer = hs.timer.doEvery(0.08, function()
            if pillState ~= "processing" then return end
            idx = (idx % #SPINNER_FRAMES) + 1
            pill[ELEM_TEXT].text = hs.styledtext.new(SPINNER_FRAMES[idx] .. "  Transcribing...", {
                font = {name="SF Pro Rounded", size=14},
                color = {red=1, green=0.85, blue=0.3, alpha=1},
            })
        end)

    -- ---- DONE: Green dot + "Done!" → 1.5s fade ----
    elseif state == "done" then
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=0.2, green=0.9, blue=0.3, alpha=1}
        pill[ELEM_DOT].radius = 6
        for i = 1, WAVE_BAR_COUNT do
            pill[ELEM_WAVE_START + i - 1].action = "skip"
        end
        pill[ELEM_TEXT].text = hs.styledtext.new("Done!", {
            font = {name="SF Pro Rounded", size=14},
            color = {red=0.2, green=0.9, blue=0.3, alpha=1},
        })
        pill[ELEM_TEXT].frame = {x=40, y=0, w=PILL_W-56, h=PILL_H}
        pill[ELEM_TEXT].textAlignment = "left"
        pill:alpha(1)

        pillHideTimer = hs.timer.doAfter(1.5, function()
            if pill then pill:alpha(0) end
            pillState = "idle"
        end)

    -- ---- ERROR: Red dot + "Failed" → 2s fade ----
    elseif state == "error" then
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=1, green=0.2, blue=0.2, alpha=1}
        pill[ELEM_DOT].radius = 6
        for i = 1, WAVE_BAR_COUNT do
            pill[ELEM_WAVE_START + i - 1].action = "skip"
        end
        pill[ELEM_TEXT].text = hs.styledtext.new("Failed", {
            font = {name="SF Pro Rounded", size=14},
            color = {red=1, green=0.3, blue=0.3, alpha=1},
        })
        pill[ELEM_TEXT].frame = {x=40, y=0, w=PILL_W-56, h=PILL_H}
        pill[ELEM_TEXT].textAlignment = "left"
        pill:alpha(1)

        pillHideTimer = hs.timer.doAfter(2, function()
            if pill then pill:alpha(0) end
            pillState = "idle"
        end)
    end
end

-- ============================================
-- HELPERS
-- ============================================

local function removeStopFile()
    os.execute("rm -f " .. stopFile)
end

local function touchStopFile()
    os.execute("touch " .. stopFile)
end

-- ============================================
-- RECORDING CONTROL
-- ============================================

local function startRecording(modeName)
    if isRecording then return end
    isRecording = true
    removeStopFile()

    -- Pill UI
    if modeName == "Continuous Mode" then
        pillSetState("listening_continuous")
    else
        pillSetState("listening_hold")
    end

    hs.notify.new({title="Bakwaas", informativeText="🎤 Recording (" .. modeName .. ")"}):send()

    local args = {bakwaasScript, "-c"}
    recordingTask = hs.task.new(pythonBin, function(exitCode, stdOut, stdErr)
        isRecording = false
        isContinuousMode = false
        if exitCode == 0 then
            pillSetState("done")
            hs.notify.new({title="Bakwaas", informativeText="✅ Pasted!"}):send()
        else
            print("Bakwaas Error: " .. stdErr)
            pillSetState("error")
            hs.notify.new({title="Bakwaas Error", informativeText="Failed"}):send()
        end
    end, args)

    recordingTask:start()
end

local function stopRecording()
    if not isRecording then return end
    touchStopFile()
    pillSetState("processing")
    hs.notify.new({title="Bakwaas", informativeText="⏹️ Processing..."}):send()
end

-- ============================================
-- FN KEY EVENTTAP
-- ============================================

local fnEventTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
    local flags = event:getFlags()
    local isFnNowDown = flags.fn or false

    if isFnNowDown == fnIsDown then return false end
    fnIsDown = isFnNowDown

    local now = hs.timer.secondsSinceEpoch()

    if isFnNowDown then
        -- FN PRESSED
        if isContinuousMode and isRecording then
            isContinuousMode = false
            stopRecording()
            lastFnTapTime = 0
            return false
        end

        local timeSinceLastTap = now - lastFnTapTime
        if timeSinceLastTap < doubleTapThreshold then
            -- DOUBLE TAP
            if fnDownTimer then
                fnDownTimer:stop()
                fnDownTimer = nil
            end
            isContinuousMode = true
            startRecording("Continuous Mode")
            lastFnTapTime = 0
        else
            -- SINGLE TAP DOWN
            lastFnTapTime = now
            fnDownTimer = hs.timer.doAfter(holdThreshold, function()
                if fnIsDown and not isRecording then
                    isContinuousMode = false
                    startRecording("Hold-to-Talk")
                end
            end)
        end
    else
        -- FN RELEASED
        if fnDownTimer then
            fnDownTimer:stop()
            fnDownTimer = nil
        end
        if isRecording and not isContinuousMode then
            stopRecording()
        end
    end

    return false
end)

-- ============================================
-- INIT
-- ============================================

local function testPillVisibility()
    print("=== PILL DEBUG ===")
    if pill then
        print("Pill exists: YES")
        print("Pill frame:", hs.inspect(pill:frame()))
        print("Pill alpha:", pill:alpha())
        print("Pill isShowing:", pill:isShowing())
        
        -- Force bright red background for testing
        pill[1].fillColor = {red=1, green=0, blue=0, alpha=1}
        pill:alpha(1)
        
        print("Forced pill to alpha=1 with bright red background")
    else
        print("Pill exists: NO - pill is nil!")
    end
end

pill = pillBuild()
hs.timer.doAfter(1, testPillVisibility)
fnEventTap:start()
hs.notify.new({title="Bakwaas", informativeText="🔥 Bakwaas loaded! Hold Fn or Double-tap Fn"}):send()
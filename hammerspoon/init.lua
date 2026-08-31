-- ============================================
-- Bakwaas Dictation Engine - Hammerspoon Config
-- Minimal, Sleek Wispr-style Floating Pill UI
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

-- UI Config
local pill = nil
local PILL_W = 220
local PILL_H = 38
local PILL_RADIUS = 19
local PILL_MARGIN_BOTTOM = 60

local ELEM_DOT = 2
local ELEM_TEXT = 3

local pillAnimTimer = nil
local pillHideTimer = nil
local pillState = "idle"

local function pillReposition()
    if not pill then return end
    local screen = hs.screen.focusedScreen() or hs.screen.mainScreen()
    if not screen then return end
    
    local frame = screen:frame()
    local x = frame.x + (frame.w - PILL_W) / 2
    local y = frame.y + frame.h - PILL_H - PILL_MARGIN_BOTTOM
    pill:frame({x=x, y=y, w=PILL_W, h=PILL_H})
end

local function pillBuild()
    local c = hs.canvas.new({x=0, y=0, w=PILL_W, h=PILL_H})
    c:level(hs.drawing.windowLevels.overlay)
    c:clickActivating(false)
    c:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

    -- [1] Dark Subtle Pill Background
    c:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = {red=0.1, green=0.1, blue=0.12, alpha=0.92},
        roundedRectRadii = {xRadius=PILL_RADIUS, yRadius=PILL_RADIUS},
        frame = {x=0, y=0, w=PILL_W, h=PILL_H},
    })

    -- [2] Indicator Dot
    c:appendElements({
        type = "circle",
        action = "fill",
        fillColor = {red=0.95, green=0.25, blue=0.25, alpha=1},
        radius = 5,
        center = {x=22, y=PILL_H/2},
    })

    -- [3] Text Label
    c:appendElements({
        type = "text",
        text = hs.styledtext.new("Listening...", {
            font = {name=".AppleSystemUIFont", size=13},
            color = {red=0.95, green=0.95, blue=0.95, alpha=1},
        }),
        frame = {x=40, y=0, w=PILL_W - 48, h=PILL_H},
        textAlignment = "left",
        textVerticalAlignment = "center",
    })

    c:hide()
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

    if state == "listening_hold" then
        pillReposition()
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=0.95, green=0.25, blue=0.25, alpha=1}
        pill[ELEM_TEXT].text = hs.styledtext.new("Listening...", {
            font = {name=".AppleSystemUIFont", size=13},
            color = {red=0.95, green=0.95, blue=0.95, alpha=1},
        })
        pill:show()

        local phase = 0
        pillAnimTimer = hs.timer.doEvery(0.05, function()
            if pillState ~= "listening_hold" then return end
            phase = phase + 0.15
            local s = 0.5 + 0.5 * math.abs(math.sin(phase))
            pill[ELEM_DOT].radius = 4 + 3 * s
        end)

    elseif state == "listening_continuous" then
        pillReposition()
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=0.95, green=0.25, blue=0.25, alpha=1}
        pill[ELEM_TEXT].text = hs.styledtext.new("Listening (Continuous)", {
            font = {name=".AppleSystemUIFont", size=13},
            color = {red=0.95, green=0.95, blue=0.95, alpha=1},
        })
        pill:show()

    elseif state == "processing" then
        pillReposition()
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=0.95, green=0.8, blue=0.25, alpha=1}
        pill[ELEM_TEXT].text = hs.styledtext.new("Transcribing...", {
            font = {name=".AppleSystemUIFont", size=13},
            color = {red=0.95, green=0.8, blue=0.25, alpha=1},
        })
        pill:show()

    elseif state == "done" then
        pillReposition()
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=0.2, green=0.85, blue=0.35, alpha=1}
        pill[ELEM_TEXT].text = hs.styledtext.new("Done!", {
            font = {name=".AppleSystemUIFont", size=13},
            color = {red=0.2, green=0.85, blue=0.35, alpha=1},
        })
        pill:show()

        pillHideTimer = hs.timer.doAfter(2.0, function()
            if pill then pill:hide() end
            pillState = "idle"
        end)

    elseif state == "error" then
        pillReposition()
        pill[ELEM_DOT].action = "fill"
        pill[ELEM_DOT].fillColor = {red=0.95, green=0.25, blue=0.25, alpha=1}
        pill[ELEM_TEXT].text = hs.styledtext.new("Failed", {
            font = {name=".AppleSystemUIFont", size=13},
            color = {red=0.95, green=0.3, blue=0.3, alpha=1},
        })
        pill:show()

        pillHideTimer = hs.timer.doAfter(2.0, function()
            if pill then pill:hide() end
            pillState = "idle"
        end)
    end
end

local function removeStopFile()
    os.execute("rm -f " .. stopFile)
end

local function touchStopFile()
    os.execute("touch " .. stopFile)
end

local function startRecording(modeName)
    if isRecording then return end
    isRecording = true
    removeStopFile()

    if modeName == "Continuous Mode" then
        pillSetState("listening_continuous")
    else
        pillSetState("listening_hold")
    end

    local args = {bakwaasScript, "-c"}
    recordingTask = hs.task.new(pythonBin, function(exitCode, stdOut, stdErr)
        isRecording = false
        isContinuousMode = false
        if exitCode == 0 then
            pillSetState("done")
            -- Hammerspoon native paste
            hs.timer.doAfter(0.1, function()
                hs.eventtap.keyStroke({"cmd"}, "v")
            end)
        else
            print("Bakwaas Error: " .. stdErr)
            pillSetState("error")
        end
    end, args)

    if not recordingTask:start() then
        isRecording = false
        isContinuousMode = false
        pillSetState("idle")
        hs.alert.show("Bakwaas Error: Failed to trigger Python execution", 3)
    end
end

local function stopRecording()
    if not isRecording then return end
    touchStopFile()
    pillSetState("processing")
end

-- EventTap for Fn key
local fnEventTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
    local flags = event:getFlags()
    local isFnNowDown = flags.fn or false

    if isFnNowDown == fnIsDown then return false end
    fnIsDown = isFnNowDown

    local now = hs.timer.secondsSinceEpoch()

    if isFnNowDown then
        if isContinuousMode and isRecording then
            isContinuousMode = false
            stopRecording()
            lastFnTapTime = 0
            return false
        end

        local timeSinceLastTap = now - lastFnTapTime
        if timeSinceLastTap < doubleTapThreshold then
            if fnDownTimer then
                fnDownTimer:stop()
                fnDownTimer = nil
            end
            isContinuousMode = true
            startRecording("Continuous Mode")
            lastFnTapTime = 0
        else
            lastFnTapTime = now
            fnDownTimer = hs.timer.doAfter(holdThreshold, function()
                if fnIsDown and not isRecording then
                    isContinuousMode = false
                    startRecording("Hold-to-Talk")
                end
            end)
        end
    else
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

-- INIT
os.execute("pkill -f bakwaas.py")
os.execute("rm -f " .. stopFile)
pill = pillBuild()
fnEventTap:start()
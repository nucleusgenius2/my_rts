if not RmlUi then
    return
end

function widget:GetInfo()
    return {
        name = "NG Rml context manager",
        desc = "This widget is responsible for handling dynamic interactions with Rml contexts.",
        author = "nucleus_genius",
        date = "2025",
        license = "GNU GPL, v2 or later",
        layer = -1000000,  -- важно, чтобы грузился ПЕРВЫМ!
        enabled = true
    }
end

local function calculateDpRatio()
    local viewSizeX, viewSizeY = Spring.GetViewGeometry()
    local userScale = Spring.GetConfigFloat("ui_scale", 1)
    local baseWidth = 1920
    local baseHeight = 1080
    local resFactor = math.min(viewSizeX / baseWidth, viewSizeY / baseHeight)
    local dpRatio = resFactor * userScale
    return math.floor(dpRatio * 100) / 100
end

local function updateContextsDpRatio()
    local newDpRatio = calculateDpRatio()
    if RmlUi.contexts then
        local contexts = RmlUi.contexts()
        for _, context in ipairs(contexts) do
            context.dp_ratio = newDpRatio
        end
    end
end

function widget:Initialize()
    if not RmlUi.GetContext("shared") then
        RmlUi.CreateContext("shared")
        Spring.Echo("[Rml Context Manager] Контекст 'shared' создан!")
    end
    updateContextsDpRatio()
end

function widget:ViewResize()
    updateContextsDpRatio()
end

function widget:Shutdown()
    Spring.Echo("Rml Context Manager shutdown, dynamic context dp ratio updates to contexts disabled.")
end

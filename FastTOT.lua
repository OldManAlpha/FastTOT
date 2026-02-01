-- This addon utilizes SuperWoW's guid-based events to update the target of target frame instead of updating every frame.

if not SUPERWOW_VERSION then
    DEFAULT_CHAT_FRAME:AddMessage("FastTOT requires SuperWoW to work.")
    return
end
local ok, result = pcall(GetCVar, "PB_FilterGuidEvents")
if result == "1" then
    DEFAULT_CHAT_FRAME:AddMessage("FastTOT requires you to disable \"Filter GUID Events\" in PerfBoost.")
    return
end

local incompatibleAddons = {"pfUI", "-DragonflightReloaded", "-Dragonflight3", "DragonflightUI-Reforged"}

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("VARIABLES_LOADED")
loadFrame:SetScript("OnEvent", function()
    for _, addon in ipairs(incompatibleAddons) do
        if IsAddOnLoaded(addon) then
            DEFAULT_CHAT_FRAME:AddMessage("FastTOT is not compatible with "..addon..".")
            return
        end
    end
    loadFrame:UnregisterAllEvents()
    FastTOT_Initialize()
end)

function FastTOT_Initialize()
    TargetofTargetFrame:SetScript("OnUpdate", nil)

    local function UpdateTargetofTarget()
        local prevThis = this
        this = TargetofTargetFrame
        TargetofTarget_OnUpdate()
        this = prevThis
    end

    local currentTOT
    local TOTScanner = function()
        local exists, guid = UnitExists("targettarget")
        if currentTOT ~= guid then
            currentTOT = guid
            UpdateTargetofTarget()
        end
    end

    local f = CreateFrame("Frame", "FastTOTHandler")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("UNIT_HEALTH")
    f:RegisterEvent("UNIT_AURA")
    f:SetScript("OnEvent", function()
        if event == "PLAYER_TARGET_CHANGED" then
            f:SetScript("OnUpdate", UnitExists("target") and TOTScanner)
            return
        end
        if UnitIsUnit(arg1, "targettarget") then
            UpdateTargetofTarget()
        end
    end)
end
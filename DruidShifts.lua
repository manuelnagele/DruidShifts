local ADDON = ...

local _, playerClass = UnitClass("player")
if playerClass ~= "DRUID" then return end

local MANA = (Enum and Enum.PowerType and Enum.PowerType.Mana) or 0
local CELL_SIZE = 28
local CELL_GAP = 6
local ICON_SIZE = 20

local defaults = {
    point = { "CENTER", "UIParent", "CENTER", 0, -180 },
    locked = false,
    scale = 1,
    sound = true,
}

local db
local cells = {}
local warned = false

local frame = CreateFrame("Frame", "DruidShiftsFrame", UIParent, "BackdropTemplate")
frame:SetSize(CELL_SIZE, CELL_SIZE + ICON_SIZE)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    db.point = { point, "UIParent", relPoint, x, y }
end)

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff7d0aDruidShifts|r: " .. msg)
end

local function GetManaCost(spellID)
    if not spellID or not GetSpellPowerCost then return nil end
    local costs = GetSpellPowerCost(spellID)
    if not costs then return nil end
    for _, c in ipairs(costs) do
        if c.type == MANA then return c.cost end
    end
end

local function GetIcon(spellID, fallback)
    if C_Spell and C_Spell.GetSpellTexture then
        return C_Spell.GetSpellTexture(spellID) or fallback
    end
    return (GetSpellTexture and GetSpellTexture(spellID)) or fallback
end

local function CountColor(n)
    if n <= 0 then return 1, 0.15, 0.15 end
    if n == 1 then return 1, 0.5, 0 end
    if n == 2 then return 1, 0.85, 0 end
    return 1, 1, 1
end

local function ApplyLock()
    frame:EnableMouse(not db.locked)
    if db.locked then
        frame:SetBackdrop(nil)
    else
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.5)
    end
end

local function ApplyPosition()
    frame:ClearAllPoints()
    local p = db.point
    frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    frame:SetScale(db.scale)
end

---------------------------------------------------------------------------
-- Cells
---------------------------------------------------------------------------

local function CreateCell(i)
    local cell = CreateFrame("Frame", nil, frame)
    cell:SetSize(CELL_SIZE, CELL_SIZE + ICON_SIZE)

    cell.icon = cell:CreateTexture(nil, "ARTWORK")
    cell.icon:SetSize(ICON_SIZE, ICON_SIZE)
    cell.icon:SetPoint("TOP", 0, 0)
    cell.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    cell.text = cell:CreateFontString(nil, "OVERLAY")
    cell.text:SetFont(STANDARD_TEXT_FONT, 20, "THICKOUTLINE")
    cell.text:SetPoint("TOP", cell.icon, "BOTTOM", 0, -2)

    local flash = cell.text:CreateAnimationGroup()
    flash:SetLooping("BOUNCE")
    local a = flash:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.15)
    a:SetDuration(0.25)
    cell.flash = flash

    cells[i] = cell
    return cell
end

local function Warn()
    if db.sound then PlaySound(SOUNDKIT.RAID_WARNING, "Master") end
    UIErrorsFrame:AddMessage("Out of mana for shapeshifting!", 1, 0.2, 0.2)
end

local function Update()
    local mana = UnitPower("player", MANA)
    local numForms = GetNumShapeshiftForms() or 0
    local shown = 0
    local activeCount

    for i = 1, numForms do
        local texture, active, _, spellID = GetShapeshiftFormInfo(i)
        local cost = GetManaCost(spellID)
        local cell = cells[i] or CreateCell(i)

        shown = shown + 1
        cell:ClearAllPoints()
        cell:SetPoint("TOPLEFT", frame, "TOPLEFT", 4 + (shown - 1) * (CELL_SIZE + CELL_GAP), -4)
        cell.icon:SetTexture(GetIcon(spellID, texture))
        cell:SetAlpha(active and 1 or 0.55)

        local count
        if cost and cost > 0 then
            count = math.floor(mana / cost)
            cell.text:SetText(count)
            cell.text:SetTextColor(CountColor(count))
        else
            cell.text:SetText("-")
            cell.text:SetTextColor(0.6, 0.6, 0.6)
        end

        if active then activeCount = count end
        if active and count == 0 then
            if not cell.flash:IsPlaying() then cell.flash:Play() end
        elseif cell.flash:IsPlaying() then
            cell.flash:Stop()
        end
        cell:Show()
    end

    for i = numForms + 1, #cells do
        cells[i].flash:Stop()
        cells[i]:Hide()
    end

    -- Warn once per depletion; re-arm when mana allows another shift.
    if activeCount then
        if activeCount == 0 and not warned then
            warned = true
            Warn()
        elseif activeCount > 0 then
            warned = false
        end
    end

    if shown == 0 then
        frame:SetSize(CELL_SIZE + 8, CELL_SIZE + ICON_SIZE + 8)
    else
        frame:SetSize(shown * CELL_SIZE + (shown - 1) * CELL_GAP + 8, CELL_SIZE + ICON_SIZE + 8)
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON then return end
        DruidShiftsDB = DruidShiftsDB or {}
        for k, v in pairs(defaults) do
            if DruidShiftsDB[k] == nil then DruidShiftsDB[k] = v end
        end
        db = DruidShiftsDB
        ApplyPosition()
        ApplyLock()
        self:UnregisterEvent("ADDON_LOADED")
        return
    end
    if (event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE") and arg2 ~= "MANA" then
        return
    end
    if db then Update() end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
frame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
for _, e in ipairs({
    "UPDATE_SHAPESHIFT_FORMS", "UPDATE_SHAPESHIFT_FORM", "SPELLS_CHANGED",
    "CHARACTER_POINTS_CHANGED", "PLAYER_EQUIPMENT_CHANGED",
}) do
    pcall(frame.RegisterEvent, frame, e)
end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------

SLASH_DRUIDSHIFTS1 = "/shifts"
SLASH_DRUIDSHIFTS2 = "/druidshifts"
SlashCmdList.DRUIDSHIFTS = function(msg)
    local cmd, arg = strsplit(" ", strtrim(msg or ""):lower(), 2)
    if cmd == "lock" then
        db.locked = true
        ApplyLock()
        Print("locked.")
    elseif cmd == "unlock" then
        db.locked = false
        ApplyLock()
        Print("unlocked - drag to move.")
    elseif cmd == "reset" then
        db.point = CopyTable(defaults.point)
        db.scale = defaults.scale
        ApplyPosition()
        Print("position and scale reset.")
    elseif cmd == "scale" then
        local s = tonumber(arg)
        if s and s >= 0.5 and s <= 3 then
            db.scale = s
            ApplyPosition()
            Print("scale set to " .. s .. ".")
        else
            Print("usage: /shifts scale <0.5 - 3>")
        end
    elseif cmd == "sound" then
        db.sound = not db.sound
        Print("warning sound " .. (db.sound and "on" or "off") .. ".")
    else
        Print("commands: lock, unlock, reset, scale <n>, sound")
    end
end

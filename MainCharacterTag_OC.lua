-- MainCharacterTag
-- Prefixes guild and guild officer chat with your main character's name.
-- Compatible with WoW 1.12.1

MainCharacterTagDB = MainCharacterTagDB or {}

local function GetMainName()
    return MainCharacterTagDB.mainName or ""
end

local function SetMainName(name)
    name = string.gsub(name, "^%s*(.-)%s*$", "%1")
    MainCharacterTagDB.mainName = name
end

local function IsCurrentCharMain()
    local currentChar = UnitName("player")
    local mainName = GetMainName()
    return mainName == "" or currentChar == mainName
end

-- ============================================================
-- Hook SendChatMessage to prepend the main name
-- Only active after the player is fully in the world
-- ============================================================
local origSendChatMessage = SendChatMessage
local playerReady = false

function SendChatMessage(msg, chatType, language, channel)
    if playerReady and msg and msg ~= "" and chatType then
        -- ignore macro directives
        if string.sub(msg, 1, 1) == "#" then
            return origSendChatMessage(msg, chatType, language, channel)
        end
        local upperType = string.upper(chatType)
        if (upperType == "GUILD" or upperType == "OFFICER") then
            local mainName = GetMainName()
            if mainName ~= "" and not IsCurrentCharMain() then
                msg = "(" .. mainName .. "): " .. msg
            end
        end
    end
    origSendChatMessage(msg, chatType, language, channel)
end

-- ============================================================
-- Options Frame  (vanilla-compatible, no XML templates)
-- ============================================================
local optionsFrame = CreateFrame("Frame", "MainCharacterTagOptions", UIParent)
optionsFrame:SetWidth(360)
optionsFrame:SetHeight(200)
optionsFrame:SetPoint("CENTER", UIParent, "CENTER")
optionsFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
optionsFrame:SetMovable(true)
optionsFrame:EnableMouse(true)
optionsFrame:RegisterForDrag("LeftButton")
optionsFrame:SetScript("OnDragStart", function() optionsFrame:StartMoving() end)
optionsFrame:SetScript("OnDragStop", function() optionsFrame:StopMovingOrSizing() end)
optionsFrame:Hide()

-- Title bar text
local titleText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOP", optionsFrame, "TOP", 0, -16)
titleText:SetText("MainCharacterTag — Options")

-- Author text
local authorText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
authorText:SetPoint("TOP", optionsFrame, "TOP", 0, -38)
authorText:SetText("Created by: Olzon")

-- Description
local descText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
descText:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, -60)
descText:SetWidth(320)
descText:SetJustifyH("LEFT")
descText:SetText("Set your main character's name. Guild and officer chat\nsent from alts will be prefixed with that name.")

-- Current character label
local currentLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
currentLabel:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, -92)

-- Name input label
local nameLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
nameLabel:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, -118)
nameLabel:SetText("Main Name:")

-- EditBox
local nameInput = CreateFrame("EditBox", "MainCharacterTagInput", optionsFrame)
nameInput:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 100, -114)
nameInput:SetWidth(230)
nameInput:SetHeight(20)
nameInput:SetAutoFocus(false)
nameInput:SetMaxLetters(64)
nameInput:SetFontObject(GameFontHighlight)
nameInput:SetBackdrop({
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true, tileSize = 5, edgeSize = 1,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
nameInput:SetBackdropColor(0, 0, 0, 0.8)
nameInput:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
nameInput:SetScript("OnEnterPressed", function() nameInput:ClearFocus() end)
nameInput:SetScript("OnEscapePressed", function() nameInput:ClearFocus() end)

-- Status text centered above buttons
local statusLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
statusLabel:SetPoint("BOTTOM", optionsFrame, "BOTTOM", 0, 50)
statusLabel:SetJustifyH("CENTER")

-- Save button (centered pair)
local saveBtn = CreateFrame("Button", nil, optionsFrame, "GameMenuButtonTemplate")
saveBtn:SetWidth(90)
saveBtn:SetHeight(24)
saveBtn:SetPoint("BOTTOM", optionsFrame, "BOTTOM", -50, 18)
saveBtn:SetText("Save")
saveBtn:SetScript("OnClick", function()
    local name = nameInput:GetText()
    SetMainName(name)
    if name == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96MainCharacterTag:|r Main name cleared. Prefix disabled.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96MainCharacterTag:|r Main set to |cffffd700" .. name .. "|r")
    end
    optionsFrame:Hide()
end)

-- Cancel button
local cancelBtn = CreateFrame("Button", nil, optionsFrame, "GameMenuButtonTemplate")
cancelBtn:SetWidth(90)
cancelBtn:SetHeight(24)
cancelBtn:SetPoint("BOTTOM", optionsFrame, "BOTTOM", 50, 18)
cancelBtn:SetText("Cancel")
cancelBtn:SetScript("OnClick", function()
    optionsFrame:Hide()
end)

-- Refresh frame contents on show
optionsFrame:SetScript("OnShow", function()
    nameInput:SetText(GetMainName())
    currentLabel:SetText("Logged in as: |cffffd700" .. (UnitName("player") or "Unknown") .. "|r")
    local main = GetMainName()
    if main == "" then
        statusLabel:SetText("|cffaaaaaa(No main set — prefix disabled)|r")
    elseif IsCurrentCharMain() then
        statusLabel:SetText("|cff00ff96You are on your main.|r")
    else
        statusLabel:SetText("|cffffff00Alt detected — prefix active.|r")
    end
end)

-- ============================================================
-- Slash commands
-- ============================================================
SLASH_MAINCHARACTERTAG1 = "/mct"
SLASH_MAINCHARACTERTAG2 = "/mainchartag"
SlashCmdList["MAINCHARACTERTAG"] = function(msg)
    if optionsFrame:IsShown() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end

-- ============================================================
-- Addon loaded event (vanilla style)
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        MainCharacterTagDB = MainCharacterTagDB or {}
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96MainCharacterTag|r loaded. Type |cffffd700/mct|r to open options.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        playerReady = true
    end
end)

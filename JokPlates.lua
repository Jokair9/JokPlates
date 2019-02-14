JokPlates = LibStub("AceAddon-3.0"):NewAddon("JokPlates", "AceEvent-3.0", "AceHook-3.0")
JokPlatesFrameMixin = {};

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local priorityList = {}

local LCG = LibStub("LibCustomGlow-1.0")
local _, class = UnitClass("player")

local glowType = "Standard"

local statusBar = "Interface\\AddOns\\JokPlates\\media\\UI-StatusBar"

local ccList
local interrupts
local nameplates_buffs
local nameplates_debuffs
local nameplates_personal
local colorList
local glowList
local iconList
local PowerPrediction

local defaults_settings = {
    profile = {
        arenanumber = true,
        sticky = true,
        clickthroughfriendly = true,
        healthWidth = 120,
        healthHeight = 7,
        buffFrameScale = 1,
        personalWidth = 150,
        personalManaHeight = 14,
        personalHealthHeight = 11,
        castTarget = true,
        castInterrupt = true,
        spells = {
        	buffs = {
        		purgeable = true,
        	},
        	debuffs = {},
        	personal = {},
            custom = {},
        },                        
    }
}

function JokPlates:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JokPlatesDB", defaults_settings, true)
	self.settings = self.db.profile

    ccList = JokPlatesFrameMixin.ccList
    interrupts = JokPlatesFrameMixin.interrupts
    nameplates_buffs = JokPlatesFrameMixin.nameplates_buffs
    nameplates_debuffs = JokPlatesFrameMixin.nameplates_debuffs
    nameplates_personal = JokPlatesFrameMixin.nameplates_personal
    colorList = JokPlatesFrameMixin.colorList
    glowList = JokPlatesFrameMixin.glowList
    iconList = JokPlatesFrameMixin.iconList
    PowerPrediction = JokPlatesFrameMixin.PowerPrediction

	self:SetupOptions()
    self:ShutdownInterfaceOptionsPanel()

    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc = function() end

    for k, v in ipairs(ccList) do
        priorityList[v] = k
    end

    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JokPlates", "|cffFF7D0AJok|rPlates")

	self:Refresh()
end

function JokPlates:OnEnable()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("NAME_PLATE_CREATED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    self:RegisterEvent('UNIT_FACTION')

    self:SecureHook('ClassNameplateManaBar_OnUpdate')
    self:SecureHook('DefaultCompactNamePlateFrameSetup')
    self:SecureHook('DefaultCompactNamePlateFrameAnchorInternal')

    self:SecureHook(NamePlateDriverFrame, 'SetupClassNameplateBars', 'SetupClassNameplateBar')
    self:SecureHook(_G['NamePlateDriverFrame'], 'UpdateNamePlateOptions', 'NamePlateDriverFrame_UpdateNamePlateOptions')
    self:SecureHook(_G['ClassNameplateManaBarFrame'], 'OnOptionsUpdated', 'ClassNameplateManaBarFrame_OnOptionsUpdated')

    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateMaxScale", 1)
    SetCVar("nameplateShowDebuffsOnFriendly", 0)
    SetCVar("nameplateOccludedAlphaMult", 1)

    SetCVar("nameplateShowAll", 1)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

function JokPlates:GetCVar(CVar)
    if GetCVar(CVar) == "1" then 
        return true
    elseif GetCVar(CVar) == "0"      then
        return false
    end
end

function JokPlates:SetCVar(CVar, value)
    if value == true then 
        SetCVar(CVar, 1)
    elseif value == false then
        SetCVar(CVar, 0)
    end
end

function JokPlates:CreateText(frame, layer, fontsize, flag, justifyh, shadow)
    local text = frame:CreateFontString("$parent.CountText", layer)
    text:SetFont("Fonts\\FRIZQT__.TTF", fontsize, flag)
    text:SetJustifyH(justifyh)
    
    if shadow then
        text:SetShadowColor(0, 0, 0)
        text:SetShadowOffset(1, -1)
    end
    
    return text
end

function JokPlates:PairsByKeys(t)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
    return iter
end

function JokPlates:CreateIcon(parent, tag, index)
    local button = CreateFrame("Frame", "$parent"..index, parent)
    button:SetSize(20, 14)    
    button:EnableMouse(false)

    button.icon = button:CreateTexture("$parent.Icon", "OVERLAY", nil, 3)
    button.icon:SetTexCoord(0.05, 0.95, 0.1, 0.6)
    button.icon:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 1,1);
    button.icon:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1,-1);

    button.overlay = button:CreateTexture("$parent.Overlay", "ARTWORK", nil, 7)
    button.overlay:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
    button.overlay:SetPoint("TOPLEFT", button, -3, 3)
    button.overlay:SetPoint("BOTTOMRIGHT", button, 3, -3)
    button.overlay:SetBlendMode("ADD")

    --Border
    if not button.Backdrop then
        local backdrop = {
            bgFile = "Interface\\AddOns\\JokUI\\media\\textures\\Square_White.tga",
            edgeFile = "",
            tile = false,
            tileSize = 32,
            edgeSize = 0,
            insets = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0
            }
        }
        local Backdrop = CreateFrame("frame", "$parent.Border", button);
        button.Backdrop = Backdrop;
        button.Backdrop:SetBackdrop(backdrop)
        button.Backdrop:SetAllPoints(button)
        button.Backdrop:Show();
    end
    button.Backdrop:SetBackdropColor(0, 0, 0, 1)

    local regionFrameLevel = button:GetFrameLevel() -- get strata for next bit
    button.Backdrop:SetFrameLevel(regionFrameLevel-2) -- put the border at the back

    button.cd = CreateFrame("Cooldown", "$parent.Cooldown", button, "CooldownFrameTemplate")
    button.cd:SetAllPoints(button)
    button.cd:SetDrawEdge(false)
    button.cd:SetAlpha(1)
    button.cd:SetDrawSwipe(true)
    button.cd:SetReverse(true)
    
    if strfind(tag, "aura") then
        button.count = self:CreateText(button, "OVERLAY", 12, "OUTLINE", "RIGHT")
        button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -2)
        button.count:SetTextColor(1, 1, 1)
    end

    button:Hide()
    parent.QueueIcon(button, tag)
    
    return button
end

function JokPlates:FormatTime(s)
    if s > 86400 then
        -- Days
        return ceil(s/86400) .. "d", s%86400
    elseif s >= 3600 then
        -- Hours
        return ceil(s/3600) .. "h", s%3600
    elseif s >= 60 then
        -- Minutes
        return ceil(s/60) .. "m", s%60
    elseif s <= 3 then
        -- Seconds
        return format("%.1f", s)
    end

    return floor(s), s - floor(s)
end

function JokPlates:FormatValue(number)
    if ( number < 1e4 ) then
        return floor(number)
    elseif ( number >= 1e12 ) then
        return format("%.3ft", number/1e12)
    elseif ( number >= 1e9 ) then
        return format("%.3fb", number/1e9)
    elseif ( number >= 1e6 ) then
        return format("%.2fm", number/1e6)
    elseif ( number >= 1e4 ) then
        return format("%.0f K", number/1e3)
    end
end

function JokPlates:Abbrev(str,length)
    if ( str ~= nil and length ~= nil ) then
        return str:len()>length and str:sub(1,length)..".." or str
    end
    return ""
end

function JokPlates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

function JokPlates:PlayerIsTank(unit)
    local assignedRole = UnitGroupRolesAssigned(unit)
    return assignedRole == "TANK"
end

function JokPlates:UseOffTankColor(unit)
    if ( UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) ) then
        if ( not UnitIsUnit("player", unit) and JokPlates:PlayerIsTank("player") and JokPlates:PlayerIsTank(unit) ) then
            return true
        end
    end
    return false
end

function JokPlates:IsPet(unit)
    return (not UnitIsPlayer(unit) and UnitPlayerControlled(unit))
end

function JokPlates:SetTextColorByClass(unit, text)
    local _, class = UnitClass (unit)
    if (class) then
        local color = RAID_CLASS_COLORS [class]
        if (color) then
            text = "|c" .. color.colorStr .. " [" .. text:gsub (("%-.*"), "") .. "]|r"
        end
    end
    return text
end

function JokPlates:SetPlayerNameByClass(unit, text)
    local _, class = UnitClass (unit)
    if (class) then
        local color = RAID_CLASS_COLORS [class]
        if (color) then
            text = "|c" .. color.colorStr .. text:gsub (("%-.*"), "") .. "|r"
        end
    end
    return text
end

function JokPlates:GroupMembers(reversed, forceParty)
    local unit  = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = forceParty and GetNumSubgroupMembers()  or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
        local ret 
        if i == 0 and unit == 'party' then 
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + (reversed and -1 or 1)
        return ret
    end
end

function JokPlates:UpdateCastbarTimer(frame)
    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            local current = frame.castBar.maxValue - frame.castBar.value
            if ( current > 0 ) then
                frame.castBar.CastTime:SetText(JokPlates:FormatTime(current))
            end
        else
            if ( frame.castBar.value > 0 ) then
                frame.castBar.CastTime:SetText(JokPlates:FormatTime(frame.castBar.value))
            end
        end
    end
end

function JokPlates:GetNpcID(unit)
    local npcID = select(6, strsplit("-", UnitGUID(unit)))

    return tonumber(npcID)
end

function JokPlates:DangerousColor(frame)
	local r, g, b
	local dangerousColor = {r = 1.0, g = 0.7, b = 0.0}
	local otherColor = {r = 0.0, g = 0.7, b = 1.0}

	local npcID = frame.npcID

	for k, npcs in pairs(colorList) do
		local tag = npcs["tag"]

		if k == npcID then
			if tag == "DANGEROUS" then			
				r, g, b = dangerousColor.r, dangerousColor.g, dangerousColor.b
			elseif tag == "OTHER" then
				r, g, b = otherColor.r, otherColor.g, otherColor.b
			end
		end
    end
    return r, g, b
end

function JokPlates:AddHealthbarText(frame)
    if ( frame ) then
        local HealthBar = frame.UnitFrame.healthBar
        if ( not HealthBar.LeftText ) then
            HealthBar.LeftText = HealthBar:CreateFontString("$parent.healthBar.leftText", "OVERLAY")
            HealthBar.LeftText:SetPoint("LEFT", HealthBar, "LEFT", 2, 0)
            HealthBar.LeftText:SetFont("FONTS\\FRIZQT__.TTF", 10, "OUTLINE")
        end
        if ( not HealthBar.RightText ) then
            HealthBar.RightText = HealthBar:CreateFontString("$parent.healthBar.rightText", "OVERLAY")
            HealthBar.RightText:SetPoint("RIGHT", HealthBar, "RIGHT", -2, 0)
            HealthBar.RightText:SetFont("FONTS\\FRIZQT__.TTF", 10, "OUTLINE")
        end
    end
end

function JokPlates:GlowNameplate(frame, show)
    if show then
        if glowType == "AutoCast" then
            LCG.AutoCastGlow_Start(frame.healthBar, nil, 8, 0.3, 1, 1, 1)
        elseif glowType == "Pixel" then
            LCG.PixelGlow_Start(frame.healthBar, nil, 10, 0.3, nil, 2, 2, 2, true)
        elseif glowType == "Standard" then
            LCG.ButtonGlow_Start(frame.healthBar)
        end
        frame.isGlowing = true
    else
        if glowType == "AutoCast" then
            LCG.AutoCastGlow_Stop(frame.healthBar)
        elseif glowType == "Pixel" then
            LCG.PixelGlow_Stop(frame.healthBar)    
        elseif glowType == "Standard" then
            LCG.ButtonGlow_Stop(frame.healthBar)
        end
        frame.isGlowing = false
    end 
end

function JokPlates:SetIcon(frame, size, show)
    if show then
        for k, npcs in pairs(iconList) do
            local icon = npcs["icon"]
            if k == frame.npcID then
                frame.icon:Show()
                frame.icon:SetTexture(npcs["icon"])
                frame.icon:SetSize(size, size)
                frame.icon:SetPoint("BOTTOM", frame.name, "TOP", 0, 2)
                frame.icon.active = true
            end
        end
        
    else
        frame.icon:SetTexture(nil)
        frame.icon:Hide()
        frame.icon.active = false
    end
end

-- UpdateBuffs Hook
function JokPlates_UpdateBuffs(self, unit, filter, showAll)

	if not self.isActive then
		for i = 1, BUFF_MAX_DISPLAY do
			if (self.buffList[i]) then
				self.buffList[i]:Hide();
			end
			if (self.debuffList[i]) then
				self.debuffList[i]:Hide();
			end
		end
		return;
	end

    -- Player Buff Frame
    if UnitIsUnit("player", unit) then
        self:SetScale(1.2)
    else
        self:SetScale(JokPlates.db.profile.buffFrameScale)
    end
	
	self.unit = unit;
	self.filter = filter;
	self:UpdateAnchor();

	-- Some buffs may be filtered out, use this to create the buff frames.
	local buffIndex = 1;
	for i = 1, BUFF_MAX_DISPLAY do
		local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, _, isBossDebuff, _, nameplateShowAll = UnitAura(unit, i, filter);

		-----------------------------------------------------------
		local flag = false

		-- Default Blizzard Filter
		flag = self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll or showAll, duration) 

		-- Debuffs Whitelist
		if JokPlates.db.profile.spells.debuffs[spellId] and caster == "player" then 
			flag = true 
		end

        if isBossDebuff then
            flag = true
        end

		-- Personal Buffs
		if JokPlates.db.profile.spells.buffs[spellId] and UnitIsUnit(unit, "player") then 
			flag = true 
		end

		-- Personal Whitelist
		if JokPlates.db.profile.spells.personal[spellId] and UnitIsUnit(unit, "player") then 
			flag = true 
		end

        if JokPlates.db.profile.spells.custom[spellId] and UnitIsUnit(unit, "player") then 
            if JokPlates.db.profile.spells.custom[spellId].personal then
                flag = true 
            end
        end  

		-----------------------------------------------------------
		if (flag) then
			if (not self.buffList[buffIndex]) then
				self.buffList[buffIndex] = CreateFrame("Frame", self:GetParent():GetName() .. "Buff" .. buffIndex, self, "NameplateBuffButtonTemplate");
				self.buffList[buffIndex]:SetMouseClickEnabled(false);
				self.buffList[buffIndex].layoutIndex = buffIndex;
				self.buffList[buffIndex].align = "right"
			end
			local buff = self.buffList[buffIndex];
			buff:SetID(i);

			buff.Icon:SetTexture(texture);

			if (count > 1) then
				buff.CountFrame.Count:SetText(count);
				buff.CountFrame.Count:Show();
			else
				buff.CountFrame.Count:Hide();
			end

			CooldownFrame_Set(buff.Cooldown, expirationTime - duration, duration, duration > 0, true);
			buff.Cooldown:SetHideCountdownNumbers(false)

			buff:Show();
			buffIndex = buffIndex + 1;
		end

		for i = buffIndex, BUFF_MAX_DISPLAY do
			if (self.buffList[i]) then
				self.buffList[i]:Hide();
			end
		end
	end

    if buffIndex == 1 then
        self:Hide()
    else
        self:Show()
    end

    self:Layout();
end

function JokPlates:ApplyCC(frame)
    local spellId, icon, start, expire

    -- Check if an aura was found
    if frame.aura.spellId then
        spellId, icon, start, expire = frame.aura.spellId, frame.aura.icon, frame.aura.start, frame.aura.expire
    end

    -- Check if there's an interrupt lockout
    if frame.interrupt.spellId then
        -- Make sure the lockout is still active
        if frame.interrupt.expire < GetTime() then
            frame.interrupt.spellId = nil
        -- Select the greatest priority (aura or interrupt)
        elseif spellId and priorityList[frame.interrupt.spellId] < priorityList[spellId] or not spellId then
            spellId, icon, start, expire = frame.interrupt.spellId, frame.interrupt.icon, frame.interrupt.start, frame.interrupt.expire
        end
    end

    -- Set up the icon & cooldown
    if spellId then
        CooldownFrame_Set(frame.cd, start, expire - start, 1, true)
        if spellId ~= frame.activeId then
            frame.activeId = spellId
            frame.icon:SetTexture(icon)
        end
    -- Remove cooldown & reset icon back to class icon
    elseif frame.activeId then
        frame.activeId = nil
        frame.icon:SetTexture(nil)
        CooldownFrame_Set(frame.cd, 0, 0, 0, true)
    end
end

function JokPlates:UpdateCC(frame)
    if not frame.displayedUnit then return end

    if UnitIsUnit(frame.displayedUnit, "player") then return end

    local priorityAura = {
        icon = nil,
        spellId = nil,
        duration = nil,
        expires = nil,
    }

    local duration, icon, expires, spellId, _

    for i = 1, BUFF_MAX_DISPLAY do
        _, icon, _, _, duration, expires, _, _, _, spellId = UnitAura(frame.displayedUnit, i, "HARMFUL")
        if not spellId then break end

        if priorityList[spellId] then
            -- Select the greatest priority aura
            if not priorityAura.spellId or priorityList[spellId] < priorityList[priorityAura.spellId] then
                priorityAura.icon = icon
                priorityAura.spellId = spellId
                priorityAura.duration = duration
                priorityAura.expires = expires
            end
        end
    end

    if priorityAura.spellId then
        frame.cc.aura.spellId = priorityAura.spellId
        frame.cc.aura.icon = priorityAura.icon
        frame.cc.aura.start = priorityAura.expires - priorityAura.duration
        frame.cc.aura.expire = priorityAura.expires
    else
        frame.cc.aura.spellId = nil
    end

    self:ApplyCC(frame.cc)
end

function JokPlates:UpdateInterrupts()
    local _, event,_,_,_,_,_, destGUID, _,_,_, spellId = CombatLogGetCurrentEventInfo()

    if not interrupts[spellId] then return end

    if event ~= "SPELL_INTERRUPT" and event ~= "SPELL_CAST_SUCCESS" then return end

    if event == "SPELL_INTERRUPT" then
        local _, _, icon = GetSpellInfo(spellId)
        local start = GetTime()
        local duration = interrupts[spellId]

        for _, namePlate in pairs(C_NamePlate.GetNamePlates(issecure())) do
            local frame = namePlate.UnitFrame
            local unit = frame.displayedUnit
            
            if not UnitIsUnit(frame.displayedUnit, "player") and UnitIsPlayer(frame.displayedUnit) then 
                if UnitGUID(unit) == destGUID then
                    frame.cc.interrupt.spellId = spellId
                    frame.cc.interrupt.icon = icon
                    frame.cc.interrupt.start = start
                    frame.cc.interrupt.expire = start + duration

                    self:ApplyCC(frame.cc)

                    C_Timer.After(duration, function()
                        self:UpdateCC(frame)
                    end)
                end
            end
        end
    end
end

function JokPlates:UpdateIcon(button, unit, index, filter)
    local name, icon, count, debuffType, duration, expire, _, canStealOrPurge, _, spellID, _, _, _, nameplateShowAll = UnitAura(unit, index, filter)

    if button.spellID ~= spellID or button.expire ~= expire or button.count ~= count or button.duration ~= duration then
        CooldownFrame_Set(button.cd, expire - duration, duration, true, true)
    end

    button.icon:SetTexture(icon)
    button.expire = expire
    button.duration = duration
    button.spellID = spellID
    button.canStealOrPurge = canStealOrPurge
    button.nameplateShowAll = nameplateShowAll

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:SetUnitAura(unit, index, filter)
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end)

    if canStealOrPurge then
        button.overlay:SetVertexColor(1, 1, 1)
        button.overlay:Show()
    else
        button.overlay:Hide()
    end

    if count and count > 1 then
        button.count:SetText(count)
    else
        button.count:SetText("")
    end

    --
    button:Show()
end

-----------------------------------------

function JokPlates:UpdateCastbar(frame)

    if ( frame:IsForbidden() ) then return end
    frame.castBar.Text:SetFont(SystemFont_Shadow_Small:GetFont(), 15, "OUTLINE")
    -- Castbar Timer.

    if ( not frame.castBar.CastTime ) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, "OVERLAY")
        frame.castBar.CastTime:Hide()
        frame.castBar.CastTime:SetPoint("LEFT", frame.castBar, "RIGHT", 4, 0)
        frame.castBar.CastTime:SetFont(SystemFont_Shadow_Small:GetFont(), 9, "OUTLINE")
        frame.castBar.CastTime:Show()
    end

    frame.castBar.update = 0.1

    frame.castBar.Icon:SetShown(true);

    -- Update Castbar.

    local lastUpdate = 0

    frame.castBar:HookScript("OnUpdate", function(self, elapsed)
        if not self.casting == nil or not self.channeling == nil then return end

        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= frame.castBar.update then
            lastUpdate = 0

            local name = UnitCastingInfo(frame.displayedUnit)
            if not name then                    
                name = UnitChannelInfo(frame.displayedUnit)
            end 

            if name and IsInGroup() and JokPlates.db.profile.castTarget then
                frame.castBar.Text:SetText(name)
                local targetUnit = frame.displayedUnit.."-target"
                for u in JokPlates:GroupMembers() do
                    if UnitIsUnit(targetUnit, u) then
                        local targetName = UnitName(targetUnit)
                        frame.castBar.Text:SetText(name .. JokPlates:SetTextColorByClass(targetName, targetName))
                    end
                end 
            end

            JokPlates:UpdateCastbarTimer(frame)
        end
    end)

    frame.castBar.BorderShield:SetTexture(nil)
end

-------------------------------------------------------------------------------
-- SKIN
-------------------------------------------------------------------------------

function JokPlates:PLAYER_ENTERING_WORLD()   
    -- Enemy Nameplates
    C_NamePlate.SetNamePlateEnemySize(self.settings.healthWidth, 40)

    -- Friendly Nameplates
    C_NamePlate.SetNamePlateFriendlySize(80, 0.1)
    C_NamePlate.SetNamePlateFriendlyClickThrough(true)

    -- Personal Nameplate
    C_NamePlate.SetNamePlateSelfSize(self.settings.personalWidth, 0.1)
    C_NamePlate.SetNamePlateSelfClickThrough(true)

    -- Class Nameplate Mana Bar
   -- ClassNameplateManaBarFrame:SetStatusBarTexture(statusBar)
    --print(ClassNameplateManaBarFrame.Texture:GetTexture())

    if ( not ClassNameplateManaBarFrame.text ) then
        ClassNameplateManaBarFrame.text = ClassNameplateManaBarFrame:CreateFontString("$parent.ResourceText", "OVERLAY")   
        ClassNameplateManaBarFrame.text:SetFont("FONTS\\FRIZQT__.TTF", 12, "OUTLINE")
        ClassNameplateManaBarFrame.text:SetPoint("CENTER", ClassNameplateManaBarFrame)
    end
end

-- NAMEPLATE 

function JokPlates:UpdateName(frame)
    if ( not ShouldShowName(frame) ) then
        frame.name:Hide();
    else
        local name = GetUnitName(frame.unit, true);

        frame.name:SetText(name);

        if ( CompactUnitFrame_IsTapDenied(frame) ) then
            frame.name:SetVertexColor(0.5, 0.5, 0.5);
        elseif ( frame.optionTable.colorNameBySelection ) then
            if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) ) then
                frame.name:SetVertexColor(1.0, 0.0, 0.0);
            else
                frame.name:SetVertexColor(UnitSelectionColor(frame.unit, frame.optionTable.colorNameWithExtendedColors));
            end
        end

        frame.name:Show();
    end

    frame.name:SetFont("Fonts\\FRIZQT__.TTF", 10)

    -- Class Player Name
    if ( UnitIsPlayer(frame.displayedUnit) ) then
        local _, class = UnitClass(frame.unit)
        local r, g, b = GetClassColor(class)
        frame.name:SetVertexColor(r, g, b);
    end
end

function JokPlates:UpdateHealth(frame)
    local health = UnitHealth(frame.displayedUnit)

    frame.healthBar:SetValue(health)
end

function JokPlates:UpdateMaxHealth(frame)
    local maxHealth = UnitHealthMax(frame.displayedUnit)

    frame.healthBar:SetMinMaxValues(0, maxHealth)
end

function JokPlates:UpdateHealthText(frame)
    if not UnitIsUnit(frame.displayedUnit, "player") then return end

    local health = UnitHealth(frame.displayedUnit)
    local maxHealth = UnitHealthMax(frame.displayedUnit)

    local perc = math.floor(100 * (health/maxHealth))

    if ( not frame.healthBar.LeftText or not frame.healthBar.RightText ) then return end    

    frame.healthBar.LeftText:Show()
    frame.healthBar.RightText:Show()
    
    if ( health >= 1 ) then
        frame.healthBar.LeftText:SetText(perc.."%")
        frame.healthBar.RightText:SetText(self:FormatValue(health))
    else
        frame.healthBar.LeftText:SetText("")
        frame.healthBar.RightText:SetText("")
    end
end

function JokPlates:UpdateSize(frame)
    if UnitIsPlayer(frame.unit) and not UnitCanAttack("player", frame.unit) and not UnitIsUnit("player", frame.unit) then
        frame.healthBar:SetHeight(5)
        frame.castBar:SetHeight(7)
    elseif not UnitIsUnit("player", frame.unit) then
        frame.healthBar:SetHeight(JokPlates.db.profile.healthHeight)
        frame.castBar:SetHeight(9)
    end
end

function JokPlates:UpdateColor(frame)
    local r, g, b

    if ( not UnitIsConnected(frame.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( frame.optionTable.healthBarColorOverride ) then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b

            if ( UnitIsUnit("player", frame.unit) ) then
                local localizedClass, englishClass = UnitClass(frame.unit)
                local classColor = RAID_CLASS_COLORS[englishClass]
                r, g, b = classColor.r, classColor.g, classColor.b
            end
        else
            local localizedClass, englishClass = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
            local raidMarker = GetRaidTargetIndex(frame.displayedUnit)

            if ( frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit) and classColor ) then
                r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                r, g, b = 0.5, 0.5, 0.5
            elseif ( colorList[frame.npcID] ) then
                r, g, b = JokPlates:DangerousColor(frame)
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( frame.optionTable.considerSelectionInCombatAsHostile and self:IsOnThreatListWithPlayer(frame.displayedUnit) ) then    
                    local target = frame.displayedUnit.."target"
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                    if ( isTanking and threatStatus ) then
                        if ( threatStatus >= 3 ) then
                            r, g, b = 0.5, 0.75, 0.95
                        elseif ( threatStatus == 2 ) then
                            r, g, b = 1.0, 0.6, 0.2
                        end
                    elseif ( self:UseOffTankColor(target) ) then
                        r, g, b = 1.0, 0.0, 1.0
                    else
                        r, g, b = 1.0, 0.0, 0.0
                    end
                else
                    r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors)
                end
            elseif ( UnitIsFriend("player", frame.unit) ) then
                r, g, b = 0.0, 1.0, 0.0
            else
                r, g, b = 1.0, 0.0, 0.0
            end
        end
    end

    local cR,cG,cB = frame.healthBar:GetStatusBarColor()
    if ( r ~= cR or g ~= cG or b ~= cB ) then

        if ( frame.optionTable.colorHealthWithExtendedColors ) then
            frame.selectionHighlight:SetVertexColor(r, g, b)
        else
            frame.selectionHighlight:SetVertexColor(1.0, 1.0, 1.0)
        end

        frame.healthBar:SetStatusBarColor(r, g, b)
    end
end

function JokPlates:UpdateSelectionHighlight(frame)
    local unit = frame.unit

    if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
        frame.selectionHighlight:Show()
        frame.healthBar.border:SetVertexColor(frame.optionTable.selectedBorderColor:GetRGBA());
    else
        frame.selectionHighlight:Hide()
        frame.healthBar.border:SetVertexColor(frame.optionTable.defaultBorderColor:GetRGBA());
    end
end

function JokPlates:UpdateBuffs(frame)
    local filter

    if UnitIsUnit("player", frame.displayedUnit) then
        filter = "HARMFUL";
    else
        filter = "HELPFUL";
    end

    -- Buffs
    local buffIndex = 1
    for i = 1, BUFF_MAX_DISPLAY do       
        local name, _, _, _, duration, expire, caster, canStealOrPurge, nameplateShowPersonal, spellID, _, isBossDebuff, castByPlayer, nameplateShowAll = UnitAura(frame.displayedUnit, i, filter)

        local flag = false

        if isBossDebuff then
            flag = true
        end

        if JokPlates.db.profile.spells.custom[spellID] and UnitIsUnit("player", frame.displayedUnit) then
            if JokPlates.db.profile.spells.custom[spellID].personal then
                flag = true
            end
        end

        if (JokPlates.db.profile.spells.buffs.purgeable and canStealOrPurge) then
            flag = true                 
        end

        if JokPlates.db.profile.spells.buffs[spellID] then
            flag = true
        end
        
        if JokPlates.db.profile.spells.custom[spellID] then
            if JokPlates.db.profile.spells.custom[spellID].all then
                flag = true
            end
        end

        if flag then
            if not frame.BuffFrame2.buffList[buffIndex] then
                frame.BuffFrame2.buffList[buffIndex] = self:CreateIcon(frame.BuffFrame2, "aura"..buffIndex, buffIndex)
            end
            self:UpdateIcon(frame.BuffFrame2.buffList[buffIndex], frame.displayedUnit, i, filter)
            buffIndex = buffIndex + 1
        end
    end

    for i = buffIndex, #frame.BuffFrame2.buffList do 
        frame.BuffFrame2.buffList[i]:Hide() 
    end
end

function JokPlates:UpdateHealPrediction(frame)
    local ABSORB_GLOW_ALPHA = 0.6;
    local ABSORB_GLOW_OFFSET = -3;

    CompactUnitFrame_UpdateHealPrediction(frame)

    local absorbBar = frame.totalAbsorb;
    if ( not absorbBar or absorbBar:IsForbidden()  ) then return end
    
    local absorbOverlay = frame.totalAbsorbOverlay;
    if ( not absorbOverlay or absorbOverlay:IsForbidden() ) then return end
    
    local healthBar = frame.healthBar;
    if ( not healthBar or healthBar:IsForbidden() ) then return end

    local _, maxHealth = healthBar:GetMinMaxValues();
    if ( maxHealth <= 0 ) then return end
    
    local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0;
    if( totalAbsorb > maxHealth ) then
        totalAbsorb = maxHealth;
    end

    absorbOverlay:SetParent(healthBar);
    absorbOverlay:SetDrawLayer("OVERLAY", 2)
    absorbOverlay:ClearAllPoints();     --we'll be attaching the overlay on heal prediction update.
    
    local absorbGlow = frame.overAbsorbGlow;
    if ( absorbGlow and not absorbGlow:IsForbidden() ) then
        absorbGlow:ClearAllPoints();
        absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0);
        absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0);
        absorbGlow:SetWidth(8);
        absorbGlow:SetDrawLayer("OVERLAY", 2)
    end
    
    if( totalAbsorb > 0 ) then  --show overlay when there's a positive absorb amount
        if ( absorbBar:IsShown() ) then     --If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
            absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0);
            absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0);
        else
            absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
            absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0);                  
        end

        local totalWidth, totalHeight = healthBar:GetSize();            
        local barSize = totalAbsorb / maxHealth * totalWidth;
        
        absorbOverlay:SetWidth( barSize );
        absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize);
        absorbOverlay:Show();
        absorbOverlay:SetDrawLayer("OVERLAY", 2)
    end
end

function JokPlates:SetUnit(frame, unit)
        frame.unit = unit
        frame.displayedUnit = unit -- For vehicles
        frame.inVehicle = false

        if (unit) then
            frame.unitGUID = UnitGUID(unit)
            frame.npcID = JokPlates:GetNpcID(unit)
            self:RegisterEvents(frame)
        else
            self:UnregisterEvents(frame)
            if ( frame.castBar ) then 
                CastingBarFrame_SetUnit(frame.castBar, nil, nil, nil);
            end
        end
        self:RefreshNameplate(frame)
end

function JokPlates:RefreshNameplate(frame)
    if ( UnitExists(frame.displayedUnit) ) then
        self:UpdateName(frame)
        self:UpdateMaxHealth(frame)
        self:UpdateHealth(frame)
        self:UpdateColor(frame)
        self:UpdateSize(frame)
        self:UpdateSelectionHighlight(frame)
        self:UpdateCC(frame)
        self:UpdateBuffs(frame)
        self:UpdateHealthText(frame)
        self:UpdateHealPrediction(frame)
    end
end

function JokPlates:UpdateAllNameplates()
    for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        self:RefreshNameplate(frame)
    end 
end

function JokPlates_OnEvent(frame, event, ...)
    local arg1, arg2, arg3, arg4 = ...
    local self = JokPlates

    if (event == "PLAYER_TARGET_CHANGED") then
        self:UpdateSelectionHighlight(frame)
    elseif ( event == "UNIT_FACTION" ) then
        self:UpdateAllNameplates(frame)
    elseif (arg1 == frame.unit or arg1 == self.displayedUnit) then
        if ( event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" ) then
            self:UpdateHealth(frame)
            self:UpdateHealthText(frame)
            self:UpdateHealPrediction(frame)
        elseif (event == "UNIT_MAXHEALTH") then
            self:UpdateMaxHealth(frame)
            self:UpdateHealth(frame)
            self:UpdateHealthText(frame)
            self:UpdateHealPrediction(frame)
        elseif (event == "UNIT_NAME_UPDATE") then
            self:UpdateName(frame)
            self:UpdateColor(frame) 
        elseif (event == "UNIT_THREAT_LIST_UPDATE") then
            if ( frame.optionTable.considerSelectionInCombatAsHostile ) then
                self:UpdateColor(frame);
                self:UpdateName(frame);
            end
        elseif ( event == "UNIT_HEAL_PREDICTION" ) then
           self:UpdateHealPrediction(frame)
        elseif ( event == "UNIT_ABSORB_AMOUNT_CHANGED" ) then
            self:UpdateHealPrediction(frame)
        elseif ( event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" ) then
            self:UpdateHealPrediction(frame)
        elseif ( event == "UNIT_AURA") then
            self:UpdateCC(frame)
            self:UpdateBuffs(frame)
        end
    end
end

function JokPlates:RegisterEvents(frame)
    local unit = frame.unit

    frame:RegisterEvent("PLAYER_TARGET_CHANGED");
    frame:RegisterEvent("UNIT_FACTION");
    frame:RegisterEvent("UNIT_HEALTH_FREQUENT");
    frame:RegisterEvent("UNIT_HEALTH");
    frame:RegisterEvent("UNIT_MAXHEALTH");
    frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    frame:RegisterEvent("UNIT_NAME_UPDATE")
    frame:RegisterEvent("UNIT_HEAL_PREDICTION")  
    frame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
    frame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED");
    frame:RegisterEvent("UNIT_AURA");

    self:RegisterUnitEvents(frame)

    frame:SetScript("OnEvent", JokPlates_OnEvent)
end

function JokPlates:RegisterUnitEvents(frame)
    local unit = frame.unit;
    local displayedUnit;
    if ( unit ~= frame.displayedUnit ) then
        displayedUnit = frame.displayedUnit;
    end

    frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit, displayedUnit);
    frame:RegisterUnitEvent("UNIT_HEALTH", unit, displayedUnit);
    frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit, displayedUnit);
    frame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit);
    frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit, displayedUnit);
    frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit);
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit, displayedUnit);
end

function JokPlates:UnregisterEvents(frame)
    frame:UnregisterAllEvents()
    frame:SetScript("OnEvent", nil)
end

-- EVENTS

function JokPlates:NAME_PLATE_CREATED(_, namePlate)
    local frame = namePlate.UnitFrame
    frame.isNameplate = true

    if ( frame:IsForbidden() ) then return end

    frame.unit = nil
    frame.displayedUnit = nil -- For vehicles
    frame.inVehicle = nil

    self:UpdateCastbar(frame)
    self:AddHealthbarText(namePlate)

    -- Hook UpdateBuffs
    frame.BuffFrame.UpdateBuffs = JokPlates_UpdateBuffs

    -- Hook UpdateAnchor
    function frame.BuffFrame:UpdateAnchor()
        if not frame.displayedUnit then return end  

        local offset = 0

        local isTarget = UnitIsUnit(frame.displayedUnit, "target");
        local targetMode = GetCVarBool("nameplateResourceOnTarget");

        if targetMode and isTarget then
            offset = 18
        end

        if UnitIsUnit(frame.displayedUnit, "player") then --player plate
            --self:ClearAllPoints()
            self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 3);
        elseif not frame.healthBar:IsShown() then -- no healthbar
            self:SetPoint("BOTTOM", frame.name, "TOP", 0, 2+offset);
        elseif frame.healthBar:IsShown() and frame.name:IsShown() then -- healthbar
            self:SetPoint("BOTTOM", frame.name, "TOP", 0, 3+offset);
        elseif frame.healthBar:IsShown() then
            self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 4+offset);
        end
    end

    -- ICON
    frame.icon = frame:CreateTexture(nil, "OVERLAY")

    -- CC FRAME
    frame.cc = CreateFrame("Frame", "$parent.CC", frame)
    frame.cc:SetPoint("LEFT", frame.healthBar, "RIGHT", 3, 2)   
    frame.cc:SetWidth(24)
    frame.cc:SetHeight(24)
    frame.cc:SetFrameLevel(frame:GetFrameLevel())   
    frame.cc.activeId = nil
    frame.cc.aura = { spellId = nil, icon = nil, start = nil, expire = nil }
    frame.cc.interrupt = { spellId = nil, icon = nil, start = nil, expire = nil }

    frame.cc.icon = frame.cc:CreateTexture(nil, "OVERLAY", nil, 3)
    frame.cc.icon:SetAllPoints(frame.cc)

    frame.cc.cd = CreateFrame("Cooldown", nil, frame.cc, "CooldownFrameTemplate")
    frame.cc.cd:SetAllPoints(frame.cc)
    frame.cc.cd:SetDrawEdge(false)
    frame.cc.cd:SetAlpha(1)
    frame.cc.cd:SetDrawSwipe(true)
    frame.cc.cd:SetReverse(true)

    -- BUFF FRAME
    frame.BuffFrame2 = CreateFrame("Frame", "$parent.DebuffFrame", frame)
    frame.BuffFrame2:SetPoint("BOTTOMLEFT", frame.BuffFrame, "TOPLEFT", 0, 3)  
    frame.BuffFrame2:SetWidth(130)
    frame.BuffFrame2:SetHeight(14)
    frame.BuffFrame2:SetFrameLevel(namePlate:GetFrameLevel())
    frame.BuffFrame2:SetScale(JokPlates.db.profile.buffFrameScale)

    frame.BuffFrame2.buffList = {}        
    frame.BuffFrame2.buffActive = {}

    frame.BuffFrame2.LineUpIcons = function()
        local lastframe
        for v, f in self:PairsByKeys(frame.BuffFrame2.buffActive) do
            f:ClearAllPoints()
            if not lastframe then
                local num = 0
                for k, j in pairs(frame.BuffFrame2.buffActive) do
                    num = num + 1
                end
                f:SetPoint("LEFT", frame.BuffFrame2, "LEFT", 0,0)
            else
                f:SetPoint("LEFT", lastframe, "RIGHT", 4, 0)
            end

            lastframe = f
        end
    end
    
    frame.BuffFrame2.QueueIcon = function(button, tag)
        button.v = tag
        
        button:SetScript("OnShow", function()
            frame.BuffFrame2.buffActive[button.v] = button
            frame.BuffFrame2.LineUpIcons()
        end)
        
        button:SetScript("OnHide", function()
            frame.BuffFrame2.buffActive[button.v] = nil
            frame.BuffFrame2.LineUpIcons()
        end)
    end
end

function JokPlates:NAME_PLATE_UNIT_ADDED(_, unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local frame = namePlate.UnitFrame

    if ( frame:IsForbidden() ) then return end

    self:SetUnit(frame, unit)
    self:RefreshNameplate(frame)

    frame.RaidTargetFrame:SetScale(1.2)
    frame.RaidTargetFrame:SetPoint("RIGHT", frame.healthBar, "LEFT", -7, 0)

    -- Glow Nameplate
    if glowList[frame.npcID] then
        self:GlowNameplate(frame, true)
    end

    -- Icon
    if iconList[frame.npcID] then
        self:SetIcon(frame, 30, true)
    end

    if UnitIsUnit(frame.displayedUnit, "player") then
        frame.healthBar:SetHeight(self.settings.personalHealthHeight)
        ClassNameplateManaBarFrame:SetSize(JokPlates.db.profile.personalWidth, JokPlates.db.profile.personalManaHeight)
        frame.BuffFrame2:SetScale(1.2)
    end
end

function JokPlates:NAME_PLATE_UNIT_REMOVED(_, unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local frame = namePlate.UnitFrame

    if ( frame:IsForbidden() ) then return end

    self:SetUnit(frame, nil)

    if frame.icon.active then
        self:SetIcon(frame, 30, false)
    end

    if frame.isGlowing then
        self:GlowNameplate(frame, false)
    end

    frame.healthBar.LeftText:Hide()
    frame.healthBar.RightText:Hide()

    --CastingBarFrame_SetUnit(frame.castBar, nil, false, true)
end

function JokPlates:COMBAT_LOG_EVENT_UNFILTERED()
    self:UpdateInterrupts()

    if IsInGroup() then
        local time, event, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()
        if event == "SPELL_INTERRUPT" and self.settings.castInterrupt then
            for _, namePlate in ipairs (C_NamePlate.GetNamePlates()) do
                local token = namePlate.namePlateUnitToken
                if (namePlate.UnitFrame.castBar:IsShown()) then
                    if (namePlate.UnitFrame.castBar.Text:GetText() == INTERRUPTED) then
                        if (UnitGUID(token) == targetGUID) then
                            --Attribute Pet Spell's to its owner
                            local type = strsplit("-",sourceGUID)
                            if type == "Pet" then
                                for unit in self:GroupMembers() do
                                    if UnitGUID(unit.."pet") == sourceGUID then
                                        sourceGUID = UnitGUID(unit)                        
                                        sourceName = UnitName(unit)
                                        sourceName = gsub(sourceName, "%-[^|]+", "")
                                        break
                                    end
                                end
                            end   
                            namePlate.UnitFrame.castBar.Text:SetText (INTERRUPTED .. self:SetTextColorByClass(sourceName, sourceName))
                        end
                    end
                end
            end
        end       
    end
end

function JokPlates:UNIT_FACTION()  
    --self:UpdateAllNameplates()
end

function JokPlates:UPDATE_MOUSEOVER_UNIT()
    local namePlate = C_NamePlate.GetNamePlateForUnit('mouseover')
    if not namePlate then return end
    local frame = namePlate.UnitFrame

    if ( frame:IsForbidden() ) then return end

    if UnitIsUnit(frame.displayedUnit, "target") or UnitIsUnit(frame.displayedUnit, "player") then return end

    local function SetBorderColor(frame, r, g, b, a)
        frame.healthBar.border:SetVertexColor(r, g, b, a);
    end

    frame.selectionHighlight:Show()
    SetBorderColor(frame, frame.optionTable.selectedBorderColor:GetRGBA());

    frame:SetScript('OnUpdate', function(frame)
        if not UnitExists('mouseover') or not UnitIsUnit('mouseover', frame.displayedUnit) then   
            if not UnitIsUnit(frame.displayedUnit, "target") then
                frame.selectionHighlight:Hide()
                SetBorderColor(frame, frame.optionTable.defaultBorderColor:GetRGBA());
            end
            frame:SetScript('OnUpdate',nil)
        end
    end)
end

function JokPlates:SetupClassNameplateBar(self, OnTarget, Bar)
    if OnTarget then return end

	if self.classNamePlateMechanicFrame then
        self.classNamePlateMechanicFrame:SetScale(1.1)
    end
end

function JokPlates:NamePlateDriverFrame_UpdateNamePlateOptions()
    ClassNameplateManaBarFrame:SetSize(JokPlates.db.profile.personalWidth, JokPlates.db.profile.personalManaHeight)
end

function JokPlates:ClassNameplateManaBar_OnUpdate(self)
    local castingSpellID = select(9, UnitCastingInfo('player'))

    if not castingSpellID then 
        if ( self.currValue ~= tonumber(self.text:GetText()) ) then
            self.text:SetText(JokPlates:FormatValue(self.currValue))
        end
        return 
    end

    local predictedValue = self.currValue

    if PowerPrediction[self.powerType] then
        for spellID, spell in pairs(PowerPrediction[self.powerType]) do
            if castingSpellID == spellID then
                predictedValue = self.currValue + spell.power
            end
        end
    end

    if ( self.currValue ~= predictedValue ) then
        self.FeedbackFrame:StartFeedbackAnim(self.currValue or 0, predictedValue);
        self.text:SetText(JokPlates:FormatValue(predictedValue))
    end 
end

function JokPlates:ClassNameplateManaBarFrame_OnOptionsUpdated()
    ClassNameplateManaBarFrame:SetSize(JokPlates.db.profile.personalWidth, JokPlates.db.profile.personalManaHeight)
end

function JokPlates:DefaultCompactNamePlateFrameSetup(frame, options)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    frame.castBar.Text:SetFont("Fonts\FRIZQT__.TTF", 8)
    frame.castBar.Text:SetShadowOffset(0.5, -0.5)
end

function JokPlates:DefaultCompactNamePlateFrameAnchorInternal(frame, setupOptions)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    if UnitIsPlayer(frame.unit) and not UnitCanAttack("player", frame.unit) and not UnitIsUnit("player", frame.unit) then
        frame.healthBar:SetHeight(5)
        frame.castBar:SetHeight(7)
    else
        frame.healthBar:SetHeight(JokPlates.db.profile.healthHeight)
        frame.castBar:SetHeight(9)
    end

    frame.castBar.Icon:SetSize(JokPlates.db.profile.healthHeight*2, JokPlates.db.profile.healthHeight*2)
    frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.castBar.Icon:ClearAllPoints()
    frame.castBar.Icon:SetPoint("BOTTOMRIGHT", frame.castBar, "BOTTOMLEFT", -1, 0)
end

SLASH_JokPlates1 = "/jokplates"
SLASH_JokPlates2 = "/jp"
SlashCmdList.JokPlates = function(msg)
	InterfaceOptionsFrame_OpenToCategory("|cffFF7D0AJok|rPlates")
	InterfaceOptionsFrame_OpenToCategory("|cffFF7D0AJok|rPlates")
end
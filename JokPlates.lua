JokPlates = LibStub("AceAddon-3.0"):NewAddon("JokPlates", "AceEvent-3.0", "AceHook-3.0")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local _, class = UnitClass("player")

local castbarFont = SystemFont_Shadow_Small:GetFont()
local statusBar = "Interface\\AddOns\\JokPlates\\media\\UI-StatusBar"

local nameplates_defaults = {
    profile = {
        enable = true,
        nameSize = 9,
        friendlyName = true,
        arenanumber = true,
        globalScale = 1,
        targetScale = 1,
        importantScale = 1.2,
        sticky = true,
        nameplateAlpha = 1,
        nameplateRange = 60,
        overlap = true,
        verticalOverlap = 0.9,
        horizontalOverlap = 0.7,
        friendlymotion = true,
        clickthroughfriendly = true,
        enemytotem = true,
        enemypets = false,
        enemyguardian = false,
        enemyminus = false, 
        healthWidth = 120,
        healthHeight = 7,
        largerNameplates = false,
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
        },                        
    }
}

local nameplates_buffs = {

    -- BUFFS/DEBUFFS

        -- Mythic+ (Buffs)
            [277242] = {category = "Mythic +" }, -- Infested (G'huun)
            [209859] = {category = "Mythic +" }, -- Bolster (Affix)
            [226510] = {category = "Mythic +" }, -- Sanguine Ichor (Affix)
            [263246] = {category = "Mythic +" }, -- Lightning Shield (Temple of Sethralis)
            [260805] = {category = "Mythic +" }, -- Claim The Iris (Waycrest Manor)

    -- PVP BUFFS

        -- Death Knight
            [47568] = {class = "DEATHKNIGHT" }, -- Empower Runic Weapon
            [51271] = {class = "DEATHKNIGHT" }, -- Pillar of Frost
            [207289] = {class = "DEATHKNIGHT" }, -- Unholy Frenzy
            [152279] = {class = "DEATHKNIGHT" }, -- Breath of Sindragosa
            [48707] = {class = "DEATHKNIGHT" }, -- AMS
            [48792] = {class = "DEATHKNIGHT" }, -- IBF

        -- Demon Hunter
            [212800] = {class = "DEMONHUNTER" }, -- Blur
            [196555] = {class = "DEMONHUNTER" }, -- Netherwalk

        -- Druid
            [194223] = {class = "DRUID" }, -- Celestial Alignment
            [22812] = {class = "DRUID" }, -- Barskin
            [61336] = {class = "DRUID" }, -- Survival Instincts
            [102342] = {class = "DRUID" }, -- Ironbark
            [102560] = {class = "DRUID" }, -- Incarn (MK)
            [102543] = {class = "DRUID" }, -- Incarn (Feral)
            [236696] = {class = "DRUID" }, -- Thorns

        -- Hunter       	
        	[53480] = {class = "HUNTER" }, -- Roar of Sacrifice
            [193526] = {class = "HUNTER" }, -- Trueshot
            [19574] = {class = "HUNTER" }, -- Bestial Wrath
            [186265] = {class = "HUNTER" }, -- Turtle
            [266779] = {class = "HUNTER" }, -- Coordinated Assault            

        -- Mage
            [12472] = {class = "MAGE" }, -- Icy Veins
            [190319] = {class = "MAGE" }, -- Combustion
            [12042] = {class = "MAGE" }, -- Arcane Power
            [45438] = {class = "MAGE" }, -- Ice Block
            [198111] = {class = "MAGE" }, -- Temporal Shield

        -- Monk
            [201318] = {class = "MONK" }, -- Fortifying Brew
            [116849] = {class = "MONK" }, -- Life Cocoon
            [122278] = {class = "MONK" }, -- Dampen Harm
            [122470] = {class = "MONK" }, -- Touch of Karma
            [122783] = {class = "MONK" }, -- Diffuse Magic
            [137639] = {class = "MONK" }, -- Storm, Earth, and Fire
            [216113] = {class = "MONK" }, -- Way of the Crane

        -- Paladin
            [31884] = {class = "PALADIN" }, -- Avenging Wrath
            [216331] = {class = "PALADIN" }, -- Avenging Wrath
            [210294] = {class = "PALADIN" }, -- Divine Favor
            [1022] = {class = "PALADIN" }, -- Blessing of Protection
            [31821] = {class = "PALADIN" }, -- Aura Mastery
            [6940] = {class = "PALADIN" }, -- Sacrifice
            [199448] = {class = "PALADIN" }, -- Ultimate Sacrifice
            [498] = {class = "PALADIN" }, -- Divine Protection
            [642] = {class = "PALADIN" }, -- Divine Shield
            [1044] = {class = "PALADIN" }, -- Blessing of Freedom
            [184662] = {class = "PALADIN" }, -- Shield of Vengeance

        -- Priest
            [200183] = {class = "PRIEST" }, -- Apotheosis
            [33206] = {class = "PRIEST" }, -- Pain Suppression
            [47788] = {class = "PRIEST" }, -- Guardian Spirit
            [47536] = {class = "PRIEST" }, -- Rapture
            [47585] = {class = "PRIEST" }, -- Dispersion
            [197862] = {class = "PRIEST" }, -- Archangel
            [197862] = {class = "PRIEST" }, -- Holy Concentration
            [197871] = {class = "PRIEST" }, -- Dark Archangel
            [213610] = {class = "PRIEST" }, -- Holy Ward
            [213602] = {class = "PRIEST" }, -- Greater Fade
            [15286] = {class = "PRIEST" }, -- Vampiric Embrace

        -- Rogue
            [199754] = {class = "ROGUE" }, -- Riposte
            [5277] = {class = "ROGUE" }, -- Evasion
            [1966] = {class = "ROGUE" }, -- Feint
            [31224] = {class = "ROGUE" }, -- Cloak of Shadows
            [13750] = {class = "ROGUE" }, -- Adrenaline Rush
            [121471] = {class = "ROGUE" }, -- Shadow Blades

        -- Shaman
            [2825] = {class = "SHAMAN" }, -- Bloodlust
            [108271] = {class = "SHAMAN" }, -- Astral Shift
            [79206] = {class = "SHAMAN" }, -- Spiritwalker's Grace 60 * OTHER
            [114050] = {class = "SHAMAN" }, -- Ascendance (Elemental)
			[114051] = {class = "SHAMAN" }, -- Ascendance (Enhancement)
			[114052] = {class = "SHAMAN" }, -- Ascendance (Restoration)

        -- Warlock
            [212295] = {class = "WARLOCK" }, -- Nether Ward
            [104773] = {class = "WARLOCK" }, -- Unending Resolve
            [196098] = {class = "WARLOCK" }, -- Soul Harvest
            [113860] = {class = "WARLOCK" }, -- Dark Soul: Misery (Affliction)
			[113858] = {class = "WARLOCK" }, -- Dark Soul: Instability (Demonology)

        -- Warrior 
            [118038] = {class = "WARRIOR" }, -- Die by the Sword
            [184364] = {class = "WARRIOR" }, -- Enraged Regeneration
            [23920] = {class = "WARRIOR" }, -- Spell Reflect
            [216890] = {class = "WARRIOR" }, -- Spell Reflection (Arms, Fury)
            [97462] = {class = "WARRIOR" }, -- Rallying Cry
            [107574] = {class = "WARRIOR" }, -- Avatar
            [1719] = {class = "WARRIOR" }, -- Recklessness
            [227847] = {class = "WARRIOR" }, -- Bladestorm
            [46924] = {class = "WARRIOR" }, -- Bladestorm (Fury)
            [197690] = {class = "WARRIOR" }, -- Def Stance
};

local nameplates_debuffs = {
	-- Azerite
        [280817] = {category = "Azerite" }, -- Battlefield Focus

   	-- Mythic+ (Debuffs)
        [256493] = {category = "Mythic +" }, -- Blazing Azerite (The MOTHERLODE!!!)
        [277965] = {category = "Mythic +" }, -- Heavy Ordnance (Siege)

	-- Add some missing class debuffs 
	-- Priest
    	[214621] = {class = "PRIEST" }, -- Schism

    -- Mage
        [228358] = {class = "MAGE" }, -- Flurry

    -- Rogue
        [79140] = {class = "ROGUE" }, -- Vendetta
};

local nameplates_personal = {

    -- PERSONAL NAMEPLATE

    -- Azerite
        [280204] = {category = "Azerite" }, -- Blightborn Infusion

    -- Druid
        [277185] = {class = "DRUID" }, -- Dread Gladiator Badge
        [202425] = {class = "DRUID" }, -- Warrior of Elune
        [287790] = {class = "DRUID" }, -- Arcanic Pulsar

    -- Priest
        [194249] = {class = "PRIEST" }, -- Void Form   
        [288343] = {class = "PRIEST" }, -- Mind Sear Proc  
        [275544] = {class = "PRIEST" }, -- Depth of Shadow  
};

-- Table for specific npcid color / TODO : Add Moblist colors to options
local moblist = {
    -- Mythic +
        -- Atal'dazar   
            [127757] = {tag = "DANGEROUS"}, -- Reanimated Honor Guard
            [122971] = {tag = "DANGEROUS"}, -- Dazar'ai Juggernaut
            [128434] = {tag = "DANGEROUS"}, -- Feasting Skyscreamer

        -- Freehold
            [127111] = {tag = "DANGEROUS"}, -- Irontide Oarsman
            [129527] = {tag = "DANGEROUS"}, -- Bilge Rat Buccaneer

        -- King's Rest
            [134174] = {tag = "DANGEROUS"}, -- Shadow-Borne Witch Doctor
            [135167] = {tag = "DANGEROUS"}, -- Spectral Berserker   
            [135235] = {tag = "DANGEROUS"}, -- Spectral Beastmaster
            [137591] = {tag = "DANGEROUS"}, -- Healing Tide Totem
            [135764] = {tag = "DANGEROUS"}, -- Explosive Totem

        -- Siege of Boralus
            [138255] = {tag = "OTHER"}, -- Ashvane Spotter
            [128969] = {tag = "DANGEROUS"}, -- Ashvane Commander
            [138465] = {tag = "DANGEROUS"}, -- Ashvane Cannoneer
            [132530] = {tag = "DANGEROUS"}, -- Kul Tiran Vanguard

        -- Temple of Sethralis 
            [135846] = {tag = "OTHER"}, -- Sand-Crusted Striker
            [134364] = {tag = "DANGEROUS"}, -- Faithless Tender
            [139946] = {tag = "DANGEROUS"}, -- Heart Guardian
            [135007] = {tag = "DANGEROUS"}, -- Orb Guardian

        -- The Underrot
            [130909] = {tag = "DANGEROUS"}, -- Fetid Maggot
                
    [144085] = {tag = "DANGEROUS"}, -- Training Dummy
    [144086] = {tag = "OTHER"}, -- Training Dummy
}

-- Totem list to anchor icon to nameplate / TODO : Add totem list to options
local totemlist = {
        [5925] = {icon = 136039}, -- Grounding Totem
        [105427] = {icon = 135829}, -- Skyfury Totem
        [2630] = {icon = 136102}, -- Earthbind Totem
        [53006] = {icon = 237586}, -- Spirit Link Totem   
        [60561] = {icon = 136100}, -- Earthgrab Totem   
        [61245] = {icon = 136013}, -- Capacitor Totem
        
        [101398] = {icon = 537021}, -- Psyfiend

        [119052] = {icon = 603532}, -- War Banner    
}

local PowerPrediction = {
    [8] = { -- Astral Power
        [194153] = {power = 12}, -- Lunar Strike
        [190984] = {power = 8}, -- Solar Wrath
        [202347] = {power = 8}, -- Stellar Flare
        [274281] = {power = 10}, -- New Moon
        [274282] = {power = 20}, -- Half Moon
        [274282] = {power = 40}, -- Full Moon
    },
    [13] = { -- Insanity
        [205351] = {power = 15}, -- Void Blast
        [8092] = {power = 12}, -- Mind Blast
        [34914] = {power = 6}, -- Vampiric Touch
        [263346] = {power = 30}, -- Dark Void
    },
}

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

function JokPlates:Refresh()
	for spellID, spell in pairs(nameplates_buffs) do
		if self.settings.spells.buffs[spellID] == nil then
			self.settings.spells.buffs[spellID] = true
		end
	end
	for spellID, spell in pairs(nameplates_debuffs) do
		if self.settings.spells.debuffs[spellID] == nil then
			self.settings.spells.debuffs[spellID] = true
		end
	end
	for spellID, spell in pairs(nameplates_personal) do
		if self.settings.spells.personal[spellID] == nil then
			self.settings.spells.personal[spellID] = true
		end
	end
end

function JokPlates:SetupOptions()
	local spells = {
		buffFrameScale = {
            type = "range",
            isPercent = true,
            name = "Buff Frame Scale",
            desc = "",
            min = 0.5,
            max = 1.5,
            step = 0.1,
            order = 1,
            set = function(info,val) 
                self.settings.buffFrameScale = val
                JokPlates:ForceUpdate()
            end,
            get = function(info) return self.settings.buffFrameScale end
        },
		buffs = {
			name = "Buffs",
			type = "group",
			order = 1,
			args = {
				purgeable = {
			        type = "toggle",
			        name = "Show Purgeable Buffs",
			        desc = "|cffaaaaaaWill show all purgeable buffs (if your class can purge it).",
			        descStyle = "inline",
			        width = "full",
			        set = function(info, val) JokPlates.db.profile.spells.buffs.purgeable = val end,
					get = function(info) return JokPlates.db.profile.spells.buffs.purgeable end,	
			        order = 4,
			    },
			},
		},
		debuffs = {
			name = "Debuffs",
			type = "group",
			order = 2,
			args = {},
		},
		personal = {
			name = "Personal Nameplate",
			type = "group",
			order = 3,
			args = {},
		}
	}
		
	for i = 1, MAX_CLASSES do

		for spellID, spell in pairs(nameplates_buffs) do
			local key = "spell"..spellID
			if spell.class and spell.class == CLASS_SORT_ORDER[i] then
				spells["buffs"].args[CLASS_SORT_ORDER[i]] = spells["buffs"].args[CLASS_SORT_ORDER[i]] or {
					name = LOCALIZED_CLASS_NAMES_MALE[CLASS_SORT_ORDER[i]],
					type = "group",
					args = {},
					icon = "Interface\\Icons\\ClassIcon_"..CLASS_SORT_ORDER[i],
				}	

				spells["buffs"].args[CLASS_SORT_ORDER[i]].args[key] = {
					type = "toggle",		
					width = "full",
					--arg = spellID,
					set = function(info, val) JokPlates.db.profile.spells.buffs[spellID] = val end,
					get = function(info) return JokPlates.db.profile.spells.buffs[spellID] end,				
					desc = function()
						local spellDesc = GetSpellDescription(spellID)
						local extra = "\n\n|cffffd700".."SpellID:".."|r "..spellID
						return spellDesc..extra
					end,
					name = function()
						return format("|T%s:20|t %s", GetSpellTexture(spellID), GetSpellInfo(spellID))
					end,
				}
			elseif spell.category then
				spells["buffs"].args[spell.category] = spells["buffs"].args[spell.category] or {
					name = spell.category,
					type = "group",
					order = 40,
					args = {},
					icon = function() 
						local icon 
						if spell.category == "Mythic +" then 
							icon = 'Interface\\MINIMAP\\Dungeon' 
						end
						return icon 
					end,
				}
				spells["buffs"].args[spell.category].args[key] = {
					type = "toggle",		
					width = "full",
					set = function(info, val) JokPlates.db.profile.spells.buffs[spellID] = val end,
					get = function(info) return JokPlates.db.profile.spells.buffs[spellID] end,
					desc = function()
						local spellDesc = GetSpellDescription(spellID)
						local extra = "\n\n|cffffd700".."SpellID:".."|r "..spellID
						return spellDesc..extra
					end,
					name = function()
						return format("|T%s:20|t %s", GetSpellTexture(spellID), GetSpellInfo(spellID))
					end,
				}
			end
		end

		for spellID, spell in pairs(nameplates_debuffs) do
			local key = "spell"..spellID
			if spell.class and spell.class == CLASS_SORT_ORDER[i] then
				spells["debuffs"].args[CLASS_SORT_ORDER[i]] = spells["debuffs"].args[CLASS_SORT_ORDER[i]] or {
					name = LOCALIZED_CLASS_NAMES_MALE[CLASS_SORT_ORDER[i]],
					type = "group",
					args = {},
					icon = "Interface\\Icons\\ClassIcon_"..CLASS_SORT_ORDER[i],
				}

				spells["debuffs"].args[CLASS_SORT_ORDER[i]].args[key] = {
					type = "toggle",		
					width = "full",
					--arg = spellID,
					set = function(info, val) JokPlates.db.profile.spells.debuffs[spellID] = val end,
					get = function(info) return JokPlates.db.profile.spells.debuffs[spellID] end,				
					desc = function()
						local spellDesc = GetSpellDescription(spellID)
						local extra = "\n\n|cffffd700".."SpellID:".."|r "..spellID
						return spellDesc..extra
					end,
					name = function()
						return format("|T%s:20|t %s", GetSpellTexture(spellID), GetSpellInfo(spellID))
					end,
				}
			elseif spell.category then
				spells["debuffs"].args[spell.category] = spells["debuffs"].args[spell.category] or {
					name = spell.category,
					type = "group",
					order = 40,
					args = {},
					icon = function() 
						local icon 
						if spell.category == "Mythic +" then 
							icon = 'Interface\\MINIMAP\\Dungeon'
						elseif spell.category == "Azerite" then
							icon = 1869493 
						end
						return icon 
					end,
				}
				spells["debuffs"].args[spell.category].args[key] = {
					type = "toggle",		
					width = "full",
					set = function(info, val) JokPlates.db.profile.spells.debuffs[spellID] = val end,
					get = function(info) return JokPlates.db.profile.spells.debuffs[spellID] end,
					desc = function()
						local spellDesc = GetSpellDescription(spellID)
						local extra = "\n\n|cffffd700".."SpellID:".."|r "..spellID
						return spellDesc..extra
					end,
					name = function()
						return format("|T%s:20|t %s", GetSpellTexture(spellID), GetSpellInfo(spellID))
					end,
				}
			end
		end

		for spellID, spell in pairs(nameplates_personal) do
			local key = "spell"..spellID
			if spell.class and spell.class == CLASS_SORT_ORDER[i] then
				spells["personal"].args[CLASS_SORT_ORDER[i]] = spells["personal"].args[CLASS_SORT_ORDER[i]] or {
					name = LOCALIZED_CLASS_NAMES_MALE[CLASS_SORT_ORDER[i]],
					type = "group",
					args = {},
					icon = "Interface\\Icons\\ClassIcon_"..CLASS_SORT_ORDER[i],
				}

				spells["personal"].args[CLASS_SORT_ORDER[i]].args[key] = {
					type = "toggle",		
					width = "full",
					--arg = spellID,
					set = function(info, val) JokPlates.db.profile.spells.personal[spellID] = val end,
					get = function(info) return JokPlates.db.profile.spells.personal[spellID] end,				
					desc = function()
						local spellDesc = GetSpellDescription(spellID)
						local extra = "\n\n|cffffd700".."SpellID:".."|r "..spellID
						return spellDesc..extra
					end,
					name = function()
						return format("|T%s:20|t %s", GetSpellTexture(spellID), GetSpellInfo(spellID))
					end,
				}
			elseif spell.category then
				spells["personal"].args[spell.category] = spells["personal"].args[spell.category] or {
					name = spell.category,
					type = "group",
					order = 40,
					args = {},
					icon = function() 
						local icon 
						if spell.category == "Mythic +" then 
							icon = 'Interface\\MINIMAP\\Dungeon'
						elseif spell.category == "Azerite" then
							icon = 1869493 
						end
						return icon 
					end,
				}
				spells["personal"].args[spell.category].args[key] = {
					type = "toggle",		
					width = "full",
					set = function(info, val) JokPlates.db.profile.spells.personal[spellID] = val end,
					get = function(info) return JokPlates.db.profile.spells.personal[spellID] end,
					desc = function()
						local spellDesc = GetSpellDescription(spellID)
						local extra = "\n\n|cffffd700".."SpellID:".."|r "..spellID
						return spellDesc..extra
					end,
					name = function()
						return format("|T%s:20|t %s", GetSpellTexture(spellID), GetSpellInfo(spellID))
					end,
				}
			end
		end
	end

	self.options = {
		name = "JokPlates",
		descStyle = "inline",
		type = "group",
		childGroups = "tab",
		args = {
			desc = {
				type = "description",
				name = "Blizzard Nameplates Enhancement.",
				fontSize = "medium",
				order = 1
			},
			author = {
				type = "description",
				name = "\n|cffffd100Author: |r Kygo @ EU-Hyjal",
				order = 2
			},
			version = {
				type = "description",
				name = "|cffffd100Version: |r" .. GetAddOnMetadata("JokPlates", "Version") .."\n",
				order = 3
			},
			size = {
				name = "Size",
				order = 1,
				type = "group",
				args = {
				    scale = {
				        name = "Nameplate Scale",
				        type = "group",
				        inline = true,
				        order = 10,
				        disabled = function(info) return not self.settings.enable end,
				        args = {
				            globalScale = {
				                type = "range",
				                isPercent = true,
				                name = "Global Scale",
				                desc = "",
				                min = 0.5,
				                max = 1.5,
				                step = 0.1,
				                order = 1,
				                set = function(info,val) 
				                    SetCVar("nameplateGlobalScale", val)
				                    JokPlates:ForceUpdate()
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateGlobalScale")) end
				            },
				            targetScale = {
				                type = "range",
				                isPercent = true,
				                name = "Target Scale",
				                desc = "",
				                min = 0.5,
				                max = 1.5,
				                step = 0.1,
				                order = 2,
				                set = function(info,val) 
				                    SetCVar("nameplateSelectedScale", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateSelectedScale")) end
				            },
				            importantScale = {
				                type = "range",
				                isPercent = true,
				                name = "Important Scale",
				                desc = "",
				                min = 0.5,
				                max = 1.5,
				                step = 0.1,
				                order = 3,
				                set = function(info,val)
				                    SetCVar("nameplateLargerScale", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateLargerScale")) end
				            },
				        },
				    },				    
				    nameplateSize = {
				        name = "Nameplate Size",
				        type = "group",
				        inline = true,
				        order = 50,
				        disabled = function(info) return not self.settings.enable end,
				        args = {
				            healthHeight = {
				                type = "range",
				                isPercent = false,
				                name = "Health Bar Height",
				                desc = "",
				                min = 3,
				                max = 12,
				                step = 0.1,
				                order = 1,
				                set = function(info,val) self.settings.healthHeight = val 
				                JokPlates:ForceUpdate()
				                end,
				                get = function(info, val) return self.settings.healthHeight end
				            },
				            healthWidth = {
				                type = "range",
				                isPercent = false,
				                name = "Health Bar Width",
				                desc = "",
				                min = 10,
				                max = 200,
				                step = 1,
				                order = 2,
				                set = function(info,val) self.settings.healthWidth = val
				                    C_NamePlate.SetNamePlateEnemySize(val,40)
				                end,
				                get = function(info, val) return self.settings.healthWidth end
				            },
				        },
				    },
				    personalSize = {
				        name = "Personal Nameplate Size",
				        type = "group",
				        inline = true,
				        order = 50,
				        disabled = function(info) return not self.settings.enable end,
				        args = {
				        	personalHealthHeight = {
				                type = "range",
				                isPercent = false,
				                name = "Health Bar Height",
				                desc = "",
				                min = 5,
				                max = 30,
				                step = 1,
				                order = 1,
				                set = function(info,val) self.settings.personalHealthHeight = val
				                JokPlates:ForceUpdate()
				                end,
				                get = function(info, val) return self.settings.personalHealthHeight end
				            },
				            personalManaHeight = {
				                type = "range",
				                isPercent = false,
				                name = "Power Bar Height",
				                desc = "",
				                min = 5,
				                max = 30,
				                step = 1,
				                order = 2,
				                set = function(info,val) self.settings.personalManaHeight = val 
                                DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight = val
				                ClassNameplateManaBarFrame:SetSize(self.settings.personalWidth-24, val)
				                end,
				                get = function(info, val) return self.settings.personalManaHeight end
				            },
				            personalWidth = {
				                type = "range",
				                isPercent = false,
				                name = "Personal Bar Width",
				                desc = "",
				                min = 25,
				                max = 220,
				                step = 1,
				                order = 3,
				                set = function(info,val) self.settings.personalWidth = val
                                    JokPlates:ForceUpdate()
				                    C_NamePlate.SetNamePlateSelfSize(val,0.1)
				                    ClassNameplateManaBarFrame:SetSize(val-24, self.settings.personalManaHeight)
				                end,
				                get = function(info, val) return self.settings.personalWidth end
				            },
                            personalPosition = {
                                type = "range",
                                isPercent = false,
                                name = "Personal Bar Position",
                                desc = "",
                                min = 1,
                                max = 100,
                                step = 1,
                                order = 4,
                                set = function(info,val)
                                    val = floor (val)
                    
                                    SetCVar ("nameplateSelfBottomInset", val / 100)
                                    SetCVar ("nameplateSelfTopInset", abs (val - 95) / 100)
                                end,
                                get = function(info, val) return tonumber (GetCVar ("nameplateSelfBottomInset")*100) end
                            },
                            
				        },
				    },
				},
			},
			visibility = {
				name = "Visibility",
				order = 3,
				type = "group",
				args = {
					overlap = {
				        name = "Overlap Options",
				        type = "group",
				        inline = true,
				        order = 30,
				        disabled = function(info) return not self.settings.enable end,
				        args = {
				            stacking = {
				                type = "toggle",
				                name = "Stacking Nameplates",
				                desc = "|cffaaaaaaNameplates will stack on top of each other. |r",
				                descStyle = "inline",
				                width = "full",
				                order = 1,
				                set = function(info,val) self.settings.overlap = val
				                    SetCVar("nameplateMotion", val)
				                end,
				                get = function(info) return GetCVar("nameplateMotion") end
				            },
				            friendlyName = {
				                type = "toggle",
				                name = "Overlap Friendly Names",
				                desc = "|cffaaaaaaForce Friendly Nameplates to not stack. |r",
				                descStyle = "inline",
				                width = "full",
				                order = 2,
				                set = function(info,val) self.settings.friendlymotion = val
				                StaticPopup_Show ("ReloadUI_Popup")
				                end,
				                get = function(info) return self.settings.friendlymotion end
				            },
				            verticalOverlap = {
				                type = "range",
				                isPercent = false,
				                name = "Vertical Overlap",
				                desc = "",
				                min = 0.3,
				                max = 1.3,
				                step = 0.1,
				                order = 3,
				                disabled = function(info) return  not self.settings.overlap or not self.settings.enable end,
				                set = function(info,val)
				                    SetCVar("nameplateOverlapV", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateOverlapV")) end
				            },
				            horizontalOverlap = {
				                type = "range",
				                isPercent = false,
				                name = "Horizontal Overlap",
				                desc = "",
				                min = 0.3,
				                max = 1.3,
				                step = 0.1,
				                order = 4,
				                disabled = function(info) return  not self.settings.overlap or not self.settings.enable end,
				                set = function(info,val)
				                    SetCVar("nameplateOverlapH", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateOverlapH")) end
				            },
				        },
				    },
				    frame = {
				        name = "Frame Options",
				        type = "group",
				        inline = true,
				        order = 20,
				        disabled = function(info) return not self.settings.enable end,
				        args = {
				            sticky = {
				                name = "Sticky Nameplates",
				                desc = "|cffaaaaaaNameplates will stick to the top of the screen if not in view angle. |r",
				                descStyle = "inline",
				                width = "full",
				                type = "toggle",
				                order = 1,
				                set = function(info,checked)
				                    if not checked then
				                        self.settings.sticky = false
				                        SetCVar("nameplateOtherTopInset", -1,true)
				                        SetCVar("nameplateOtherBottomInset", -1,true)
				                        else
				                        for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v),true) end
				                    end
				                    self.settings.sticky = checked
				                end,
				                get = function(info) return self.settings.sticky end
				            },
				            nameplateAlpha = {
				                type = "range",
				                isPercent = true,
				                name = "Nameplate Alpha",
				                desc = "",
				                min = 0,
				                max = 1,
				                step = 0.1,
				                order = 3,
				                set = function(info,val) self.settings.nameplateAlpha = val
				                end,
				                get = function(info) return self.settings.nameplateAlpha end
				            },
				            nameplateRange = {
				                type = "range",
				                isPercent = false,
				                name = "Nameplate Range",
				                desc = "",
				                min = 40,
				                max = 80,
				                step = 1,
				                order = 4,
				                set = function(info,val) self.settings.nameplateRange = val
				                    SetCVar("nameplateMaxDistance", val)
				                end,
				                get = function(info) return self.settings.nameplateRange end
				            },
				        },
				    },
				    visibility = {
				        name = "Visibility Options",
				        type = "group",
				        inline = true,
				        order = 40,
				        disabled = function(info) return not self.settings.enable end,
				        args = {
				            enemytotem = {
				                type = "toggle",
				                name = "Show Enemy Totems",
				                desc = "",
				                order = 1,
				                set = function(info,val) self.settings.enemytotem = val
				                    SetCVar("nameplateShowEnemyTotems", val)
				                end,
				                get = function(info) return self.settings.enemytotem end
				            },
				            enemypets = {
				                type = "toggle",
				                name = "Show Enemy Pets",
				                desc = "",
				                order = 1,
				                set = function(info,val) self.settings.enemypets = val
				                    SetCVar("nameplateShowEnemyPets", val)
				                end,
				                get = function(info) return self.settings.enemypets end
				            },
				            enemyguardian = {
				                type = "toggle",
				                name = "Show Enemy Guardians",
				                desc = "",
				                order = 1,
				                set = function(info,val) self.settings.enemyguardian = val
				                    SetCVar("nameplateShowEnemyGuardians", val)
				                end,
				                get = function(info) return self.settings.enemyguardian end
				            },
				        },
				    },
				},
			},
			misc = {
				name = "Misc",
				order = 4,
				type = "group",
				args = {
					arenanumber = {
				        type = "toggle",
				        name = "Arena Number",
				        desc = "|cffaaaaaaReplace names on Nameplates with arena numbers. |r",
				        descStyle = "inline",
				        width = "full",
				        order = 1,
				        disabled = function(info) return not self.settings.enable end,
				        set = function(info,val) self.settings.arenanumber = val
				        JokPlates:ForceUpdate()
				        end,
				        get = function(info) return self.settings.arenanumber end
				    },
				    castInterrupt = {
				        type = "toggle",
				        name = "Show who interrupted",
				        desc = "|cffaaaaaaWill show who interrupted the cast in the cast bar. |r",
				        descStyle = "inline",
				        width = "full",
				        order = 2,
				        disabled = function(info) return not self.settings.enable end,
				        set = function(info,val) self.settings.castInterrupt = val
				        end,
				        get = function(info) return self.settings.castInterrupt end
				    },
				    castTarget = {
				        type = "toggle",
				        name = "Show who is targeted",
				        desc = "|cffaaaaaaWill show who is targeted by the cast in the cast bar. |r",
				        descStyle = "inline",
				        width = "full",
				        order = 3,
				        disabled = function(info) return not self.settings.enable end,
				        set = function(info,val) self.settings.castTarget = val
				        end,
				        get = function(info) return self.settings.castTarget end
				    },
				},
			},
			auras = {
				name = "Auras",
				type = "group",
				childGroups = "tab",
				order = 5,
				args = spells
			},
		}
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable("JokPlates", self.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JokPlates", "|cffFF7D0AJok|rPlates")
end

function JokPlates:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JokPlatesDB", nameplates_defaults, true)
	self.settings = self.db.profile

	self:SetupOptions()
	self:Refresh()
end

function JokPlates:OnEnable()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("NAME_PLATE_CREATED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
    self:RegisterEvent('UNIT_HEALTH_FREQUENT')

    self:SecureHook('CompactUnitFrame_UpdateName')
    self:SecureHook('CompactUnitFrame_UpdateHealthColor')
    self:SecureHook('ClassNameplateManaBar_OnUpdate')
    self:SecureHook('DefaultCompactNamePlateFrameAnchorInternal')   
    self:SecureHook(NamePlateDriverFrame, 'SetupClassNameplateBars', 'SetupClassNameplateBar')
    
    self:Buffs()
    self:CC()

    -- Set CVAR
    SetCVar("nameplateGlobalScale", self.settings.globalScale)
    SetCVar("nameplateSelectedScale", self.settings.targetScale)
    SetCVar("nameplateLargerScale", self.settings.importantScale)
    SetCVar("nameplateOverlapV", self.settings.verticalOverlap)
    SetCVar("nameplateOverlapH", self.settings.horizontalOverlap)      
    SetCVar("nameplateMotion", self.settings.overlap)
    SetCVar("nameplateShowEnemyGuardians", self.settings.enemyguardian)
    SetCVar("nameplateShowEnemyTotems", self.settings.enemytotem)
    SetCVar("nameplateShowEnemyPets", self.settings.enemypets)

    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateMaxScale", 1)
    SetCVar("nameplateShowDebuffsOnFriendly", 0)

    SetCVar("nameplateShowAll", 1)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- Format Time
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

-- Format Number
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

-- Abbreviate Function
function JokPlates:Abbrev(str,length)
    if ( str ~= nil and length ~= nil ) then
        return str:len()>length and str:sub(1,length)..".." or str
    end
    return ""
end

-- Force Nameplate Update 
function JokPlates:ForceUpdate()
    for i, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
    end
end

function JokPlates:UpdateAllNameplates()
    for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        self:UpdateCastbar(frame)
        self:UpdateName(frame)
    end 
end

-- Check for threat.
function JokPlates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

-- Checks to see if unit has tank role.
function JokPlates:PlayerIsTank(unit)
    local assignedRole = UnitGroupRolesAssigned(unit)
    return assignedRole == "TANK"
end

-- Off Tank Color Checks
function JokPlates:UseOffTankColor(unit)
    if ( UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) ) then
        if ( not UnitIsUnit("player", unit) and JokPlates:PlayerIsTank("player") and JokPlates:PlayerIsTank(unit) ) then
            return true
        end
    end
    return false
end

-- Is Pet?
function JokPlates:IsPet(unit)
    return (not UnitIsPlayer(unit) and UnitPlayerControlled(unit))
end

-- Class Color Text
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

-- Class Color Text
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

function JokPlates:GetPlayerRGBColor(unit)
    local _, class = UnitClass (unit)
    if (class) then
        c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
    end
    return c.r, c.g, c.g
end

-- Is Showing Resource Frame?
function JokPlates:IsShowingResourcesOnTarget()
    if GetCVar("nameplateResourceOnTarget") == "1" and GetCVar("nameplateShowSelf") == "1" and NamePlateTargetResourceFrame:IsShown() then
        return true
    end
end

-- Group Members Snippet 
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

-- Update CastBar Timer
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

-- Get NPCID
function JokPlates:GetNpcID(unit)
    local npcID = select(6, strsplit("-", UnitGUID(unit)))

    return tonumber(npcID)
end

-- Is Unit from table
function JokPlates:IsUnit(table, unit)
	local npcID = self:GetNpcID(unit)

	for k, npcs in pairs(table) do
		if k == npcID then
			return true
		end
    end
end

-- Return r,g,b from npcid/table
function JokPlates:DangerousColor(unit)
	local r, g, b
	local dangerousColor = {r = 1.0, g = 0.7, b = 0.0}
	local otherColor = {r = 0.0, g = 0.7, b = 1.0}

	local npcID = self:GetNpcID(unit)

	for k, npcs in pairs(moblist) do
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

-- Add HealthText
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

function JokPlates:UpdateHealth(frame, unit)
    if ( not frame.healthBar.LeftText or not frame.healthBar.RightText ) then return end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local perc = math.floor(100 * (health/maxHealth))

    if ( health >= 1 ) then
        frame.healthBar.LeftText:SetText(perc.."%")
        frame.healthBar.RightText:SetText(self:FormatValue(health))
    else
        frame.healthBar.LeftText:SetText("")
        frame.healthBar.RightText:SetText("")
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

	local OriAuraSize = true
	
	self.unit = unit;
	self.filter = filter;
	self:UpdateAnchor();

	-- Some buffs may be filtered out, use this to create the buff frames.
	local buffIndex = 1;
	for i = 1, BUFF_MAX_DISPLAY do
		local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura(unit, i, filter);

		-----------------------------------------------------------
		local flag = false

		-- Default Blizzard Filter
		flag = self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll or showAll, duration) 

		-- Debuffs Whitelist
		if JokPlates.db.profile.spells.debuffs[spellId] and caster == "player" then 
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

    self:Layout();
end

-----------------------------------------

function JokPlates:UpdateCastbar(frame)

    if ( frame:IsForbidden() ) then return end
    
    -- Castbar Timer.

    if ( not frame.castBar.CastTime ) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, "OVERLAY")
        frame.castBar.CastTime:Hide()
        frame.castBar.CastTime:SetPoint("LEFT", frame.castBar, "RIGHT", 4, 0)
        frame.castBar.CastTime:SetFont(castbarFont, 9, "OUTLINE")
        frame.castBar.CastTime:Show()
    end

    -- Update Castbar.

    frame.castBar:SetScript("OnValueChanged", function(self, value)
        if ( frame.unit ) then
            if ( frame.castBar.casting ) then
                notInterruptible = select(8, UnitCastingInfo(frame.displayedUnit))
            else
                notInterruptible = select(7, UnitChannelInfo(frame.displayedUnit))
            end
        end

        if not frame.castBar.Icon:IsShown() then
            frame.castBar.Icon:Show()
            if ( frame.castBar.casting ) then
                frame.castBar.Icon:SetTexture(select(3, UnitCastingInfo(frame.displayedUnit)))
            else
                frame.castBar.Icon:SetTexture(select(3, UnitChannelInfo(frame.displayedUnit)))
            end
        end

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
    end)

    frame.castBar.BorderShield:SetTexture(nil)
end

function JokPlates:ThreatColor(frame)
    local r, g, b
    local npcID = self:GetNpcID(frame.displayedUnit)

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
            elseif ( self:IsUnit(moblist, frame.displayedUnit) ) then
				r, g, b = JokPlates:DangerousColor(frame.displayedUnit)
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

-------------------------------------------------------------------------------
-- SKIN
-------------------------------------------------------------------------------

function JokPlates:PLAYER_ENTERING_WORLD()

    DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight = JokPlates.db.profile.personalManaHeight

    -- Remove Larger Nameplates Function (thx Plater)
    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Disable()
    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc = function() end

    -- Enemy Nameplates
    C_NamePlate.SetNamePlateEnemySize(self.settings.healthWidth, 40)

    -- Friendly Nameplates
    C_NamePlate.SetNamePlateFriendlySize(90, 0.1)
    C_NamePlate.SetNamePlateFriendlyClickThrough(true)

    -- Personal Nameplate
    C_NamePlate.SetNamePlateSelfSize(self.settings.personalWidth, 0.1)
    C_NamePlate.SetNamePlateSelfClickThrough(true)

    -- Class Nameplate Mana Bar
    ClassNameplateManaBarFrame:SetSize(self.settings.personalWidth-24, self.settings.personalManaHeight)
    ClassNameplateManaBarFrame:SetHeight(self.settings.personalManaHeight)
    ClassNameplateManaBarFrame:SetStatusBarTexture(statusBar)

    if ( not ClassNameplateManaBarFrame.text ) then
        ClassNameplateManaBarFrame.text = ClassNameplateManaBarFrame:CreateFontString("$parent.ResourceText", "OVERLAY")   
        ClassNameplateManaBarFrame.text:SetFont("FONTS\\FRIZQT__.TTF", 12, "OUTLINE")
        ClassNameplateManaBarFrame.text:SetPoint("CENTER", ClassNameplateManaBarFrame)
    end
end

function JokPlates:NAME_PLATE_CREATED(_, namePlate)
	local frame = namePlate.UnitFrame
    frame.isNameplate = true

    frame.healthBar:SetStatusBarTexture(statusBar)
    frame.selectionHighlight:SetTexture(statusBar)
    frame.castBar:SetStatusBarTexture(statusBar)

    frame.RaidTargetFrame:SetScale(1.2)
    frame.RaidTargetFrame:SetPoint("RIGHT", frame.healthBar, "LEFT", -7, 0)

    self:UpdateCastbar(frame)

    self:AddHealthbarText(namePlate)

	-- Hook UpdateBuffs
	frame.BuffFrame.UpdateBuffs = JokPlates_UpdateBuffs

	-- Hook UpdateAnchor
	function frame.BuffFrame:UpdateAnchor()
		if not frame.displayedUnit then return end   		
		if UnitIsUnit(frame.displayedUnit, "player") then --player plate
            --self:ClearAllPoints()
			self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 3);
		elseif not frame.healthBar:IsShown() then -- no healthbar
			self:SetPoint("BOTTOM", frame.name, "TOP", 0, 2);
		elseif frame.healthBar:IsShown() and frame.name:IsShown() then -- healthbar
			self:SetPoint("BOTTOM", frame.name, "TOP", 0, 3);
        elseif frame.healthBar:IsShown() then
            self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 4);
		end
	end	
end

function JokPlates:NAME_PLATE_UNIT_ADDED(_, unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local frame = namePlate.UnitFrame

    if ( frame:IsForbidden() ) then return end

    if self:IsUnit(totemlist, frame.displayedUnit) then
        if not frame.icon then
            frame.icon = frame:CreateTexture(nil, "OVERLAY")
            frame.icon:SetSize(30, 30)
            frame.icon:SetPoint("BOTTOM", frame.name, "TOP", 0, 2)
        end

        local npcID = self:GetNpcID(frame.displayedUnit)

        for k, npcs in pairs(totemlist) do
            local icon = npcs["icon"]

            if k == npcID then
                frame.icon:SetTexture(npcs["icon"])
            end
        end
    else
        if frame.icon then
            frame.icon:SetTexture(nil)
        end
    end

    if UnitIsUnit(frame.displayedUnit, "player") then 
        frame.healthBar:SetHeight(self.settings.personalHealthHeight)
        self:UpdateHealth(frame, "player")
        return 
    end
end

function JokPlates:NAME_PLATE_UNIT_REMOVED(_, unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local frame = namePlate.UnitFrame
end

function JokPlates:CompactUnitFrame_UpdateName(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    -- Abbreviate Long Names. 
    frame.name:SetText(self:Abbrev(frame.name:GetText(), 24))

    -- Player Name
    if ( UnitIsPlayer(frame.displayedUnit) and not UnitIsUnit(frame.displayedUnit, "player") ) then
        local _, class = UnitClass(frame.unit)
        local r, g, b = GetClassColor(class)
        frame.name:SetVertexColor(r, g, b);

        local name = UnitName(frame.unit);
        frame.name:SetText(name)
    end
    
    -- Arena Number on Nameplates.  
    if IsActiveBattlefieldArena() and self.settings.arenanumber then 
        for i=1,3 do 
            if UnitIsUnit(frame.displayedUnit, "arena"..i) then 
                frame.name:SetText(i)
                frame.name:SetTextColor(1,1,0)
                break 
            end 
        end 
    end
end

function JokPlates:CompactUnitFrame_UpdateHealthColor(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    self:ThreatColor(frame) 
end

function JokPlates:SetupClassNameplateBar(self, OnTarget, Bar)
    if OnTarget then return end

	if self.classNamePlateMechanicFrame then
        self.classNamePlateMechanicFrame:SetScale(1.1)
    end
end

function JokPlates:ClassNameplateManaBar_OnUpdate(self)
    local currValue = UnitPower("player", self.powerType);
    local predictedValue = currValue

    local castingSpellID = select(9, UnitCastingInfo('player'))

    if PowerPrediction[self.powerType] then
        for spellID, spell in pairs(PowerPrediction[self.powerType]) do
            if castingSpellID == spellID then
                predictedValue = currValue + spell.power
            end
        end
    end

    if ( currValue ~= predictedValue and castingSpellID ) then
        self.forceUpdate = nil;
        
        self.FeedbackFrame:StartFeedbackAnim(currValue or 0, predictedValue);
        if ( self.FullPowerFrame.active ) then
            self.FullPowerFrame:StartAnimIfFull(self.currValue or 0, currValue);
        end
        self.currValue = currValue;
    else
        self.FeedbackFrame.GainGlowTexture:Hide()
    end

    self.text:SetText(JokPlates:FormatValue(predictedValue))
end

function JokPlates:UNIT_HEALTH_FREQUENT(_, unit)
    if not UnitIsUnit(unit, "player") then return end

    local namePlate = C_NamePlate.GetNamePlateForUnit('player')
    if not namePlate then return end
    local frame = namePlate.UnitFrame

    self:UpdateHealth(frame, unit)
end

function JokPlates:DefaultCompactNamePlateFrameAnchorInternal(frame, setupOptions)
    if ( frame:IsForbidden() ) then return end
    if ( not frame.isNameplate ) then return end

    frame.healthBar:SetHeight(JokPlates.db.profile.healthHeight)
end

-- Mouseover Highlight
function JokPlates:UPDATE_MOUSEOVER_UNIT()
    local namePlate = C_NamePlate.GetNamePlateForUnit('mouseover')
    if not namePlate then return end
	local frame = namePlate.UnitFrame

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

-- Check Spell Interrupt
function JokPlates:COMBAT_LOG_EVENT_UNFILTERED()
    if IsInGroup() then
        local time, event, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()
        if event == "SPELL_INTERRUPT" and self.settings.castInterrupt then
            for _, namePlate in ipairs (C_NamePlate.GetNamePlates()) do
                local token = namePlate.namePlateUnitToken
                if (namePlate.UnitFrame.castBar:IsShown()) then
                    if (namePlate.UnitFrame.castBar.Text:GetText() == INTERRUPTED) then
                        if (UnitGUID(token) == targetGUID) then
                            namePlate.UnitFrame.castBar.Text:SetText (INTERRUPTED .. self:SetTextColorByClass(sourceName, sourceName))
                        end
                    end
                end
            end
        end       
    end
end

-- Buffs
function JokPlates:Buffs()

    local Jok_PlateHolder = {}

    local function CreateText(frame, layer, fontsize, flag, justifyh, shadow)
        local text = frame:CreateFontString("$parent.CountText", layer)
        text:SetFont("Fonts\\FRIZQT__.TTF", fontsize, flag)
        text:SetJustifyH(justifyh)
        
        if shadow then
            text:SetShadowColor(0, 0, 0)
            text:SetShadowOffset(1, -1)
        end
        
        return text
    end

    local function PairsByKeys(t)
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

    ----------------------------------------------------------
    ---------------[[    Nameplate Icons    ]]----------------
    ----------------------------------------------------------

    local function CreateIcon(parent, tag, index)
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
            button.count = CreateText(button, "OVERLAY", 12, "OUTLINE", "RIGHT")
            button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -2)
            button.count:SetTextColor(1, 1, 1)
        end

        button:Hide()
        parent.QueueIcon(button, tag)
        
        return button
    end

    local function UpdateAuraIcon(button, unit, index, filter)
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

        -- button:SetScript("OnUpdate", function(self)
        --     if MouseIsOver(self) then
        --         GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        --         GameTooltip:SetUnitAura(unit, index, filter)
        --     else
        --         GameTooltip:ClearLines()
        --         GameTooltip:Hide()
        --     end
        -- end)

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

    local function UpdateAuras(unitFrame)
        if not unitFrame.unit then return end   
        local unit = unitFrame.unit 
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        local self = unitFrame.BuffFrame

        if UnitIsUnit("player", unit) then
            self:SetScale(1.2)
        else
            self:SetScale(JokPlates.db.profile.buffFrameScale)
        end
        
        -- Buffs
        local buffIndex = 1
        if UnitIsUnit(unit, "player") then
        	for i = 1, BUFF_MAX_DISPLAY do       
	            local name, _, _, _, duration, expire, caster, canStealOrPurge, nameplateShowPersonal, spellID, _, isBossDebuff, castByPlayer, nameplateShowAll = UnitAura(unit, i, 'HARMFUL')
	            if isBossDebuff then
	                if not self.buffList[buffIndex] then
	                    self.buffList[buffIndex] = CreateIcon(self, "aura"..buffIndex, buffIndex)
	                end
	                UpdateAuraIcon(self.buffList[buffIndex], unit, i, 'HARMFUL')
	                buffIndex = buffIndex + 1
	            end
	        end
        else
	        for i = 1, BUFF_MAX_DISPLAY do       
	            local name, _, _, _, duration, expire, caster, canStealOrPurge, nameplateShowPersonal, spellID, _, isBossDebuff, castByPlayer, nameplateShowAll = UnitAura(unit, i, 'HELPFUL')
	            if (JokPlates.db.profile.spells.buffs.purgeable and canStealOrPurge) or JokPlates.db.profile.spells.buffs[spellID] or isBossDebuff then
	                if not self.buffList[buffIndex] then
	                    self.buffList[buffIndex] = CreateIcon(self, "aura"..buffIndex, buffIndex)
	                end
	                UpdateAuraIcon(self.buffList[buffIndex], unit, i, 'HELPFUL')
	                buffIndex = buffIndex + 1
	            end
	        end
	    end

        for i = buffIndex, #self.buffList do 
        	self.buffList[i]:Hide() 
        end
    end

    local function NamePlate_OnEvent(self, event, arg1, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            UpdateAuras(self)   
        elseif event == "UNIT_AURA" and arg1 == self.unit then
            UpdateAuras(self)
        end
    end

    local function SetUnit(unitFrame, unit)
        unitFrame.unit = unit
        if unit then
            unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            unitFrame:RegisterUnitEvent("UNIT_AURA", unitFrame.unit)
            unitFrame:SetScript("OnEvent", NamePlate_OnEvent)
        else
            unitFrame:UnregisterAllEvents()
            unitFrame:SetScript("OnEvent", nil)
        end
    end

    local function UpdateAllNamePlates()
        for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
            local unitFrame = namePlate.Jok
            UpdateAuras(unitFrame)
        end
    end

    local function OnNamePlateCreated(namePlate)
        if namePlate.UnitFrame:IsForbidden() then return end

        namePlate.Jok = CreateFrame("Button", "$parentUnitFrame", namePlate)
        namePlate.Jok:SetAllPoints(namePlate)
        namePlate.Jok:SetFrameLevel(namePlate:GetFrameLevel())

        -- Buff Frame
        namePlate.Jok.BuffFrame = CreateFrame("Frame", "$parentJokBuff", namePlate.UnitFrame)

        namePlate.Jok.BuffFrame:SetPoint("BOTTOMLEFT", namePlate.UnitFrame.BuffFrame, "TOPLEFT", 0, 3)
        
        namePlate.Jok.BuffFrame:SetWidth(130)
        namePlate.Jok.BuffFrame:SetHeight(14)
        namePlate.Jok.BuffFrame:SetFrameLevel(namePlate:GetFrameLevel())

        namePlate.Jok.BuffFrame.buffList = {}        
        namePlate.Jok.BuffFrame.buffActive = {}

        namePlate.Jok.BuffFrame.LineUpIcons = function()
            local lastframe
            for v, frame in PairsByKeys(namePlate.Jok.BuffFrame.buffActive) do
                frame:ClearAllPoints()
                if not lastframe then
                    local num = 0
                    for k, j in pairs(namePlate.Jok.BuffFrame.buffActive) do
                        num = num + 1
                    end
                    frame:SetPoint("LEFT", namePlate.Jok.BuffFrame, "LEFT", 0,0)
                else
                    frame:SetPoint("LEFT", lastframe, "RIGHT", 4, 0)
                end

                lastframe = frame
            end
        end
        
        namePlate.Jok.BuffFrame.QueueIcon = function(frame, tag)
            frame.v = tag
            
            frame:HookScript("OnShow", function()
                namePlate.Jok.BuffFrame.buffActive[frame.v] = frame
                namePlate.Jok.BuffFrame.LineUpIcons()
            end)
            
            frame:HookScript("OnHide", function()
                namePlate.Jok.BuffFrame.buffActive[frame.v] = nil
                namePlate.Jok.BuffFrame.LineUpIcons()
            end)
        end
        
        table.insert(Jok_PlateHolder, namePlate.Jok.BuffFrame)
        
        namePlate.Jok:EnableMouse(false)
    end

    local function OnNamePlateAdded(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        local unitFrame = namePlate.Jok

        if namePlate.UnitFrame:IsForbidden() then return end

        SetUnit(unitFrame, unit)
        UpdateAuras(unitFrame)
    end

    local function OnNamePlateRemoved(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        SetUnit(namePlate.Jok, nil)
    end

    local function OnEvent(self, event, ...) 
        if ( event == "VARIABLES_LOADED" ) then
            UpdateAllNamePlates()
        elseif ( event == "NAME_PLATE_CREATED" ) then
            local namePlate = ...
            OnNamePlateCreated(namePlate)
        elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then 
            local unit = ...
            OnNamePlateAdded(unit)
        elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then 
            local unit = ...
            OnNamePlateRemoved(unit)
        end
    end

    local NamePlatesFrame = CreateFrame("Frame", "NamePlatesFrame", UIParent) 
    NamePlatesFrame:SetScript("OnEvent", OnEvent)
    NamePlatesFrame:RegisterEvent("VARIABLES_LOADED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_CREATED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

-- CC Module
function JokPlates:CC()

    local spellList = {
        -- Higher up = higher display priority

        -- CCs
        5211,   -- Mighty Bash (Stun)
        108194, -- Asphyxiate (Stun)
        199804, -- Between the Eyes (Stun)
        118905, -- Static Charge (Stun)
        1833,   -- Cheap Shot (Stun)
        853,    -- Hammer of Justice (Stun)
        179057, -- Chaos Nova (Stun)
        132169, -- Storm Bolt (Stun)
        408,    -- Kidney Shot (Stun)
        163505, -- Rake (Stun)
        119381, -- Leg Sweep (Stun)
        89766,  -- Axe Toss (Stun)
        30283,  -- Shadowfury (Stun)
        24394,  -- Intimidation (Stun)
        211881, -- Fel Eruption (Stun)
        91800,  -- Gnaw (Stun)
        205630, -- Illidan's Grasp (Stun)
        203123, -- Maim (Stun)
        200200, -- Holy Word: Chastise, Censure Talent (Stun)
        22703,  -- Infernal Awakening (Stun)
        132168, -- Shockwave (Stun)
        20549,  -- War Stomp (Stun)
        199085, -- Warpath (Stun)
        204437, -- Lightning Lasso (Stun)
        64044,  -- Psychic Horror (Stun)
        255723, -- Bull Rush (Stun)
        202346, -- Double Barrel (Stun)
        213688, -- Fel Cleave (Stun)
        204399, -- Earthfury (Stun)
        91717,  -- Monstrous Blow (Stun)


        33786,  -- Cyclone (Disorient)
        5246,   -- Intimidating Shout (Disorient)
        8122,   -- Psychic Scream (Disorient)
        2094,   -- Blind (Disorient)
        605,    -- Mind Control (Disorient)
        105421, -- Blinding Light (Disorient)
        207167, -- Blinding Sleet (Disorient)
        31661,  -- Dragon's Breath (Disorient)
        207685, -- Sigil of Misery (Disorient)
        198909, -- Song of Chi-ji (Disorient)
        202274, -- Incendiary Brew (Disorient)
        118699, -- Fear (Disorient)
        6358,   -- Seduction (Disorient)
        261589, -- Seduction 2 (Disorient)
        87204,  -- Sin and Punishment (Disorient)
        2637,   -- Hibernate (Disorient)
        226943, -- Mind Bomb (Disorient)
        236748, -- Intimidating Roar (Disorient)

        51514,  -- Hex (Incapacitate)
        211004, -- Hex: Spider (Incapacitate)
        210873, -- Hex: Raptor (Incapacitate)
        211015, -- Hex: Cockroach (Incapacitate)
        211010, -- Hex: Snake (Incapacitate)
        196942, -- Hex: Voodoo Totem (Incapacitate)
        277784, -- Hex: Wicker Mongrel (Incapacitate)
        277778, -- Hex: Zandalari Tendonripper (Incapacitate)
        118,    -- Polymorph (Incapacitate)
        61305,  -- Polymorph: Black Cat (Incapacitate)
        28272,  -- Polymorph: Pig (Incapacitate)
        61721,  -- Polymorph: Rabbit (Incapacitate)
        61780,  -- Polymorph: Turkey (Incapacitate)
        28271,  -- Polymorph: Turtle (Incapacitate)
        161353, -- Polymorph: Polar Bear Cub (Incapacitate)
        126819, -- Polymorph: Porcupine (Incapacitate)
        161354, -- Polymorph: Monkey (Incapacitate)
        161355, -- Polymorph: Penguin (Incapacitate)
        161372, -- Polymorph: Peacock (Incapacitate)
        277792, -- Polymorph: Bumblebee (Incapacitate)
        277787, -- Polymorph: Baby Direhorn (Incapacitate)
        3355,   -- Freezing Trap (Incapacitate)
        203337, -- Freezing Trap, Diamond Ice Honor Talent (Incapacitate)
        115078, -- Paralysis (Incapacitate)
        213691, -- Scatter Shot (Incapacitate)
        6770,   -- Sap (Incapacitate)
        20066,  -- Repentance (Incapacitate)
        200196, -- Holy Word: Chastise (Incapacitate)
        221527, -- Imprison, Detainment Honor Talent (Incapacitate)
        217832, -- Imprison (Incapacitate)
        99,     -- Incapacitating Roar (Incapacitate)
        82691,  -- Ring of Frost (Incapacitate)
        1776,   -- Gouge (Incapacitate)
        107079, -- Quaking Palm (Incapacitate)
        236025, -- Enraged Maim (Incapacitate)
        197214, -- Sundering (Incapacitate)

        -- Immunities
        642,    -- Divine Shield
        186265, -- Aspect of the Turtle
        45438,  -- Ice Block
        47585,  -- Dispersion
        1022,   -- Blessing of Protection
        204018, -- Blessing of Spellwarding
        216113, -- Way of the Crane
        31224,  -- Cloak of Shadows
        212182, -- Smoke Bomb
        212183, -- Smoke Bomb
        8178,   -- Grounding Totem Effect
        199448, -- Blessing of Sacrifice

        -- Interrupts
        1766,   -- Kick (Rogue)
        2139,   -- Counterspell (Mage)
        6552,   -- Pummel (Warrior)
        19647,  -- Spell Lock (Warlock)
        47528,  -- Mind Freeze (Death Knight)
        57994,  -- Wind Shear (Shaman)
        91802,  -- Shambling Rush (Death Knight)
        96231,  -- Rebuke (Paladin)
        106839, -- Skull Bash (Feral)
        115781, -- Optical Blast (Warlock)
        116705, -- Spear Hand Strike (Monk)
        132409, -- Spell Lock (Warlock)
        147362, -- Countershot (Hunter)
        171138, -- Shadow Lock (Warlock)
        183752, -- Consume Magic (Demon Hunter)
        187707, -- Muzzle (Hunter)
        212619, -- Call Felhunter (Warlock)
        231665, -- Avengers Shield (Paladin)

        -- Anti CCs
        23920,  -- Spell Reflection
        216890, -- Spell Reflection (Honor Talent)
        213610, -- Holy Ward
        212295, -- Nether Ward
        48707,  -- Anti-Magic Shell
        5384,   -- Feign Death
        213602, -- Greater Fade

        -- Silences
        81261,  -- Solar Beam
        202933, -- Spider Sting
        233022, -- Spider Sting 2
        1330,   -- Garrote
        15487,  -- Silence
        199683, -- Last Word
        47476,  -- Strangulate
        31935,  -- Avenger's Shield
        204490, -- Sigil of Silence
        217824, -- Shield of Virtue
        43523,  -- Unstable Affliction Silence 1
        196364, -- Unstable Affliction Silence 2

        -- Disarms
        236077, -- Disarm
        236236, -- Disarm (Protection)
        209749, -- Faerie Swarm (Disarm)
        233759, -- Grapple Weapon
        207777, -- Dismantle

        -- Roots
        339,    -- Entangling Roots
        170855, -- Entangling Roots (Nature's Grasp)
        201589, -- Entangling Roots (Tree of Life)
        235963, -- Entangling Roots (Feral honor talent)
        122,    -- Frost Nova
        102359, -- Mass Entanglement
        64695,  -- Earthgrab
        200108, -- Ranger's Net
        212638, -- Tracker's Net
        162480, -- Steel Trap
        204085, -- Deathchill
        233395, -- Frozen Center
        233582, -- Entrenched in Flame
        201158, -- Super Sticky Tar
        33395,  -- Freeze
        228600, -- Glacial Spike
        116706, -- Disable
        45334,  -- Immobilized
        53148,  -- Charge (Hunter Pet)
        190927, -- Harpoon
        136634, -- Narrow Escape (unused?)
        198121, -- Frostbite
        117526, -- Binding Shot
        207171, -- Winter is Coming
    }

    local priorityList = {}

    local interrupts = {
        [1766] = 5, -- Kick (Rogue)
        [2139] = 6, -- Counterspell (Mage)
        [6552] = 4, -- Pummel (Warrior)
        [19647] = 6, -- Spell Lock (Warlock)
        [47528] = 3, -- Mind Freeze (Death Knight)
        [57994] = 3, -- Wind Shear (Shaman)
        [91802] = 2, -- Shambling Rush (Death Knight)
        [96231] = 4, -- Rebuke (Paladin)
        [93985] = 4, -- Skull Bash (Feral)
        --[97547] = 5, -- Solar Beam (Druid)
        [106839] = 4, -- Skull Bash (Feral)
        [115781] = 6, -- Optical Blast (Warlock)
        [116705] = 4, -- Spear Hand Strike (Monk)
        [132409] = 6, -- Spell Lock (Warlock)
        [147362] = 3, -- Countershot (Hunter)
        [171138] = 6, -- Shadow Lock (Warlock)
        [183752] = 3, -- Consume Magic (Demon Hunter)
        [187707] = 3, -- Muzzle (Hunter)
        [212619] = 6, -- Call Felhunter (Warlock)
        [231665] = 3, -- Avengers Shield (Paladin)
    }

    for k, v in ipairs(spellList) do
        priorityList[v] = k
    end

    local function OnNamePlateCreated(frame)
        if frame:IsForbidden() then return end

        frame.cc = CreateFrame("Frame", "$parent.CC", frame)

        frame.cc:SetPoint("LEFT", frame.healthBar, "RIGHT", 3, 2)
        
        frame.cc:SetWidth(24)
        frame.cc:SetHeight(24)
        frame.cc:SetFrameLevel(frame:GetFrameLevel())
        
        frame.cc.icon = frame.cc:CreateTexture(nil, "OVERLAY", nil, 3)
        frame.cc.icon:SetAllPoints(frame.cc)

        frame.cc.cd = CreateFrame("Cooldown", nil, frame.cc, "CooldownFrameTemplate")
        frame.cc.cd:SetAllPoints(frame.cc)
        frame.cc.cd:SetDrawEdge(false)
        frame.cc.cd:SetAlpha(1)
        frame.cc.cd:SetDrawSwipe(true)
        frame.cc.cd:SetReverse(true)

        frame.cc.activeId = nil
        frame.cc.aura = { spellId = nil, icon = nil, start = nil, expire = nil }
        frame.cc.interrupt = { spellId = nil, icon = nil, start = nil, expire = nil }
    end

    local function ApplyAura(frame)
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

    local function UpdateAuras(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        if not namePlate then return end

        local frame = namePlate.UnitFrame

        if UnitIsUnit(frame.displayedUnit, "player") then return end

        local priorityAura = {
            icon = nil,
            spellId = nil,
            duration = nil,
            expires = nil,
        }

        local duration, icon, expires, spellId, _

        for i = 1, BUFF_MAX_DISPLAY do
            _, icon, _, _, duration, expires, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
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

        ApplyAura(frame.cc)
    end

    local function UpdateInterrupts()
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

	                    ApplyAura(frame.cc)

	                    -- Check for auras when an interrupt lockout expires
	                    C_Timer.After(duration, function()
	                        UpdateAuras(unit)
	                    end)
	                end
	            end
            end
        end
    end

    local function OnNamePlateAdded(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        local frame = namePlate.UnitFrame

        if frame:IsForbidden() then return end

        UpdateAuras(frame.displayedUnit)
    end

    local function NamePlates_OnEvent(self, event, ...) 
        if ( event == "NAME_PLATE_CREATED" ) then
            local namePlate = ...
            OnNamePlateCreated(namePlate.UnitFrame)
        elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then 
            local unit = ...
            OnNamePlateAdded(unit)
        elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
            UpdateInterrupts()
        elseif ( event == "UNIT_AURA" ) then
            local unit = ...
            if not unit:find("nameplate") then return end
            UpdateAuras(unit)
        end
    end

    local NamePlatesFrame = CreateFrame("Frame", "NamePlatesFrame", UIParent) 
    NamePlatesFrame:SetScript("OnEvent", NamePlates_OnEvent)
    NamePlatesFrame:RegisterEvent("UNIT_AURA")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_CREATED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    NamePlatesFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

SLASH_JokPlates1 = "/jokplates"
SLASH_JokPlates2 = "/jp"
SlashCmdList.JokPlates = function(msg)
	InterfaceOptionsFrame_OpenToCategory("|cffFF7D0AJok|rPlates")
	InterfaceOptionsFrame_OpenToCategory("|cffFF7D0AJok|rPlates")
end
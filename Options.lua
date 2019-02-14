JokPlates = LibStub("AceAddon-3.0"):GetAddon("JokPlates")

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

function JokPlates:Refresh()
	local nameplates_buffs = JokPlatesFrameMixin.nameplates_buffs
	local nameplates_debuffs = JokPlatesFrameMixin.nameplates_debuffs
	local nameplates_personal = JokPlatesFrameMixin.nameplates_personal

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

function JokPlates:ShutdownInterfaceOptionsPanel()
	local frames = {
		InterfaceOptionsNamesPanelUnitNameplatesFriendsText,
		InterfaceOptionsNamesPanelUnitNameplatesEnemies,
		InterfaceOptionsNamesPanelUnitNameplatesFriends,
		InterfaceOptionsNamesPanelUnitNameplatesMakeLarger,
		InterfaceOptionsNamesPanelUnitNameplatesShowAll,
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions,
		InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions,
		InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus,
		InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown,
	}

	for _, frame in ipairs (frames) do
		frame:Hide()
	end

	InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc = function() end
	InterfaceOptionsNamesPanelUnitNameplatesAggroFlash:SetPoint("TOPLEFT", InterfaceOptionsNamesPanelUnitNameplates, "BOTTOMLEFT", 0, -8)
	
	local button = CreateFrame("Button", "InterfaceOptionsNamesPanelUnitNameplatesJokPlatesButton", InterfaceOptionsNamesPanel, "UIPanelButtonTemplate")
	button:SetWidth(200)
    button:SetHeight(30)
	button:SetPoint("topleft", InterfaceOptionsNamesPanelUnitNameplatesAggroFlash, "bottomleft", 0, -8)
	button:SetText("Open JokPlates")
	button:SetScript("OnClick", function()
		InterfaceOptionsFrame_OpenToCategory("|cffFF7D0AJok|rPlates")
		InterfaceOptionsFrame_OpenToCategory("|cffFF7D0AJok|rPlates")
	end)
end

function JokPlates:SetupOptions()
    local nameplates_buffs = JokPlatesFrameMixin.nameplates_buffs
    local nameplates_debuffs = JokPlatesFrameMixin.nameplates_debuffs
    local nameplates_personal = JokPlatesFrameMixin.nameplates_personal

    local customSpellInfo = {
        delete = {
            type = "execute",
            name = "Delete",
            desc = "Delete the cooldown",
            func = function(info)
                local spellId = info[#info-1]:gsub("spell", "")
                spellId = tonumber(spellId)
                JokPlates.db.profile.spells.custom[spellId] = nil

                JokPlates:SetupOptions()
            end,
            arg = key,
            order = 2,
        },
        lb = {
            name = "",
            type = "header",
            order = 3,
        },
        visibility = {
            name = "Visibility",
            type = "group",
            inline = true,
            order = 4,
            
            args = {
                personal = {
                    type = "toggle",
                    name = "Personal Nameplate",
                    desc = "",
                    order = 1,
                    width = "full",
                    set = function(info, val) 
                        local spellId = info[#info-2]:gsub("spell", "")
                        spellId = tonumber(spellId)
                        JokPlates.db.profile.spells.custom[spellId].personal = val 
                    end,
                    get = function(info) 
                        local spellId = info[#info-2]:gsub("spell", "")
                        spellId = tonumber(spellId)
                        return JokPlates.db.profile.spells.custom[spellId].personal
                    end
                },
                all = {
                    type = "toggle",
                    name = "All Nameplates",
                    desc = "",
                    order = 2,
                    width = "full",
                    set = function(info,val) 
                        local spellId = info[#info-2]:gsub("spell", "")
                        spellId = tonumber(spellId)
                        JokPlates.db.profile.spells.custom[spellId].all = val 
                    end,
                    get = function(info) 
                        local spellId = info[#info-2]:gsub("spell", "")
                        spellId = tonumber(spellId)
                        return JokPlates.db.profile.spells.custom[spellId].all
                    end
                },
            },
        },    
    }

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
		},
        custom = {
            name = "Custom Spells",
            type = "group",
            order = 4,
            args = {
                spellId = {
                    name = "Add Custom Spell",
                    type = "input",
                    set = function(info, state)
                        spellId = tonumber(state)
                        local name = GetSpellInfo(spellId)
                        if spellId and name then
                            JokPlates.db.profile.spells.custom[spellId] = JokPlates.db.profile.spells.custom[spellId] or { personal = false, all = false }

                            JokPlates:SetupOptions()
                        end
                    end,
                }
            },
        },
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

    for spellID, spell in pairs(JokPlates.db.profile.spells.custom) do
        local key = "spell"..spellID
        local name = GetSpellInfo(spellID)

        spells["custom"].args[key] = {
            name = name,
            type = "group",
            childGroups = "tab",
            args = customSpellInfo,
            icon = GetSpellTexture(spellID),
        }
    end

	self.options = {
		name = "JokPlates",
		descStyle = "inline",
		type = "group",
		childGroups = "tree",
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
                                    SetCVar ("nameplateSelfTopInset", abs (val - 94) / 100)
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
					frame = {
				        name = "Frame Options",
				        type = "group",
				        inline = true,
				        order = 10,
				        
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
				            nameplateRange = {
				                type = "range",
				                isPercent = false,
				                name = "Nameplate Range",
				                desc = "",
				                min = 40,
				                max = 80,
				                step = 1,
				                order = 4,
				                set = function(info,val) 
				                    SetCVar("nameplateMaxDistance", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateMaxDistance")) end
				            },
				        },
				    },
					overlap = {
				        name = "Overlap Options",
				        type = "group",
				        inline = true,
				        order = 20,
				        
				        args = {
				            stacking = {
				                type = "select",
				                name = "Nameplate Motion Type",
				                style = "dropdown",
				                values = {
				                	[0] = "Overlaping Nameplate", -- 0
				                	[1] = "Stacking Nameplate", -- 1	                	

				            	},
				                order = 1,
				                set = function(info,val)				                    
				                    SetCVar("nameplateMotion", val)		
				                end,
				                get = function(info) 
				                	return tonumber(GetCVar("nameplateMotion"))
				            	end
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
				                disabled = function(info) return  not self:GetCVar("nameplateMotion") end,
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
				                disabled = function(info) return  not self:GetCVar("nameplateMotion") end,
				                set = function(info,val)
				                    SetCVar("nameplateOverlapH", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateOverlapH")) end
				            },
				        },
				    },				    
				    alpha = {
				        name = "Alpha Options",
				        type = "group",
				        inline = true,
				        order = 30,
				        
				        args = {
				            nameplateAlpha = {
				                type = "range",
				                isPercent = false,
				                name = "Nameplate Alpha",
				                desc = "",
				                min = 0,
				                max = 1,
				                step = 0.05,
				                order = 1,
				                set = function(info,val)
				                    SetCVar("nameplateMinAlpha", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateMinAlpha")) end
				            },
				            personalAlpha = {
				                type = "range",
				                isPercent = false,
				                name = "Personal Resource Alpha",
				                desc = "",
				                min = 0,
				                max = 1,
				                step = 0.05,
				                order = 1,
				                set = function(info,val)
				                    SetCVar("nameplateSelfAlpha", val)
				                end,
				                get = function(info) return tonumber(GetCVar("nameplateSelfAlpha")) end
				            },
				        },
				    },
				    visibility = {
				        name = "Visibility Options",
				        type = "group",
				        inline = true,
				        order = 40,
				        
				        args = {
				        	enemy = {
						        name = "Enemy Units",
						        type = "group",
						        inline = true,
						        order = 1,
						        
						        args = {
				            
						            enemytotem = {
						                type = "toggle",
						                name = "Show Totems",
						                desc = "",
						                order = 1,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowEnemyTotems", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowEnemyTotems") end
						            },
						            enemypets = {
						                type = "toggle",
						                name = "Show Pets",
						                desc = "",
						                order = 2,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowEnemyPets", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowEnemyPets") end
						            },
						            enemyguardian = {
						                type = "toggle",
						                name = "Show Guardians",
						                desc = "",
						                order = 3,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowEnemyGuardians", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowEnemyGuardians") end
						            },
						            enemyminus = {
						                type = "toggle",
						                name = "Show Minus",
						                desc = "",
						                order = 4,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowEnemyMinus", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowEnemyMinus") end
						            },
						        },
						    },
						    friendly = {
						        name = "Friendly Units",
						        type = "group",
						        inline = true,
						        order = 2,
						        
						        args = {
				            
						            friendlytotem = {
						                type = "toggle",
						                name = "Show Totems",
						                desc = "",
						                order = 1,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowFriendlyTotems", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowFriendlyTotems") end
						            },
						            friendlypets = {
						                type = "toggle",
						                name = "Show Pets",
						                desc = "",
						                order = 2,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowFriendlyPets", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowFriendlyPets") end
						            },
						            friendlyguardian = {
						                type = "toggle",
						                name = "Show Guardians",
						                desc = "",
						                order = 3,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowFriendlyGuardians", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowFriendlyGuardians") end
						            },
						            friendlynpcs = {
						                type = "toggle",
						                name = "Show NPCs",
						                desc = "",
						                order = 4,
						                set = function(info,val) 
						                    self:SetCVar("nameplateShowFriendlyNPCs", val)
						                end,
						                get = function(info) return self:GetCVar("nameplateShowFriendlyNPCs") end
						            },
						        },
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
end
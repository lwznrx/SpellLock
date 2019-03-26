SpellLock = LibStub("AceAddon-3.0"):NewAddon("SpellLock", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0", "LibBars-1.0", "LibSink-2.0")
--local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("SpellLock")
--local SM = LibStub("LibSharedMedia-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibBars = LibStub("LibBars-1.0")
local CS;
local options
local warning;
local anchor
local cdanchor
local fanchor
local numbars
local schools = {}
local spells = {}
local cooldowns = {}
local icons = {}
local colors = {}

if (DBM) then
	CS = DBM:NewMod("SpellLock");
	warning = CS:NewAnnounce("%s");
end

function SpellLock:OnInitialize()
	self.def = {
		char = {
			enabled = true,
			partyChat = false,
			coolDownEnabled = false,
			useDBM = false,
			position = {
				p = "CENTER",
				pr = "CENTER",
				px = 0,
				py = -150
			},
			showInternalBars = true,
			barWidth = 150,
			barHeight = 15,
			growUp = false
		}
	}
    self.db = LibStub:GetLibrary("AceDB-3.0"):New("SpellLockDB", self.def)
	anchor = SpellLock:NewBarGroup("Locks", nil, SpellLock.db.char.barWidth,SpellLock.db.char.barHeight)
	anchor.RegisterCallback(SpellLock, "AnchorClicked", "AnchorClicked")
	anchor:ClearAllPoints()
	anchor:SetPoint(SpellLock.db.char.position.p, UIParent, SpellLock.db.char.position.pr, SpellLock.db.char.position.px, SpellLock.db.char.position.py)
	anchor:SetTexture("Interface\\AddOns\\SpellLock\\media\\smooth.tga")
	anchor:SetColorAt(1, 0, 0, 0, 1)
	anchor:ReverseGrowth(SpellLock.db.char.growUp)
	anchor:HideAnchor()
	numbars = 0
	
	-- Init schools table
	schools[2] = "Holy"
	schools[4] = "Fire"
	schools[8] = "Nature"
	schools[16] = "Frost"
	schools[20] = "Frost/Fire"
	schools[32] = "Shadow"
	schools[64] = "Arcane"
	
	-- Init icon table
	icons[2] = "Interface\\Icons\\Spell_Holy_HolyBolt"
	icons[4] = "Interface\\Icons\\Spell_Fire_FireBolt02"
	icons[8] = "Interface\\Icons\\Spell_Nature_ResistNature"
	icons[16] = "Interface\\Icons\\Spell_Frost_FrostBolt02"
	icons[20] = "Interface\\Icons\\Ability_Mage_FrostFireBolt"
	icons[32] = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight"
	icons[64] = "Interface\\Icons\\Spell_Arcane_Blast"
	
	-- Init color table
	colors[2] = {0.9, 0.9, 0.0}
	colors[4] = {1.0, 0.1, 0.0}
	colors[8] = {0.0, 0.9, 0.1}
	colors[16] = {0.0, 0.1, 0.9}
	colors[20] = {0.0, 0.1, 0.9}
	colors[32] = {0.9, 0.0, 0.9}
	colors[64] = {0.4, 0.4, 0.4}
	
	--Init spells table
	spells[2139] = 8 --Counterspell
	spells[1766] = 5 --Kick
	spells[47528] = 4 --Mind Freeze
	spells[6552] = 4 --Pummel
	spells[19244] = 5 --Spell Lock Rank 1
	spells[19647] = 6 --Spell Lock Rank 2
	spells[57994] = 2 --Wind Shear
	spells[72] = 6 --Shield Bash
	spells[26679] = 3 --Deadly Throw rank 1
	spells[48673] = 3 --Deadly Throw rank 2
	spells[48674] = 3 --Deadly Throw rank 3
	spells[16979] = 4 --Feral Charge - Bear
	
	--Init cooldowns table
	cooldowns[2139] = 24 --Counterspell
	cooldowns[1766] = 10 --Kick
	cooldowns[47528] = 10 --Mind Freeze
	cooldowns[6552] = 10 --Pummel
	cooldowns[19244] = 24 --Spell Lock Rank 1
	cooldowns[19647] = 24 --Spell Lock Rank 2
	cooldowns[57994] = 6 --Wind Shear
	cooldowns[72] = 12 --Shield Bash
	cooldowns[16979] = 15 --Feral Charge - Bear
end

function SpellLock:UpdateAnchor()
	anchor:SetWidth(SpellLock.db.char.barWidth)
	anchor:SetHeight(SpellLock.db.char.barHeight)
	anchor:ReverseGrowth(SpellLock.db.char.growUp)
end

function SpellLock:AnchorClicked(callback, group, button)
	local p,_,pr,px,py = anchor:GetPoint()
	--SpellLock:Print(p.." "..pr.." "..px.." "..py)
	SpellLock.db.char.position.p = p
	SpellLock.db.char.position.pr = pr
	SpellLock.db.char.position.px = px
	SpellLock.db.char.position.py = py
	if button == "RightButton" then
	end
		anchor:ToggleAnchor()
end

function SpellLock:NewLockBar(isCD, bartime, schoolorguid, subject, spellid, spellname)
	if(isCD) then
		txt = spellname
		_, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellid)
		_, englishClass, _, _, _ = GetPlayerInfoByGUID(schoolorguid)
		if(spellid == 19244 or spellid == 19647) then
			color = {RAID_CLASS_COLORS["WARLOCK"].r, RAID_CLASS_COLORS["WARLOCK"].g, RAID_CLASS_COLORS["WARLOCK"].b}
		else
			color = {RAID_CLASS_COLORS[englishClass].r, RAID_CLASS_COLORS[englishClass].g, RAID_CLASS_COLORS[englishClass].b}
		end
	else
		icon = icons[schoolorguid]
		txt = schools[schoolorguid]
		color = colors[schoolorguid]
	end
	
	anchor:NewCounterBar(numbars, subject .. " - "..txt, bartime, bartime, icon, LibBars.LEFT_TO_RIGHT, 200, 30):SetColorAt(1, color[1], color[2], color[3], 1)
	numbars = numbars + 1
	if (numbars > 20) then numbars = 0 end
end

function SpellLock:TestBars()
	local name, realm = UnitName("player")
	if(SpellLock.db.char.coolDownEnabled) then SpellLock:NewLockBar(true, 24, UnitGUID("player"), name, 2139, "Counterspell") end
	SpellLock:NewLockBar(false, 5, 2, name)
	SpellLock:NewLockBar(false, 4, 8, name)
end

local function OnEvent(this, event, arg1, arg2, ...)
 -- Combat log events.
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		if(arg2 == "SPELL_INTERRUPT") then
		--SpellLock:Print("Interrupt found!")
			local config = SpellLock.db.char
			if(config.enabled == true) then
			--SpellLock:Print("Addon is Enabled")
	
				--wowwiki saves the day!
				--SpellLock:Print(arg6)
				local B = tonumber(arg6:sub(5,5), 16);
				local player = B % 8; -- x % 8 has the same effect as x & 0x7 on numbers <= 0xf
				--local knownTypes = {[0]="player", [3]="NPC", [4]="pet", [5]="vehicle"};

				if(player == 0) then
				--SpellLock:Print(arg7.." is a player")
				--guid based
				playerguid = UnitGUID("player")
				petguid = UnitGUID("pet")
	
				if(arg3 == playerguid or arg3 == petguid or UnitPlayerOrPetInParty(arg4) ) then
				--SpellLock:Print("name: "..arg4)
		
					school = schools[arg14]
					locktime = spells[arg9]
		
					SpellLock:Print("Lockout:" .. arg7 .. " ("..school..") for "..locktime.."sec by ".. arg4)
					--Using LibBar-1.0
					if(config.showInternalBars) then
						SpellLock:NewLockBar(false, locktime, arg14, arg7)
					end
		
					--Using DBM UI
					if(DBM and config.useDBM == true) then
						warning:Show("Lockout:" .. arg7 .. " ("..school..") for "..locktime.."sec by ".. arg4)
						timer = CS:NewTimer(locktime, arg7 .. " - "..school)
						timer:Start()
					end
		
					--Write to party chat
					if(config.partyChat == true) then
						members = GetNumPartyMembers();
						if(members > 0) then
							_, englishClass, _, _, _ = GetPlayerInfoByGUID(arg6)
							SendChatMessage("Lockout: " .. arg7 .. " ("..englishClass..":"..school..") for "..locktime.."sec by ".. arg4, "PARTY");
						end
					end
		--DEBUG
		--SpellLock:Print(arg1 .. " -" .. arg2 .. " -" .. arg3 .. " -" .. arg4 .. " -" .. arg5 .. " -" .. arg6 .. " -" .. arg7 .. " -" .. arg8 .. " -" .. arg9 .. " -" .. arg10 .. " -" .. arg11 .. " -" .. arg12 .. " -" .. arg13.. " -" .. arg14)
				end
			end
		end
	end
	--cooldown module
	if(SpellLock.db.char.inArena and SpellLock.db.char.coolDownEnabled) then
		if(arg2 == "SPELL_CAST_SUCCESS") then
			--[15:37:22] SpellLock: 1256132248.04 -SPELL_CAST_SUCCESS -0x0100000002E27DFB -Darmage -66888 -0x0100000002EB6700 -Akarou -1297 -2139 -Counterspell -64
			cd = cooldowns[arg9]
			if(cd) then --RUN THIS FIRST FOR OPTIMALIZATION
				playerguid = UnitGUID("player")
				petguid = UnitGUID("pet")
				if(arg3 == playerguid or arg3 == petguid or UnitPlayerOrPetInParty(arg4) ) then
					--do nothing
				else
					local B = tonumber(arg3:sub(5,5), 16);
					local player = B % 8; -- x % 8 has the same effect as x & 0x7 on numbers <= 0xf
					--local knownTypes = {[0]="player", [3]="NPC", [4]="pet", [5]="vehicle"};
					if(player == 0 or player == 4) then
						SpellLock:NewLockBar(true, cd, arg3, arg4, arg9, arg10)
					end
				end
			end
		end
	end
  end
  
	if(event == "ZONE_CHANGED_NEW_AREA") then
		local zone = select(2, IsInInstance())
			
		if (zone == "arena") then
			SpellLock.db.char.inArena = true
		elseif (zone ~= "arena" and lastZone == "arena") then
			SpellLock.db.char.inArena = false
		end
		
		lastZone = zone
	end
end


local function Enable()
	eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
	eventFrame:Show()
 end
 
 local function Disable()
	eventFrame:Hide()
	eventFrame:UnregisterAllEvents()
end

function SpellLock:OnEnable()
	Enable()
end

function SpellLock:OnDisable()
	Disable()
end

options = {
  type="group",
  args={
	general={
		type = 'group',
		name = "General Settings",
		args={
			description={
			  name="Basic options for SpellLock\n",
			  type="description",
			  order = 1
			},
			enableAddon={
			  name="Enable Addon",
			  desc="Enables / disables the addon",
			  order = 2,
			  type="toggle",
			  set = function(info,val) SpellLock.db.char.enabled = val end,
			  get = function(info) return SpellLock.db.char.enabled end
			},
			showInternalBars={
			  name="Show Internal Bars",
			  desc="Shows / Hides Internal Bars.",
			  order = 3,
			  type="toggle",
			  set = function(info,val) SpellLock.db.char.showInternalBars = val end,
			  get = function(info) return SpellLock.db.char.showInternalBars end
			},
			showCooldownBars={
			  name="Show enemy cooldowns.",
			  desc="Shows / Hides the showing of enemy interrupt cooldowns.",
			  order = 4,
			  type="toggle",
			  set = function(info,val) SpellLock.db.char.coolDownEnabled = val end,
			  get = function(info) return SpellLock.db.char.coolDownEnabled end
			},
			enableSendToParty={
			  name="Enable send to party",
			  desc="Enables / disables writing to party chat",
			  order = 5,
			  type="toggle",
			  set = function(info,val) SpellLock.db.char.partyChat = val end,
			  get = function(info) return SpellLock.db.char.partyChat end
			},
			useDBM={
			  name="Use DBM Output",
			  desc="Enables / disables using DBM bars and warnings",
			  order = 6,
			  type="toggle",
			  set = function(info,val) SpellLock.db.char.useDBM = val end,
			  get = function(info) return SpellLock.db.char.useDBM end
			},
		}
	},
	intBarSettings={
		type = 'group',
		name = "Internal Bars",
		args={
			description={
			  name="Internal bar options\n",
			  type="description",
			  order = 1
			},
			reverseGrowth={
			name="Toggle reverse growth.",
			desc="Makes the bar list grow upwards.",
			order = 6,
			type="toggle",
			set = function(info,val) SpellLock.db.char.growUp = val; SpellLock:UpdateAnchor(); end,
			get = function(info) return SpellLock.db.char.growUp end
			},
			showAnchor={
			  name="Toggle Anchor",
			  desc="Shows / Hides the anchor.",
			  order = 2,
			  type="execute",
			  func = function() anchor:ToggleAnchor() end
			},
			testBars={
			  name="Test Bars",
			  desc="Displays three test bars.",
			  order = 3,
			  type="execute",
			  func = function() SpellLock:TestBars() end
			},
			barWidth={
				name="Bar width",
				desc="Edit bar width.",
				order = 4,
				type="range",
				min=50,
				max=500,
				step=10,
				set = function(info,val) SpellLock.db.char.barWidth = val; SpellLock:UpdateAnchor(); end,
				get = function(info) return SpellLock.db.char.barWidth end
			},
			barHeight={
				name="Bar Height",
				desc="Edit bar Height.",
				order = 5,
				type="range",
				min=15,
				max=50,
				step=1,
				set = function(info,val) SpellLock.db.char.barHeight = val; SpellLock:UpdateAnchor(); end,
				get = function(info) return SpellLock.db.char.barHeight end
			}
		}
	}
  }
}

SpellLock:RegisterChatCommand("slock", "OpenOptions")
SpellLock:RegisterChatCommand("spelllock", "OpenOptions")

function SpellLock:OpenOptions(msg)
	if(msg == "anchor") then anchor:ToggleAnchor()
	elseif(msg == "test") then SpellLock:TestBars()
	else
		LibStub("AceConfigDialog-3.0"):Open("SpellLock")
	end
end

AceConfig:RegisterOptionsTable("SpellLock", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SpellLock", "SpellLock")

eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:SetScript("OnUpdate", OnUpdateDelayedInfo)
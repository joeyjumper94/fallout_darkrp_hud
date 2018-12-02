local function init()
	if SERVER then
		AddCSLuaFile("autorun/fallout_hud.lua")
		if true then
			resource.AddWorkshop(631583771)
		else
			resource.AddFile("materials/hud/fo/ammo.vmt")
			resource.AddFile("materials/hud/fo/ammo.vtf")
			resource.AddFile("materials/hud/fo/armor.vmt")
			resource.AddFile("materials/hud/fo/armor.vtf")
			resource.AddFile("materials/hud/fo/compass.vmt")
			resource.AddFile("materials/hud/fo/compass.vtf")
			resource.AddFile("materials/hud/fo/life_hud.vmt")
			resource.AddFile("materials/hud/fo/life_hud.vtf")
			resource.AddFile("materials/hud/fo/tick.vmt")
			resource.AddFile("materials/hud/fo/tick.vtf")
			resource.AddFile("sound/death.mp3")
		end
		return
	end
	hook.Remove("HUDPaint","StarWars.HUDPaint")
	hook.Remove("HUDPaint","QuantumMain")
	hook.Remove("HUDShouldDraw","MHUD_Hide")
	hook.Remove("Tick","MHUDATick")
	hook.Remove("Tick","MHUDAgTick")
	hook.Remove("HUDPaint","MHUDEntityDisplay")
	hook.Remove("InitPostEntity","MHUDInit")
	hook.Remove("Tick","MHUDTick")
	hook.Remove("HUDPaint","GraphiteAgenda")
	hook.Remove("HUDPaint","GraphiteAmmo")
	hook.Remove("HUDPaint","GraphiteBase")
	hook.Remove("HUDPaint","GraphiteDoor")
	hook.Remove("HUDPaint","GraphiteLevel")
	hook.Remove("HUDPaint","GraphiteNotifications")
	hook.Remove("HUDPaint","mlphud")
	hook.Remove("Initialize","mlphudfont")
	hook.Remove("PopulateToolMenu","MLPHUDOptioncreate")
	hook.Remove("HUDPaint","DarkRP_Mod_HUDPaint_2")--remove wolven's HUD
	hook.Remove("HUDPaint","DarkRP_Mod_HUDPaint")--remove part of pony wither's hud
	hook.Remove("HUDShouldDraw","disableHUD")
	hook.Remove("HUDPaint","karma_localInfo2")
	if modelPanel and modelPanel:IsValid() then
		modelPanel:Remove()
	end
	if av and av:IsValid() then
		av:Remove()--remove the image from wolven's hud
	end
	if MHUD and MHUD:IsValid() then
		MHUD:Remove()--remove TPLs hud
	end
	if MHUDAg and MHUDAg:IsValid() then
		MHUDAg:Remove()--remove TPLs hud
	end
	if MHUDA and MHUDA:IsValid() then
		MHUDA:Remove()--remove TPLs hud
	end
	if GetAvatarPanel then
		local a=GetAvatarPanel()
		if a and a:IsValid() then
			a:Remove()--remove the image from wolven's hud
		end
	end
	hook.Remove("PlayerSwitchWeapon","HideHUDWIthCamera")

	net.Receive("pma_create_aura",function() end)
	net.Receive("pma_remove_aura",function() end)
	hook.Remove("PhysgunPickup","pma_pickup")
	hook.Remove("PhysgunDrop","pma_drop")
	hook.Remove("PostDrawTranslucentRenderables","pma_draw")

	local hideHUDElements={
		--if you DarkRP_HUD this to true, ALL of DarkRP's HUD will be disabled. That is the health bar and stuff,
		--but also the agenda, the voice chat icons, lockdown text, player arrested text and the names above players' heads
		["DarkRP_HUD"]=true,

		--DarkRP_EntityDisplay is the text that is drawn above a player when you look at them.
		--This also draws the information on doors and vehicles
		["DarkRP_EntityDisplay"]=true,

		--This is the one you're most likely to replace first
		--DarkRP_LocalPlayerHUD is the default HUD you see on the bottom left of the screen
		--It shows your health, job, salary and wallet, but NOT hunger(if you have hungermod enabled)
		["DarkRP_LocalPlayerHUD"]=true,

		--If you have hungermod enabled, you will see a hunger bar in the DarkRP_LocalPlayerHUD
		--This does not get disabled with DarkRP_LocalPlayerHUD so you will need to disable DarkRP_Hungermod too
		["DarkRP_Hungermod"]=true,

		--Drawing the DarkRP agenda
		["DarkRP_Agenda"]=false,

		--Lockdown info on the HUD
		["DarkRP_LockdownHUD"]=false,

		--Arrested HUD
		["DarkRP_ArrestedHUD"]=false,
	}
	--this is the code that actually disables the drawing.
	hook.Add("HUDShouldDraw","HideDefaultDarkRPHud",function(name)
		if hideHUDElements[name] then
			return false
		end
	end)

	hook.Add("PlayerSpawn","GetPLYCollor",function(ply)
		ply:SetNWVector("hudColor",Vector(ply:GetWeaponColor().x*255,ply:GetWeaponColor().y*255,ply:GetWeaponColor().z*255))
	end)

	trace=ErrorNoHalt

	local function Agenda()
		local agenda=LocalPlayer():getAgendaTable()
		if not agenda then return end

		draw.RoundedBox(10,10,10,460,110,Color(0,0,0,155))
		draw.RoundedBox(10,12,12,456,106,Color(51,58,51,100))
		draw.RoundedBox(10,12,12,456,20,Color(0,0,70,100))

		draw.DrawNonParsedText(agenda.Title,"FOFont_normal",30,12,Color(255,0,0,255),0)

		local text=LocalPlayer():getDarkRPVar("agenda") or ""

		text=text:gsub("//","\n"):gsub("\\n","\n")
		text=DarkRP.textWrap(text,"FOFont_normal",440)
		draw.DrawNonParsedText(text,"FOFont_normal",30,35,Color(255,255,255,255),0)
	end

	local VoiceChatTexture=surface.GetTextureID("voice/icntlk_pl")
	local function DrawVoiceChat()
		if SERVER then return end
		if LocalPlayer().DRPIsTalking then
			local chbxX,chboxY=chat.GetChatBoxPos()

			local Rotating=math.sin(CurTime()*3)
			local backwards=0
			if Rotating<0 then
				Rotating=1-(1+Rotating)
				backwards=180
			end
			surface.SetTexture(VoiceChatTexture)
			surface.SetDrawColor(Color(140,0,0,180))
			surface.DrawTexturedRectRotated(ScrW()-100,chboxY,Rotating*96,96,backwards)
		end
	end

	local function LockDown()
		local chbxX,chboxY=chat.GetChatBoxPos()
		if GetGlobalBool("DarkRP_LockDown") then
			local cin=(math.sin(CurTime())+1)/2
			local chatBoxSize=math.floor(ScrH()/4)
			draw.DrawNonParsedText(DarkRP.getPhrase("lockdown_started"),"FOFont_normal",chbxX+60,chboxY,Color(cin*255,0,255-(cin*255),255),TEXT_ALIGN_LEFT)
		end
	end

	local Arrested=function() end

	usermessage.Hook("GotArrested",function(msg)
		local StartArrested=CurTime()
		local ArrestedUntil=msg:ReadFloat()
		
		local ArrestedY=ScrW()/2
		local ArrestedX=ScrH()/1.2
		local c=LocalPlayer():GetPlayerColor()*255
		Arrested=function()
			if CurTime()-StartArrested<=ArrestedUntil and LocalPlayer():getDarkRPVar("Arrested") then
				draw.DrawNonParsedText(DarkRP.getPhrase("youre_arrested",math.ceil(ArrestedUntil-(CurTime()-StartArrested))),"FOFont_normal",ArrestedX,ArrestedY,Color(c.x,c.y,c.z,255),1)
			elseif !LocalPlayer():getDarkRPVar("Arrested") then
				Arrested=function() end
			end
		end
	end)

	local AdminTell=function() end

	usermessage.Hook("AdminTell",function(msg)
		timer.Remove("DarkRP_AdminTell")
		local Message=msg:ReadString()

		AdminTell=function()
			draw.RoundedBox(4,10,10,ScrW()-20,100,Color(0,0,0,200))
			draw.DrawNonParsedText(DarkRP.getPhrase("listen_up"),"FOFont_huge",ScrW()/2+10,10,Color(255,255,255,255),1)
			draw.DrawNonParsedText(Message,"FOFont_normal",ScrW()/2+10,80,Color(200,30,30,255),1)
		end

		timer.Create("DarkRP_AdminTell",10,1,function()
			AdminTell=function() end
		end)
	end)

	local dangerous={--if the value is false, we draw nothing
		gmod_camera=false,
		gmod_tool=false,
		pocket=false,
		keys=false,
		med_kit=false,
		weapon_blowtorch=false,
		weapon_medkit=false,
		weapon_keypadchecker=false,
		weapon_physcannon=false,
		weapon_physgun=false,
		weaponchecker=false,
		weaponchecker=false,
		none=false,
		unarrest_stick=false,
		
		
		arrest_stick=true,
		stunstick=true,
		weapon_stunstick=true,
		weapon_357=true,
	}
	local function DrawPlayerInfo(ply,showhealth)
		local pos=ply:EyePos()

		pos.z=pos.z+10
		pos=pos:ToScreen()
		pos.y=pos.y-50

		if DarkRP then
			draw.DrawText(ply:Nick(),"FOFont_normal",pos.x+1,pos.y+5+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.DrawText(ply:Nick(),"FOFont_normal",pos.x,pos.y+5,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			if GAMEMODE.Config.showhealth or showhealth then
				draw.DrawText(DarkRP.getPhrase("health",(ply:Health() or 0)),"FOFont_normal",pos.x+1,pos.y+35+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.DrawText(DarkRP.getPhrase("health",(ply:Health() or 0)),"FOFont_normal",pos.x,pos.y+35,Color(192,57,43,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
			local teamname=team.GetName(ply:Team())
			draw.DrawText("Job: "..(ply:getDarkRPVar("job") or teamname or "nil"),"FOFont_normal",pos.x+1,pos.y+60+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.DrawText("Job: "..(ply:getDarkRPVar("job") or teamname or "nil"),"FOFont_normal",pos.x,pos.y+60,team.GetColor(ply:Team()),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			local weapon=ply:GetActiveWeapon()
			weapon=weapon:IsValid() and weapon:GetClass():lower() or "none"
			if dangerous[weapon]==false then
				--nothing to worry about here
			elseif dangerous[weapon]==true then
				draw.DrawText("Visibly armed","FOFont_normal",pos.x+1,pos.y+85+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.DrawText("Visibly armed","FOFont_normal",pos.x,pos.y+85,team.GetColor(ply:Team()),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			elseif weapon:StartWith("weapon_vape") then
				dangerous[weapon]=false--mark it as safe
			elseif weapon:StartWith("cw") or weapon:StartWith("m9k") or weapon:StartWith("fas") or weapon:StartWith("weapon") then
				dangerous[weapon]=true--cache it in the table so we don't have to do the find operation again
				draw.DrawText("Visibly armed","FOFont_normal",pos.x+1,pos.y+85+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.DrawText("Visibly armed","FOFont_normal",pos.x,pos.y+85,team.GetColor(ply:Team()),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			else--unknown weapon
				draw.DrawText("active weapon: "..weapon,"FOFont_normal",pos.x+1,pos.y+85+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.DrawText("active weapon: "..weapon,"FOFont_normal",pos.x,pos.y+85,team.GetColor(ply:Team()),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
			local Page=Material("icon16/page_white_text.png")
			local function GunLicense()
				if LocalPlayer():getDarkRPVar("HasGunlicense") then

					surface.SetMaterial(Page)
					surface.SetDrawColor(255,255,255,255)
					surface.DrawTexturedRect(Settings.PosX+Settings.Width+10,Settings.PosY+Settings.Height-32,32,32)

				end
			end
		else
			draw.DrawText(ply:Name(),"FOFont_normal",pos.x+1,pos.y+5+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.DrawText(ply:Name(),"FOFont_normal",pos.x,pos.y+5,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
			draw.DrawText("HP: "..(ply:Health() or 0),"FOFont_normal",pos.x+1,pos.y+35+1,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.DrawText("HP: "..(ply:Health() or 0),"FOFont_normal",pos.x,pos.y+35,Color(192,57,43,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local function DrawWantedInfo(ply)
		if not ply:Alive() then return end

		local pos=ply:EyePos()
		if not pos:isInSight({LocalPlayer(),ply}) then return end

		pos.z=pos.z+10
		pos=pos:ToScreen()
		pos.y=pos.y-50
		
		local wantedText=DarkRP.getPhrase("wanted",tostring(ply:getDarkRPVar("wantedReason")))
		
--		draw.RoundedBox(4,pos.x-51,pos.y-100-5,100+2,30+2,Color(30,30,30,255))
--		draw.RoundedBox(4,pos.x-50,pos.y-99-5,100,30,Color(70,70,70,255))
		
		draw.DrawText(wantedText,"FOFont_normal",pos.x+1,pos.y-99,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.DrawText(wantedText,"FOFont_normal",pos.x,pos.y-100,Color(255,0,0,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local medkits={
		med_kit=true,
		weapon_medkit=true,
	}
	local function DrawEntityDisplay()
		local showhealth=false
		local ViewPos=vector_origin
		local ViewEnt=GetViewEntity()
		local SpecEnt=FSpectate and FSpectate.getSpecEnt()
		if SpecEnt and SpecEnt.GetShootPos then
			ViewPos=SpecEnt:GetShootPos()
			showhealth=true
		elseif SpecEnt and SpecEnt.GetPos then
			ViewPos=SpecEnt:GetPos()
			showhealth=true
		elseif ViewEnt.GetShootPos then
			ViewPos=ViewEnt:GetShootPos()
		elseif ViewEnt.GetPos then
			ViewPos=ViewEnt:GetPos()
		end
--		local showall=GetViewEntity()!=LocalPlayer()
		local aimVec=LocalPlayer():GetAimVector()
		for int,swep in pairs(LocalPlayer():GetWeapons()) do
			if medkits[swep:GetClass()] then
				showhealth=true
				break
			end
		end
		for k,ply in pairs(players or player.GetAll()) do
			if !ply:Alive() or ply==ViewEnt and !SpecEnt then continue end
			local hisPos=ply:GetShootPos()
			if DarkRP and ply:getDarkRPVar("wanted") then DrawWantedInfo(ply) end
			if SpecEnt and hisPos:DistToSqr(ViewPos)<40000 then
				DrawPlayerInfo(ply,showhealth)
			elseif hisPos:DistToSqr(ViewPos)<500000 then
				local pos=hisPos-ViewPos
--				local unitPos=pos:GetNormalized()
--				if unitPos:Dot(aimVec)>0.95 then
					local trace=util.QuickTrace(ViewPos,pos,{LocalPlayer(),GetViewEntity()})
					if trace.Hit and trace.Entity!=ply then
					else
						DrawPlayerInfo(ply,showhealth)
					end
--				end
			end
		end
		
		if !DarkRP then return end

		local tr=LocalPlayer():GetEyeTrace()

		if IsValid(tr.Entity) and tr.Entity:isKeysOwnable() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos())<200 then
			tr.Entity:drawOwnableInfo()
		end
	end

	usermessage.Hook("_Notify",function(msg)
		local txt=msg:ReadString()
		GAMEMODE:AddNotify(txt,msg:ReadShort(),msg:ReadLong())
		surface.PlaySound("buttons/lightswitch2.wav")
		--Log to client console
		print(txt)
	end)


	hook.Add("HUDDrawTargetID","DisableDrawInfo",function()
		return false
	end)


	hook.Add("HUDPaint","DrawFOH",function()
--		if game.SinglePlayer() then return end
		if DarkRP then
			Agenda()
			DrawVoiceChat()
			LockDown()
			Arrested()
			AdminTell()
		end
		DrawEntityDisplay()
	end)

	local tohide={--This is a table where the keys are the HUD items to hide
		["CHudHealth"]=true,
		["CHudBattery"]=true,
		["CHudAmmo"]=true,
		["CHudDamageIndicator"]=true,
		["CHudSecondaryAmmo"]=true,
	}

	hook.Add("HUDShouldDraw","HUDDisabler",function(name)
		if tohide[name]then
			return false
		end
	end)


	 
	hook.Add("RenderScreenspaceEffects","DownEffect",function()
		if LocalPlayer()  then
			if LocalPlayer():Health()<=0 then
				local tab={
					["$pp_colour_addr"]=0,
					["$pp_colour_addg"]=0,
					["$pp_colour_addb"]=0,
					["$pp_colour_brightness"]=0,
					["$pp_colour_contrast"]=1,
					["$pp_colour_colour"]=0,
					["$pp_colour_mulr"]=0.5,
					["$pp_colour_mulg"]=0.5,
					["$pp_colour_mulb"]=0.5,
				}
				DrawColorModify(tab)
				DrawBloom(0.2,0.2,0.2,0.2,0.2,3,2,2,2)
			end
		end
	 
	end)

	usermessage.Hook("FOSound",function(data)
		if(LocalPlayer():IsValid()) then
			--LocalPlayer():EmitSound("death.mp3")--Plays Sound to Everyone Online, Needs Looking Into.
		end
	end)


	hook.Add("PlayerSpawn","SetAttributes",function(ply)
		ply:SetNWInt("AP",100)
	end)

	hook.Add("PlayerDeath","playerDeathTest",function(victim,weapon,killer)
--		umsg.Start("FOSound")
--		umsg.Entity(target)
--		umsg.End()
	end)

	hook.Add("PlayerDeathSound","OverrideDeathSound",function()
		return true
	end)


	local FalloutHUD={}

	surface.CreateFont("FOFont_big",{
		font="Impact",
		size=45,
		weight=400,
		underline=0,
		additive=false,
		outline=false,
		blursize=0
	})
	surface.CreateFont("FOFont_huge",{
		font="Impact",
		size=80,
		weight=400,
		underline=0,
		additive=false,
		outline=false,
		blursize=0
	})

	surface.CreateFont("FOFont_big_blur",{
		font="Impact",
		size=45,
		weight=400,
		underline=0,
		additive=false,
		outline=false,
		blursize=5
	})

	surface.CreateFont("FOFont_normal",{
		font="Impact",
		size=25,
		weight=400,
		underline=0,
		additive=false,
		outline=false,
		blursize=0
	})

	surface.CreateFont("FOFont_normal_blur",{
		font="Impact",
		size=25,
		weight=400,
		underline=0,
		additive=false,
		outline=false,
		blursize=5
	})
	 
	local localplayer
	local compass=surface.GetTextureID("hud/fo/compass") 
	--local player=surface.GetTextureID("hud/fo/player_found") 
	local htick=surface.GetTextureID("hud/fo/tick") 
	local hbar=surface.GetTextureID("hud/fo/life_hud") 
	local armor=surface.GetTextureID("hud/fo/armor") 
	local htock=surface.GetTextureID("hud/fo/tick") 
	local hammo=surface.GetTextureID("hud/fo/ammo") 
	getHUDColor=Vector(0,0,0)

	local function drawBlur(x,y,text,allign,blur)

		local c=LocalPlayer():GetPlayerColor()*255
		getHUDColor=Vector(c.x,c.y,c.z)

		if !blur then
			for i=0,1 do
				draw.SimpleText(text,"FOFont_normal_blur",x,y,Color(getHUDColor.x-20,getHUDColor.y-20,getHUDColor.z-20,200),allign,0)
			end

			draw.SimpleText(text,"FOFont_normal",x,y,Color(getHUDColor.x+40,getHUDColor.y+40,getHUDColor.z+40,255),allign,0)

		else

			for i=0,1 do
				draw.SimpleText(text,"FOFont_big_blur",x,y,Color(getHUDColor.x-20,getHUDColor.y-20,getHUDColor.z-20,200),allign,0)
			end

			draw.SimpleText(text,"FOFont_big",x,y,Color(getHUDColor.x+40,getHUDColor.y+40,getHUDColor.z+40,255),allign,0)

		end

	end

	hook.Add("HUDPaint","FalloutHUD.draw",function()
		if !LocalPlayer():Alive() then return end
		local magic=LocalPlayer().DarkRPVars and LocalPlayer().DarkRPVars.magic
		local magic_offset=0
		local job
		if TeamTable then
			local tbl=TeamTable[LocalPlayer():Team()]
			if tbl and tbl.Name and tbl.Regiment then
				job=tbl.Regiment.." "..tbl.Name
			end
		elseif LocalPlayer().DarkRPVars then
			job=LocalPlayer().DarkRPVars.job
		end
		
		if magic then
			drawBlur(90,ScrH()-135," magic: "..math.Round(magic,3),3)
			magic_offset=20
		end
		if DarkRP and !DarkRP.disabledDefaults["modules"]["hungermod"] then
			drawBlur(90,ScrH()-195-magic_offset," Name: "..(LocalPlayer().DarkRPVars.rpname or ""),0)
			if job then
				drawBlur(90,ScrH()-175-magic_offset," Job: "..job,0)
			end
			drawBlur(90,ScrH()-155-magic_offset," HP: "..tostring(LocalPlayer():Health()).." Armor: "..tostring(LocalPlayer():Armor()),0)
			drawBlur(90,ScrH()-135-magic_offset," Hunger: "..(LocalPlayer().DarkRPVars.Energy and math.Round(LocalPlayer().DarkRPVars.Energy,3) or "nil"),0)
		else
			drawBlur(90,ScrH()-175-magic_offset," Name: "..LocalPlayer():Name(),0)
			if job then
				drawBlur(90,ScrH()-155-magic_offset," Job: "..job,0)
			end
			drawBlur(90,ScrH()-135-magic_offset," HP: "..tostring(LocalPlayer():Health()).." Armor: "..tostring(LocalPlayer():Armor()),0)
		end
		if LevelSystemConfiguration then
			local XP=LocalPlayer():getDarkRPVar('xp') or 0
			local PlayerLevel=LocalPlayer():getDarkRPVar('level')
			local total=XP/((XP or 0)/(((10+(((PlayerLevel or 1)*((PlayerLevel or 1)+1)*90))))*LevelSystemConfiguration.XPMult))
			local tonext=total-XP
			drawBlur(ScrW()-95,ScrH()-235," Next: "..(tonext or "nil"),2)
			drawBlur(ScrW()-95,ScrH()-215," Xp: "..(LocalPlayer():getDarkRPVar('xp') or "nil").."/"..(total or "nil"),2)
			drawBlur(ScrW()-95,ScrH()-195," Level: "..(LocalPlayer():getDarkRPVar('level') or "nil"),2)
		end
		
		local ClDatTab=ClDatTab or {}
		net.Receive("ClUpdB", function()
			ClDatTab = net.ReadTable()
		end)
		if LocalPlayer().GetKarma then
			drawBlur(ScrW()-95,ScrH()-195," karma: "..(LocalPlayer():GetKarma() or "nil"),2)
		end
		if ClDatTab["CuB"] then
			drawBlur(ScrW()-95,ScrH()-215," Your bounty: "..DarkRP.formatMoney(ClDatTab["CuB"][LocalPlayer()] or 0),2)
		end
		if LocalPlayer().DarkRPVars then
			drawBlur(ScrW()-95,ScrH()-175," Salary: "..(LocalPlayer().DarkRPVars.salary or "nil"),2)
			drawBlur(ScrW()-95,ScrH()-155," Bottlecaps: "..(LocalPlayer().DarkRPVars.money or "nil"),2)
		end
		if LocalPlayer():GetActiveWeapon():IsValid() then

			if LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())>0 || LocalPlayer():GetActiveWeapon():Clip1()>-1 then

				if(LocalPlayer():GetActiveWeapon():Clip1()>-1) then
					drawBlur(ScrW()-95,ScrH()-80,tostring(LocalPlayer():GetActiveWeapon():Clip1()).."/"..tostring(LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())),2)
				else
					drawBlur(ScrW()-95,ScrH()-80,tostring(LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())),2)
				end

			end

		end

		surface.SetTexture(compass)
		surface.SetDrawColor(getHUDColor.x+25,getHUDColor.y+25,getHUDColor.z+25,255)
		surface.DrawPartialTexturedRect(82,ScrH()-97,256,64,(-LocalPlayer():GetAngles().y/360)*1024+143,0,256,64,1024,64)

	end)
	hook.Add("HUDPaint","FalloutHUD_draw",FalloutHUD.draw)

	function surface.DrawPartialTexturedRect(x,y,w,h,partx,party,partw,parth,texw,texh)
		--[[ 
			Arguments:
			x: Where is it drawn on the x-axis of your screen
			y: Where is it drawn on the y-axis of your screen
			w: How wide must the image be?
			h: How high must the image be?
			partx: Where on the given texture's x-axis can we find the image you want?
			party: Where on the given texture's y-axis can we find the image you want?
			partw: How wide is the partial image in the given texture?
			parth: How high is the partial image in the given texture?
			texw: How wide is the texture?
			texh: How high is the texture?
		]]--
		 
		--Verify that we recieved all arguments
		if not(x && y && w && h && partx && party && partw && parth && texw && texh) then 
			return
		end
		 
		--Get the positions and sizes as percentages/100
		local percX,percY=partx/texw,party/texh
		local percW,percH=partw/texw,parth/texh
		 
		--Process the data
		local vertexData={
			{
				x=x,
				y=y,
				u=percX,
				v=percY
			},
			{
				x=x+w,
				y=y,
				u=percX+percW,
				v=percY
			},
			{
				x=x+w,
				y=y+h,
				u=percX+percW,
				v=percY+percH
			},
			{
				x=x,
				y=y+h,
				u=percX,
				v=percY+percH
			}
		}
			 
		surface.DrawPoly(vertexData)
	end
	 
	--A function to draw a certain part of a texture
	function draw.DrawPartialTexturedRect(x,y,w,h,partx,party,partw,parth,texturename)
		--[[ 
			Arguments:
			-Also look at the arguments of the surface version of this
			texturename: What is the name of the texture?
		]]--
		 
		--Verify that we recieved all arguments
		if not(x && y && w && h && partx && party && partw && parth && texturename) then
			 
			return
		end
		 
		--Get the texture
		local texture=surface.GetTextureID(texturename)
		 
		--Get the positions and sizes as percentages/100
		local texW,texH=surface.GetTextureSize(texture)
		local percX,percY=partx/texW,party/texH
		local percW,percH=partw/texW,parth/texH
		 
		--Process the data
		local vertexData={
			{
				x=x,
				y=y,
				u=percX,
				v=percY
			},
			{
				x=x+w,
				y=y,
				u=percX+percW,
				v=percY
			},
			{
				x=x+w,
				y=y+h,
				u=percX+percW,
				v=percY+percH
			},
			{
				x=x,
				y=y+h,
				u=percX,
				v=percY+percH
			}
		}
		 
		surface.SetTexture(texture)
		surface.SetDrawColor(255,255,255,255*multiplo_fixture)
		surface.DrawPoly(vertexData)
	end

--[[unused function
	function GetAngleOfLineBetweenTwoPoints(p1,p2)

		xDiff=p2:GetPos().x-p1:GetPos().x 
		yDiff=p2:GetPos().y-p1:GetPos().y 

		return math.atan2(yDiff,xDiff)*(180/math.pi)

	end
--]]
	hook.Add("HUDPaint","FOHL",function()
		local c=LocalPlayer():GetPlayerColor()*255
		text=Vector(c.x,c.y,c.z)
		
		surface.SetTexture(hbar)
		surface.SetDrawColor(text.x+40,text.y+40,text.z+40,255)
		surface.DrawTexturedRectRotated(264,ScrH()-40,390,200,0)

		if(LocalPlayer():Health()<=LocalPlayer():GetMaxHealth() && LocalPlayer():Health()>0) then

			hl=LocalPlayer():Health()/LocalPlayer():GetMaxHealth()*100

			for i=0,hl/2.75 do

				surface.SetTexture(htick)
				surface.SetDrawColor(text.x+25,text.y+25,text.z+25,255)
				surface.DrawTexturedRectRotated(92.5+i*6,ScrH()-100,20,24,0)

			end

		elseif(LocalPlayer():Health()>0) then

			for i=0,36.3636 do
				surface.SetTexture(htick)
				surface.SetDrawColor(text.x+25,text.y+25,text.z+25,255)
				surface.DrawTexturedRectRotated(92.5+i*6,ScrH()-100,20,24,0)
			end

		end

		if(LocalPlayer():Armor()>0) then
			surface.SetTexture(armor)
			surface.SetDrawColor(text.x+25,text.y+25,text.z+25,255)
			surface.DrawTexturedRectRotated(327,ScrH()-102,20,20,0)
		end

	end)

	hook.Add("HUDPaint","DrawHUDFO",function() 

		local c=LocalPlayer():GetPlayerColor()*255
		getHUDColor=Vector(c.x,c.y,c.z)

		surface.SetTexture(hammo)
		surface.SetDrawColor(getHUDColor.x+40,getHUDColor.y+40,getHUDColor.z+40,255)
		surface.DrawTexturedRectRotated(ScrW()-170,ScrH()-40,390,200,0)

		if(LocalPlayer():GetNWInt("AP",0)<=100 && LocalPlayer():GetNWInt("AP",0)>0) then

			hl=LocalPlayer():GetNWInt("AP",0)

			for i=0,hl/2.75 do

				surface.SetTexture(htock)
				surface.SetDrawColor(getHUDColor.x+25,getHUDColor.y+25,getHUDColor.z+25,255)
				surface.DrawTexturedRectRotated(ScrW()-90-i*6,ScrH()-100,20,24,0)

			end

		elseif(LocalPlayer():Health()>0) then

			for i=0,36.3636 do

				surface.SetTexture(htock)
				surface.SetDrawColor(getHUDColor.x+25,getHUDColor.y+25,getHUDColor.z+25,255)
				surface.DrawTexturedRectRotated(ScrW()-100-i*7,ScrH()-116,24,30,0)
			end
		end
	end)
end
hook.Add("Initialize","fallout_hud",init)
if player.GetAll()[1] or LocalPlayer and LocalPlayer():IsValid() then init() end
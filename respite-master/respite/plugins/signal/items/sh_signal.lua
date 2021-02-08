ITEM.name = "Signalling Device"
ITEM.desc = "A device that allows you to send a simple message to radios or other signalling devices.\nPower: %s\nFrequency: %s"
ITEM.model = "models/gibs/shield_scanner_gib1.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Communication"
ITEM.price = 150
ITEM.flag = "v"
ITEM.uniqueID = "comm_signal"

ITEM.iconCam = {
	pos = Vector(0, 0, 200),
	ang = Angle(90, 0, -60),
	fov = 2.5,
}

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("power", false)) then
			surface.SetDrawColor(110, 110, 255, 100)
		else
			surface.SetDrawColor(255, 110, 110, 100)
		end

		surface.DrawRect(w - 14, h - 14, 8, 8)
	end

	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	local COLOR_ACTIVE = Color(0, 0, 255)
	local COLOR_INACTIVE = Color(255, 0, 0)

	function ITEM:drawEntity(entity, item)
		entity:DrawModel()
		local rt = RealTime()*100
		local position = entity:GetPos() + entity:GetForward() * 0 + entity:GetUp() * 2 + entity:GetRight() * 0

		if (entity:getData("power", false) == true) then
			if (math.ceil(rt/14)%10 == 0) then
				render.SetMaterial(GLOW_MATERIAL)
				render.DrawSprite(position, rt % 14, rt % 14, entity:getData("power", false) and COLOR_ACTIVE or COLOR_INACTIVE)
			end
		end
	end
end

// On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.toggle = { -- sorry, for name order.
	name = "Toggle",
	tip = "useTip",
	icon = "icon16/connect.png",
	onRun = function(item)
		item:setData("power", !item:getData("power", false), player.GetAll(), false, true)
		item.player:EmitSound("buttons/button14.wav", 70, 150)

		return false
	end
}

ITEM.functions.use = { -- sorry, for name order.
	name = "Freq",
	tip = "useTip",
	icon = "icon16/wrench.png",
	onRun = function(item)
		netstream.Start(item.player, "signalAdjust", item:getData("freq", "000,0"), item.id)

		return false
	end
}

function ITEM:getDesc(partial)
	local desc = self.desc
	
	if(!partial) then
		local PLUGIN = nut.plugin.list["signal"]
		
		desc = desc.. "\n\n"
		
		for k, v in pairs(PLUGIN.codeList) do
			desc = desc..k.. ": " ..v
			
			if(k < #PLUGIN.codeList) then
				desc = desc.. ", "
			end
		end
	end
	
	if (!self.entity or !IsValid(self.entity)) then
		return Format(desc, (self:getData("power") and "On" or "Off"), self:getData("freq", "000.0"))
	else
		local data = self.entity:getData()
	
		return Format(desc, (self.entity:getData("power") and "On" or "Off"), self.entity:getData("freq", "000.0"))
	end
end

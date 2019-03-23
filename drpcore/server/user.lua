function CreateUser(source, identifier)
  local self = {
    source = source,
		identifier = identifier,
		playerData = {},
		characters = {},
    permissions = {},
		job = {
			name = nil,
			label = nil,
			grade = nil,
			grade_label = nil,
			salary = 0
		}
	}

  self.setCoords = function(x, y, z)
    self.playerData.coords = { x = x, y = y, z = z}
  end

  self.getCoords = function()
    return self.playerData.coords
  end

  self.removeInventoryItem = function(item, count)
    if self.playerData.inventory[item] == nil then
      self.playerData.inventory[item] = 0
    else
      self.playerData.inventory[item] = self.playerData.inventory[item] - count
    end

    TriggerEvent("drp/inventory:onRemoveInventoryItem", self.source, item, count)
    TriggerClientEvent("drp/inventory:removeInventoryItem", self.source, item, count)
  end

  self.addInventoryItem = function(item, count)
    if self.playerData.inventory[item] == nil then
      self.playerData.inventory[item] = count
    else
      self.playerData.inventory[item] = self.playerData.inventory[item] + count
    end

    TriggerEvent("drp/inventory:onAddInventoryItem", self.source, item, count)
    TriggerClientEvent("drp/inventory:addInventoryItem", self.source, item, count)
  end

  return self
end
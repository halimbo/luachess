require("global")
Input = {}
function Input:new()
	local i = {}
	setmetatable(i,self)
	self.__index = self
	function i:deselect()
		self.selected = false
	end
	function i:mouseOff(T,here)
		if here==self.selected then
			return true,false
		end
		local newT = T:move(self.selected,here)
		if newT then
			self.selected = false
			return false, newT
		else
			self:deselect()
			return false
		end
	end
	function i:touch(T,here)
		if self.selected then
			if here==self.selected then
				return true
			else
				local newT = T:move(self.selected,here)
				if not newT and T:isPiece(here) then
					self.selected = loc:new(here.x,here.y)
					return true
				elseif not newT then
					self:deselect()
					return false
				elseif newT then
					self.selected = false
					return false,newT
				end
			end
		else
			if T:isPiece(here) then
				self.selected = loc:new(here.x,here.y)
				return true
			else
				return false
			end
		end
	end
	return i
end

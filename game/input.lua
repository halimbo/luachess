require("global")
function click_and_drag()
	local i = {}
	function i:reset()
		self.selected = false
	end
	function i:mouseOff(here)
		if not self.selected then return false end
		if here==self.selected then
			return true
		else
			return self.selected, here
		end
	end
	function i:mouseOn(here,piece)
		if self.selected and here==self.selected then
			return true
		elseif self.selected then
			return self.selected , here
		elseif piece then
			self.selected = loc:new(here.x,here.y)
			return true
		end
	end
	function i:float()
		return true
	end
	return i
end
function click_only()
	local i = {}
	function i:reset()
		self.selected = false
	end
	function i:mouseOff(here)
		return true
	end
	function i:mouseOn(here,piece)
		if self.selected and here==self.selected then
			return true
		elseif self.selected then
			return self.selected, here
		elseif piece then
			self.selected = loc:new(here.x,here.y)
			return true
		end
	end
	function i:float()
		return false
	end
	return i
end
function drag_only()
	local i = {}
	function i:reset()
		self.selected = false
	end
	function i:mouseOff(here)
		if not self.selected then return false end
		if here==self.selected then
			return true
		else
			return self.selected, here
		end
	end
	function i:mouseOn(here,piece)
		if piece then
			self.selected = loc:new(here.x,here.y)
			return true
		end
	end
	function i:float()
		return true
	end
	return i
end

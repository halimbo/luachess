function Layout(x,y,f)
	local b = {}
	local horizontal = x>y and true or false
	if not f and horizontal then
		b.size = y
		b.ox,b.oy = math.floor(x/2-y/2+0.5),0
	elseif not f and not horizontal then
		b.size = x
		b.ox,b.oy = 0,math.floor(y/2-x/2+0.5)
	elseif f and horizontal then
		b.size = y
		b.ox,b.oy = math.floor(x/2-y/2+0.5),0
	elseif f and not horizontal then
		b.size = x
		b.ox,b.oy = 0,math.floor(y/2-x/2+0.5)
	end
	return b
end

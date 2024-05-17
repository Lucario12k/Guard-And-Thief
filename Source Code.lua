--guard and thief
--by archer

debug = false
rando_count = 30

function _init()
 objects = {}
 spots = {}

 for i=0,31 do
  for j=0,31 do
   if fget(mget(i,j),1) then
    local art = new_painting(
     i*8, j*8, mget(i, j)
    )
    add(objects, art)
    
    mset(i,j,1)
    mset(i+1,j,1)
    
    local spot = new_spot(
     i*8, j*8+8, 16, 8
    )
    add(spots, spot)
   end
   
   if fget(mget(i,j),2) then
    local art = new_statue(
     i*8, j*8, mget(i, j)
    )
    add(objects, art)
    
    mset(i,j,0)
    mset(i,j+1,24)
    
    for k=-1,1 do
     for l=0,2 do
      if k!=0 or l!=1 then
       local spot = new_spot(
			     (i+k)*8, (j+l)*8,
			     8, 8, 1/8
			    )
			    add(spots, spot)
      end
     end
    end
   end
   
   if mget(i,j)==9 then
    local spot = new_spot(
     i*8, j*8-8, 16, 8
    )
    add(spots, spot)
   end
   
   if mget(i,j)==11 then
    mset(i,j,0)
    mset(i+1,j,0)
    mset(i,j+1,0)
    mset(i+1,j+1,0)
    
    local spot = new_spot(
     i*8, j*8, 16, 16
    )
    add(spots, spot)
   end
   
   if mget(i,j)==29 then
    mset(i+1,j,30)
    
    local spot = new_spot(
     i*8, j*8+8, 16, 8
    )
    add(spots, spot)
   end
   
   if mget(i,j)==13 then
    mset(i,j-1,15)
    mset(i,j,31)
    
    local spot = new_spot(
     i*8-8, j*8-8, 8, 16
    )
    add(spots, spot)
   end
   
   if mget(i,j)==14 then
    mset(i,j-1,15)
    mset(i,j,31)
    
    local spot = new_spot(
     i*8+8, j*8-8, 8, 16
    )
    add(spots, spot)
   end
  end
 end
 
 for i=1,#spots do
  spots[i]:connect(spots, i)
 end
 
 for i=0,31 do
  for j=0,31 do
   if mget(i,j) == 1 and
      not fget(mget(i,j+1),7) then
    local n = 2
    if (not fget(mget(i-1,j),0) or fget(mget(i-1,j),3)) n += 1
    if (not fget(mget(i+1,j),0) or fget(mget(i-1,j),3)) n += 2
    mset(i,j,n)
   end
  end
 end
 
 local turn = flr(rnd(2))
 
 local thief = new_thief(turn)
 add(objects, thief)
 
 local guard = new_guard(1-turn)
 add(objects, guard)
 
 for n=1,rando_count do
  local rando = new_rando()
  add(objects, rando)
 end
end

thief = nil

function _update60()
 for o in all(objects) do
  if (o.update) o:update()
 end
 
 objects = sort(objects, "depth")
end

function _draw()
 cls(7)
 
 for i=0,128,8 do
  for j=0,128,8 do
   spr(0,i,j)
  end
 end
 
 map(0, 0, 0, 0, 32, 32)
 
 for o in all(objects) do
  if (o.draw) o:draw()
 end
 
 --[[
 for s in all(spots) do
  s:draw()
 end--]]
 
 --[[
 for s in all(spots) do
  s:draw_lines()
 end--]]
 
 for o in all(objects) do
  if (o.ui) o:ui()
 end
 
 --print(debug, 8, 8, 0)
 
 --[[
 for rando in all(objects) do
	 local path = rando.path
	 if path then
	  for i=2,#path do
	   draw_lane(path[i-1].x, path[i-1].y, path[i].x, path[i].y)
	  end
			local i = rando.closest
  		rectfill(
  			path[i].x,
  			path[i].y,
  			path[i].x + rando.w - 1,
  			path[i].y + rando.h - 1,
  			10
  		)
	 end
 end
 --]]
end

function draw_lane(x0, y0, x1, y1)
 color(11)
 line(x0, y0, x1, y1)
 line(x0+actw-1, y0, x1+actw-1, y1)
 line(x0, y0+acth-1, x1, y1+acth-1)
 line(x0+actw-1, y0+acth-1, x1+actw-1, y1+acth-1)
end
-->8
--actor base

actw = 7
acth = 3

function new_actor(x, y, n)
 local actor = {}
 
 actor.x = x
 actor.y = y
 actor.n = n
 if type(n)!="function" then
  actor.n = spr_func(n, true)
 end
 
 actor.speed = 0.5
 
 function actor:input()
  return {press={},hold={}}
 end
 
 actor.w = actw
 actor.h = acth
 actor.depth = 0
 actor.facing = false
 actor.moving = false
 
 function actor:update()
  local controls = self:input()
  
  local xspeed = 0
  if (controls.hold[0]) xspeed -= self.speed
  if (controls.hold[1]) xspeed += self.speed
  
  local yspeed = 0
  if (controls.hold[2]) yspeed -= self.speed
  if (controls.hold[3]) yspeed += self.speed
  
  self.moving = false
  
  self.x += xspeed
  self.y += yspeed
  
  if (xspeed != 0 or yspeed != 0) self.moving = true
  
  if (xspeed > 0) self.facing = false
  if (xspeed < 0) self.facing = true
  
  if self:walled() then
   self:unwall(xspeed, yspeed)
  end
  
  self.depth = -self.y
 end
 
 function actor:walled(x, y)
  if (not x) x = self.x
  if (not y) y = self.y
  
  local l = x\8
  local r = (x+self.w-1)\8
  local t = y\8
  local b = (y+self.h-1)\8
  
  for i=l,r do
   for j=t,b do
    if (fget(mget(i,j),0)) return true
   end
  end
  
  return false
 end
 
 function actor:unwall(xspeed, yspeed)
  testx = self.x
  testy = self.y
  while true do
   if (xspeed != 0) testx -= sgn(xspeed)/2
   if not self:walled(testx, self.y) then
    self.x = testx
    break
   end
   
   if (yspeed != 0) testy -= sgn(yspeed)/2
   if not self:walled(self.x, testy) then
    self.y = testy
    break
   end
   
   if not self:walled(testx, testy) then
    self.x = testx
    self.y = testy
    break
   end
  end
 end
 
 function actor:draw()
  self.n(self.x, self.y-8+self.h, self.moving, self.facing)
 end
 
 return actor
end
-->8
--randos

start_timer = {0, 10}
stay_timer = {2, 10}
wander_timer = {8, 10}

function new_rando(x, y, n)
 local rando = new_actor(
  x, y, n or rnd_person()
 )
 
 if not x or not y then
	 place_random(rando)
	else
	 assert(not rando:walled(),
	  "cannot generate rando in a wall!"
	 )
	end
	
	rando.tx = rando.x
	rando.ty = rando.y
	rando.path = nil
	rando.closest = 1
	rando.debug = {}
	
	function rando:stay()
	 self.path = nil
	 self.timer = rnd_time(stay_timer)
	 self.iswander = false
	end
	
	function rando:wander()
	 self:where_next()
	 self.timer = rnd_time(wander_timer)
	 self.iswander = true
	end
	
	rando:stay()
	rando.timer = rnd_time(start_timer)
	
	function rando:input()
	 local control = {press={},hold={}}
	 
	 if self.timer > 0 then
	  self.timer -= 1
	 --elseif self.iswander then
	  --self:stay()
	 else
	  self:wander()
	 end
	 
	 self:next_point()
	 
	 if (self.tx < self.x) control.hold[0] = true
	 if (self.tx > self.x) control.hold[1] = true
	 if (self.ty < self.y) control.hold[2] = true
	 if (self.ty > self.y) control.hold[3] = true
  
	 if self.path then
		 local ep = self.path[#self.path]
		 if self.iswander and self.x==ep.x and self.y==ep.y then
		  self:stay()
		 end
	 end
	 
	 self.debug = control
	 return control
	end
	
	function rando:next_point()
	 if self.path == nil then
	  self.tx = self.x
	  self.ty = self.y
	  return
	 end
	 
	 for i=#self.path,self.closest+1,-1 do
	  local p = self.path[i]
	  if empty_lane(self.x, self.y, p.x, p.y) then
	   self.tx = p.x
	   self.ty = p.y
	   self.closest = i
	   return
	  end
	 end
	end
	
	function rando:where_next()
	 if rnd(2) < 1 then
	  local ox = self.x
	  local oy = self.y
	  place_random(self)
	  self.tx = self.x
	  self.ty = self.y
	  self.x = ox
	  self.y = oy
	 else
	  
	  local spot = rnd_spot()
	  self.tx, self.ty = spot:rnd()
	 end
	 
	 self.path = point_to_point(
	  self.x, self.y, self.tx, self.ty
	 )
	 self.closest = 1
	end
 
 return rando
end
-->8
--guard

function new_guard(p, x, y)
 local guard = new_actor(
  x, y, 19
 )
 
 if not x or not y then
	 place_random(guard)
	else
	 assert(not guard:walled(),
	  "cannot generate guard in a wall!"
	 )
	end
 
 function guard:input()
  return player_input(p)
 end
 
 function guard:ui()
  local n = 44
  if (p == 1) n = 45
  
  spr(n,
   self.x+(actw-4)\2,
   self.y+acth-12
  )
 end
 
 return guard
end

-->8
--thief

function new_thief(p, x, y, n)
 local thief = new_actor(
  x, y, n or rnd_person(true)
 )
 
 if not x or not y then
	 place_random(thief)
	else
	 assert(not thief:walled(),
	  "cannot generate thief in a wall!"
	 )
	end
 
 thief.holding = nil
 thief.timer = -1
 thief.max_timer = 60 * 1
 thief.score = 0
 
 function thief:input()
  local controls = player_input(p)
  
  if controls.hold[4] then
   if self.holding then
    self:deposit(controls.press[4])
   else
    self:steal(controls.press[4])
   end
  end
  
  return controls
 end
 
 function thief:steal(pressing)
  local target = self:can_steal()
  if (not target) then
   self.timer = -1
   return
  end
  
  if self.timer < 0 then
   if pressing then
    self.timer = self.max_timer
   end
  elseif self.timer > 0 then
   self.timer -= 1
  else
   self.timer = -1
   self.holding = target
   target.stolen = true
  end
 end
 
 function thief:can_steal()
  for o in all(objects) do
   if (o.stealable and o:stealable(self.x,self.y)) return o
  end
 end
 
 function thief:deposit(pressing)
  if not self:can_deposit() then
   self.timer = -1
   return
  end
  
  if self.timer < 0 then
   if pressing then
    self.timer = self.max_timer
   end
  elseif self.timer > 0 then
   self.timer -= 1
  else
   self.timer = -1
   self.score += self.holding.value
   self.holding = nil
  end
 end
 
 function thief:can_deposit()
  local mx = (self.x+self.w/2)\8
  local my = (self.y+self.h/2)\8
  if fget(mget(mx-1,my),4) or
     fget(mget(mx+1,my),4) or
     fget(mget(mx,my-1),4) or
     fget(mget(mx,my+1),4) then
   return true
  end
  return false
 end
 
 function thief:ui()
	 local n = 44
  if (p == 1) n = 45
  
  spr(n,
   self.x+(actw-4)\2,
   self.y+acth-12
  )
  print("$"..self.score, 3, 121, 9)
 end
	
	return thief
end
-->8
--art

local pids = {32, 34, 36, 38, 48, 50, 52, 54}
local sids = {40, 41, 42, 43}

function new_art(x, y, value, bx, by, bw, bh)
 local art = {}
 art.x = x
 art.y = y
 art.value = value
 art.bx = bx or 0
 art.by = by or 0
 art.bw = bw or 8
 art.bh = bh or 8
 
 art.stolen = false
 art.seen_stolen = false
 art.depth = -art.y
 
 function art:stealable(tx, ty)
  return not self.stolen and
         tx>=self.x+self.bx and
         tx<self.x+self.bx+self.bw and
         ty>=self.y+self.by and
         ty<self.y+self.by+self.bh
 end
 
 function art:draw()
  if self.seen_stolen then
   self:draw_stolen()
  else
   self:draw_normal()
  end
 end
 
 return art
end

function new_painting(x, y, n)
 local art = new_art(
  x, y, 1000,
  0, 8, 16-actw, 8-acth
 )
 
 art.n = n or 6
 
 if fget(art.n, 0) then
  if #pids > 0 then
   art.n = rnd(pids)
   del(pids, art.n)
  else
   art.n = 32+16*flr(rnd(2))+2*flr(rnd(4))
  end
 end
 
 function art:draw_normal()
  spr(self.n, self.x, self.y)
  spr(self.n+1, self.x+8, self.y)
 end
 
 function art:draw_stolen()
  local n = 6
  spr(n, self.x, self.y)
  spr(n+1, self.x+8, self.y)
 end
 
 return art
end

function new_statue(x, y, n)
 local art = new_art(
  x, y, 1000,
  -8, 0, 24-actw, 24-acth
 )
 
 art.n = n or 8
 art.depth = -art.y-11
 
 if fget(art.n, 0) then
  if #sids > 0 then
   art.n = rnd(sids)
   del(sids, art.n)
  else
   art.n = 40+flr(rnd(4))
  end
 end
 
 function art:draw_normal()
  spr(self.n, self.x, self.y)
  spr(self.n+16, self.x, self.y+8)
 end
 
 function art:draw_stolen()
  --Do nothing
 end
 
 return art
end
-->8
--spots

function new_spot(x, y, w, h, weight)
 local spot = {}
 
 spot.w = w or 6
 spot.h = h or 4
 spot.weight = weight or 1
 spot.x = x
 spot.y = y
 spot.px = x+spot.w\2-(actw+1)\2
 spot.py = y+spot.h\2-(acth+1)\2
 spot.cs = {}
 
 function spot:rnd()
  return 
   flr(self.x+rnd(self.w-actw+1)),
   flr(self.y+rnd(self.h-acth+1))
 end
 
 function spot:connect(spots, skip)
	 for i=skip+1,#spots do
	  local o = spots[i]
	  if empty_lane(self.px, self.py, o.px, o.py, 0) then
	   local d = point_dist(
	    self.px, self.py,
	    o.px, o.py
	   )
	   
	   add(self.cs, {other=o, dist=d})
	   add(o.cs, {other=self, dist=d})
	  end
	 end
 end
 
 function spot:draw()
  rectfill(
   self.x,
   self.y,
   self.x+self.w,
   self.y+self.h,
   10
  )
  
  rectfill(
   self.x+self.w\2-1, self.y+self.h\2-1,
   self.x+self.w\2+1, self.y+self.h\2+1,
   11
  )
 end
 
 function spot:draw_lines(col)
  for c in all(self.cs) do
   line(
    self.x+self.w\2, self.y+self.h\2,
    c.other.x+c.other.w\2, c.other.y+c.other.h\2,
    col or 0
   )
  end
 end
 
 return spot
end

function rnd_spot()
 local total = 0
 for spot in all(spots) do
  total += spot.weight
 end
 local val = rnd(total)
 for spot in all(spots) do
  val -= spot.weight
  if (val < 0) return spot
 end
 assert(false, "rnd_spot failed ):")
end

function point_to_point(x0, y0, x1, y1)
 local first = closest(x0, y0)
 local last = closest(x1, y1)
 local path = pathing(first, last)
 
 local points = {{x=x0, y=y0}}
 for spot in all(path) do
  add(points, {x=spot.px, y=spot.py})
 end
 add(points, {x=x1, y=y1})
 
 return points
end

function pathing(first, last)
 reset_pathing()
 local unpathed = {}
 for spot in all(spots) do
  add(unpathed, spot)
 end
 first.dist = 0
 first.path = {first}
 return pathing_helper(unpathed, first, last)
end

function pathing_helper(unpathed, cur, last)
 if (cur == last) return cur.path
 
 for c in all(cur.cs) do
  if not c.other.pathed then
	  local newdist = cur.dist + c.dist
	  if not c.other.dist or newdist < c.other.dist then
	   c.other.dist = newdist
	   c.other.path = {}
	   for spot in all(cur.path) do
	    add(c.other.path, spot)
	   end
	   add(c.other.path, c.other)
	  end
	 end
 end
 
 local mindist = nil
 local next = nil
 for spot in all(unpathed) do
  if spot.dist and (not mindist or spot.dist < mindist) then
   mindist = spot.dist
   next = spot
  end
 end
 
 cur.pathed = true
 del(unpathed, cur)
 
 return pathing_helper(unpathed, next, last)
end

function reset_pathing()
 for spot in all(spots) do
  spot.pathed = false
  spot.path = nil
  spot.dist = nil
 end
end

function closest(x, y)
 local mindist = 0
 local close = nil
 
 for spot in all(spots) do
  local dist = point_dist(x, y, spot.x, spot.y)
  if not close or dist < mindist then
   mindist = dist
   close = spot
  end
 end
 
 return close
end
-->8
--utility

unique_tbl = {}

function rnd_person(unique)
 local pern = 22
 perx = 8 * (pern % 16)
 pery = 8 * (pern \ 16)
 
 local ind = flr(rnd(13))
 local base = 17+flr(rnd(2))
 
 local hair
 local skin
 if ind < 8 then
  hair = sget(perx+ind, pery)
  skin = sget(perx+ind, pery+1)
 else
  ind -= 8
  hair = sget(perx+ind, pery+2)
  skin = sget(perx+ind, pery+3)
 end
 
 if (hair == 1) base = 16
 
 local shoe = sget(perx+flr(rnd(2)), pery+4)
 local shirt = sget(perx+flr(rnd(3)), pery+5)
 local pants = sget(perx+flr(rnd(2)), pery+6)
 
 local thief = false
 if rnd(100) < 1 then
  base = 20
  hair = 0
  shirt = 0
  pants = 0
  thief = true
 end
 
 local ghost
 if rnd(100) < 1 and not thief then
  base = 21
  hair = 0
  skin = 0
  shoe = 0
  shirt = 0
  pants = rnd{8, 9, 12, 14}
  ghost = true
 end
 
 local inner = spr_func(base, not ghost)
 
 local pid = base.." "
 pid ..= hair.." "
 pid ..= skin.." "
 pid ..= shoe.." "
 pid ..= shirt.." "
 pid ..= pants
 
 for oid in all(unique_tbl) do
  if (pid == oid) return rnd_person(unique)
 end
 
 if (unique) add(unique_tbl, pid)
 
 return function(x, y, moving, facing)
  pal(4, hair)
  pal(15, skin)
  pal(5, shoe)
  pal(12, shirt)
  pal(7, pants)
  if thief then
   palt(2, true)
   palt(0, false)
  end
  inner(x, y, moving, facing)
  pal()
  palt()
 end
end

function spr_func(base, dofeet)
 return function(x, y, moving, facing)
  spr(base, x, y, 0.875, 1, facing)
  palt()
  
  if dofeet then
   local feet = 0
   if moving then
    if time()%.25<.125 then
     feet = 1
    else
     feet = 2
    end
   end
   sspr(56, 8+feet*2, 5, 2, x+1, y+6)
  else
   local feet = 0
   if moving then
    if time()%.25<.125 then
     feet = 0
    else
     feet = 1
    end
   end
   sspr(56, 14+feet, 5, 1, x+1, y+7)
  end
 end
end

function place_random(actor)
 repeat
  actor.x = flr(rnd(128))
  actor.y = flr(rnd(128))
 until not actor:walled()
end

function rnd_time(b, e)
 if type(b)=="table" then
  e = b[2]
  b = b[1]
 end
 
 return b*60+flr(rnd((e-b)*60))
end

function player_input(p)
 local control = {hold={}, press={}}
 
 for b=0,5 do
  control.hold[b] = btn(b, p)
  control.press[b] = btnp(b, p)
 end
 
 return control
end

function point_dist(x0, y0, x1, y1)
 return sqrt((x0-x1)^2 + (y0-y1)^2)
end

function empty_line(x0, y0, x1, y1, f)
 local d = 8*ceil(point_dist(x0, y0, x1, y1)/8)
 for i=0,d,8 do
  local px = lerp(x0, x1, i/d)
  local py = lerp(y0, y1, i/d)
  if (fget(mget(px\8, py\8),f)) return false
 end
 return true
end

function empty_lane(x0, y0, x1, y1, f)
 return empty_line(x0, y0, x1, y1, f) and
        empty_line(x0+actw-1, y0, x1+actw-1, y1, f) and
        empty_line(x0, y0+acth-1, x1, y1+acth-1, f) and
        empty_line(x0+actw-1, y0+acth-1, x1+actw-1, y1+acth-1, f)
end

function lerp(a, b, t)
 return a + (b - a) * t
end

function sort(t, p)
 local s = {}
 for e in all(t) do
  if #s == 0 then
   add(s, e)
   
  else
   for i=1,#s+1 do
    if not s[i] or s[i][p] < e[p] then
     add(s, e, i)
     break
    end
   end
  end
 end
 
 return s
end

function rectrect(x0,y0,w0,h0,x1,y1,w1,h1)
 return x0<x1+w1 and x1<x0+w0 and y0<y1+h1 and y1<y0+h0
end
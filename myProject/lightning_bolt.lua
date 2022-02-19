function draw_bolt(points,img, color)
  
  for i=1,#points do
    if points[i+1] ~= nil then
      local x1,y1,x2,y2=points[i][1],points[i][2],points[i+1][1],points[i+1][2]
      local ang = math.atan2(y2-y1,x2-x1)
      local x_scale = (math.sqrt(((y2-y1)^2)+((x2-x1)^2)))/(img:getWidth()-125)
      love.graphics.setColor(color[1],color[2],color[3],color[4])
      love.graphics.setBlendMode('add')
      love.graphics.draw(img,x1,y1,ang,x_scale,0.25,65,65)
      --love.graphics.line({x1,y1,x2,y2})
      love.graphics.setBlendMode('alpha')
    end
  end

end

function bolt(start,End)
  local points={}
  local x1,y1,x2,y2=start[1],start[2],End[1],End[2]
  table.insert(points,{x1,y1})
  
  local dist=math.sqrt(((y2-y1)^2)+((x2-x1)^2))
  local angle  =  math.atan2(y2-y1,x2-x1)
  
  for i=1,(dist/50) do
    local ran_dist = math.random(30,40)
    local  x,y = x1+(i*math.cos(angle)*ran_dist), y1+ (i*math.sin(angle)*ran_dist)
    x=x+math.cos(angle+math.rad(math.random(-40,40)))*math.random(30,40)
    y=y+math.sin(angle+math.rad(math.random(-40,40)))*math.random(30,40)
    table.insert(points,{x,y})
  end
  
  table.insert(points,{x2,y2})
  
  return points
  
end

--[[
  -> increase duration time of bolt per frame
  
]]
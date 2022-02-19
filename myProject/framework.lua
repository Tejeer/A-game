local framework={}

framework.rect =  function (x,y,w,h,color)
  local t={}
  
    t.x=x
    t.y=y
    t.w=w
    t.h=h
    if color ~= nil then 
     t.r,t.g,t.b,t.a=color[1],color[2],color[3],color[4] end
    
    t.colliderect= function (rect)
      if (t.x+t.w>rect.x and t.x<rect.x+rect.w and t.y<rect.y+rect.h and t.y+t.h>rect.y) then
        return true
      else
        return false
      end
    end
    
    t.collidepoint= function (px,py)
      if (t.x<=px and t.x+t.w>=px and t.y<=py and t.y+t.h>=py) then return true
      else return false end
    end
    
  t.getSideCords= function(side)
    
    if side=='top' then return t.y 
    elseif side=='bottom' then return t.y+t.h
    elseif side=='left' then return t.x
    elseif side=='right' then return t.x+t.w
    else return "no such side" end
    
  end
  
  t.setSideCords = function (side, value)
    
    if side=='top' then t.y = value
    elseif side=='bottom' then t.y = value - t.h
    elseif side=='left' then t.x = value
    elseif side=='right' then t.x = value - t.w
    else return "no such side" end
    
  end
    
  return t
  
end


framework.getHitLst = function(mainRect, checkRect)
      
      local hitLst={}
      
      
      for i,v in pairs(checkRect) do 
        if mainRect.colliderect(v) then 
          table.insert(hitLst,v)
        end
      end
      
      return hitLst
      
end
  
framework.onScreen = function (pos, cam, screenDimensions) --parameters must be in tables
    if math.floor((pos[1]+cam[1])/screenDimensions[1]) == 0 and math.floor((pos[2]+cam[2])/screenDimensions[2]) == 0 then
      
      return true
      
    else
      
      return false
    
    end
end

framework.load_tileMap = function (img_path, w, h, names_of_tiles)
  
  local tiles={}
  tiles.img = love.graphics.newImage(img_path)
  tiles.img:setFilter('nearest','nearest')
  
  local img_w, img_h = tiles.img:getDimensions()
  local index = 1
  local x,y=0,0
  
  for i,v in ipairs(names_of_tiles) do
    
    local quad = love.graphics.newQuad(x,y,w,h,tiles.img:getDimensions())
      
    tiles[tostring(v)] = quad
    
    x=x+w
    if x>= img_w then x=0 y=y+h end
    if y>= img_h then break end
    
  end
  return tiles
  
end


framework.normalize = function (val,rate)
  if val>rate then val=val-rate elseif val < -rate then val=val+rate else val=0 end
  return val
end

framework.cap = function (val,val2)
    if val > val2 then
        val = val2 end
    if val < -val2 then 
        val = -val2 end
    return val
  
end

framework.getDis = function(p1 , p2)
  return math.sqrt( ((p2[2] - p1[2])^2) + ((p2[1] - p1[1])^2) )
end

framework.raycast = function (start, target, map, width)
  local angle = math.atan2(target[2] - start[2], target[1] - start[1])
  local tileX, tileY = math.floor(start[1] / width) * width, math.floor(start[2] / width) * width
  local nx , ny, x_multiplier;
  
  --verticals        ----#
  local cos_val = math.cos( angle )
  local sin_val = math.sin( angle )
  if cos_val < 0 then 
    x_multiplier = - 1 
    nx = tileX
  else 
    x_multiplier = 1
    nx = tileX + width
  end
  
  for i = 0 , framework.getDis({start[1] ,start[2] }, {target[1] , target[2]}), width do
    ---hypot
    local hypot = ( nx - start[1]) / cos_val
    ny = start[2] + ( hypot * sin_val)
    
    if map[ math.floor(ny / width) ] ~= nil then
      if map[ math.floor(ny / width) ][ math.floor( (nx + x_multiplier ) / width)] ~= 0 then
        break
      end
    end
    nx = nx + (x_multiplier * width)
    
  end
  
  ---horizontals ---
  local x,y , y_multiplier;
  if sin_val >= 0 then y, y_multiplier  = tileY + width, 1 else y, y_multiplier = tileY, -1 end
  for i = 0 , framework.getDis({start[1] ,start[2] }, {target[1] , target[2]}) , width do
    --if sin_val == 0 then sin_val = 0.000001 end
    local hypot = ( y - start[2]) / sin_val
    x = start[1] + (hypot * cos_val)
    
    if map[ math.floor((y + y_multiplier) / width) ] ~= nil then
      if map[ math.floor((y + y_multiplier)/ width) ][ math.floor( (x ) / width)] ~= 0 then
        break
      end
    end
     
    y = y + (width * y_multiplier)
     
  end
  
  if framework.getDis( {px, py}, {nx, ny} ) < framework.getDis( {px, py}, {x,y}) then return nx, ny else return x,y end
  
end

framework.arc_vfx = function(x, y)
  local points = {}
  for r = 89,90 do
    for a = 1, 80 do
      table.insert(points, x + math.cos(math.rad(30 + a) ) * r )
      table.insert(points, y + math.sin(math.rad(30 + a) ) * r )
    end
  end
  love.graphics.polygon('fill',points)
end

return framework

--[[to do:
  arc_vfx, cloth, improve animations, visuals ]]
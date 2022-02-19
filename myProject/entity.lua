game=require(folder..'.'.."framework")
require(folder..'.'..'Animation')
require(folder..'.'..'shaders')

function normalize(val, rate)
    if val > rate then
        val = val - rate 
    elseif val < -rate then
        val = val + rate 
    else
        val = 0 end
    return val
end

local function Entity(x,y,w,h,speed,health)
  local entity={}
  entity.x = x
  entity.y = y
  entity.w = w
  entity.h = h
  entity.speed = speed
  entity.velocity = {0,0}
  entity.animations = {}
  entity.action = 'idle'
  entity.flip={1,1}
  entity.scale = {1,1}
  entity.random_angle = math.rad(math.random(-30,30))
  entity.timer = 1 --animation purpose
  entity.dead_timer = 0.1
  entity.dead = false
  entity.health = health
  entity.damage = false
  entity.custom_color = {1,1,1}
  entity.shoot_timer = 5
  
  entity.rect = game.rect(entity.x, entity.y, entity.w, entity.h)
  
  entity.move=function (movement,tiles,map)
    
    entity.rect.x,entity.rect.y=entity.x,entity.y
    if tiles ~= nil then
        entity.rect.x = entity.rect.x+movement[1]
        
        local collision = {}
        collision['up'], collision['down'], collision['left'], collision['right'] = false,false,false,false
        
        local hitList= game.getHitLst(entity.rect, tiles)
        
        for i,v in pairs(hitList) do
          if movement[1]>0 then entity.rect.setSideCords('right', v.getSideCords('left')) collision['right'] = true
          elseif movement[1]<0 then entity.rect.setSideCords('left', v.getSideCords('right')) collision['left'] = true end
        end
        
        entity.x = entity.rect.x 
        
        entity.rect.y=entity.rect.y+movement[2]
        
        hitList= game.getHitLst(entity.rect, tiles)
        
        for i,v in pairs(hitList) do
          if movement[2]>0 then entity.rect.setSideCords('bottom', v.getSideCords('top')) collision['down'] = true
          elseif movement[2]<0 then entity.rect.setSideCords('top', v.getSideCords('bottom')) collision['up']=true end
        end
        
        entity.y = entity.rect.y
        
        return collision
    
    end
  end
  
  entity.getDistance = function (target_pos)
    return math.sqrt(((target_pos[2]-entity.y)^2)+((target_pos[1]-entity.x)^2))
  end
  
  entity.getDistanceFromCentre = function (target_pos)
    return math.sqrt(((target_pos[2] - (entity.y + entity.h/2))^2)+((target_pos[1] - (entity.x + entity.w/2))^2))
  end
  
  entity.center = function ()
      return {entity.x+entity.w/2,entity.y+entity.h/2}
  end
  
  entity.load_animation = function (Path,name,durations,dimension)
    entity.animations[name] = Animation(Path,dimension[1],dimension[2],durations)
  end
  
  entity.render = function (scale, offset)
    
    if entity.timer > #entity.animations[entity.action].frames+1 then entity.timer=1 end
    
    love.graphics.setColor(entity.custom_color[1], entity.custom_color[2], entity.custom_color[3])
    if entity.custom_color[1] ~= 1 and entity.custom_color[2] ~= 1 and entity.custom_color[3] ~= 1  then love.graphics.setBlendMode('add') end
    
    if entity.damage then love.graphics.setShader(shader) end
    
    if entity.flip[1]>0 then 
      love.graphics.draw(entity.animations[entity.action].img, entity.animations[entity.action].frames[math.floor(entity.timer)],entity.x-offset[1], entity.y-offset[2] ,0,scale[1]*entity.flip[1],scale[2]*entity.flip[2])
    else 
      love.graphics.draw(entity.animations[entity.action].img, entity.animations[entity.action].frames[math.floor(entity.timer)],entity.x-offset[1]+entity.w+2,entity.y-offset[2] ,0,scale[1]*entity.flip[1],scale[2]*entity.flip[2])
    end
    
    love.graphics.setShader()
    love.graphics.setBlendMode('alpha')
    
  end
  
  entity.update = function(dt, random_angle_increment)
    --its for animation purpose thats why i m multiplying it with 60
    entity.timer = entity.timer+dt*60
    -----------------------------------#
    
    if random_angle_increment and not entity.dead then 
      entity.random_angle = entity.random_angle + math.rad(1)
      if entity.random_angle > math.rad(360) then entity.random_angle = math.rad(0) end 
    end
  
    entity.velocity = {normalize(entity.velocity[1], (dt*36/2)), normalize(entity.velocity[2] , (dt*36/2))}
    if entity.health <= 0 then entity.dead_timer = entity.dead_timer - dt end
    if entity.dead_timer < 0 then entity.dead = true end
    
    entity.shoot_timer = entity.shoot_timer - dt
    
  end
  
  entity.set_action = function(action)
    entity.action = action
  end
  
  return entity
  
end

return Entity
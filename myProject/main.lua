Entity=require(folder..'.'..'entity')
game=require(folder..'.'..'framework')
require(folder..'.projectiles')
generate_map=require(folder..'.'..'proc_gen')
require(folder..'.light')
require(folder..'.sparks')
require(folder..'.abiotic_generator')
require(folder..'.lightning_bolt')
require(folder..'.explosion')
require(folder..'.'..'cloth')
require(folder..'.shaders')

width, height = 640,480--love.graphics.getDimensions()
set=love.window.setMode(width,height,{fullscreen=false})
game_width, game_height = 320, 240
screen = love.graphics.newCanvas(game_width,game_height)
angle = 0
math.randomseed(os.clock())
game_timer = math.random(-360,360)
love.mouse.setVisible(false)
love.graphics.setDefaultFilter("nearest", "nearest")
shadow_img = love.graphics.newImage(folder..'/assests/shadow.png')
stick =love.graphics.newImage(folder..'/assests/stick.png')
game_speed = 1

projectile =love.graphics.newImage(folder..'/assests/projectile.png')
Projectiles={}
sparks={}
local crosshair = love.graphics.newImage(folder..'/assests/crosshair.png')

stone_img = game.load_tileMap(folder..'/assests/stones.png',2, 3 ,{1,2,3,4})
plant_img = game.load_tileMap(folder..'/assests/plants.png',6, 4 ,{1,2,3,4})

light_shader = love.graphics.newShader(light_shader_code)

--powerup_pos, timer
  powerUps = {['triple_bullets'] = {{}, 0}}

corpses_imgs = {}
corpses_imgs['worm'] = love.graphics.newImage(folder..'/assests/worm_dead.png') 
corpses_imgs['scorpion'] = love.graphics.newImage(folder..'/assests/scorpion/scorpion_dead.png')

function get_surrounding_rects(pos, map, area)
  local x , y = math.floor(pos[1]/16), math.floor(pos[2]/16)
  local tileRects = {}
  if map[y-area]~=nil then  y = y-area if map[y][x-area] then x=x-area end end
  for y_=0,area*2 do
    for x_=0,area*2 do
      if map[y+y_]~=nil then if map[y+y_][x+x_]~=nil then if map[y+y_][x+x_] ~= 0 then table.insert(tileRects, game.rect((x+x_)*16, (y+y_)*16, 16,16)) end end end
    end
  end
  
  return tileRects
  
end

--[[
 night ->153,161,165
 afternoon ->1,1,1
 morning ->225, 165, 165
]]

function draw_map(map, canvas, tiles)
  
  love.graphics.setCanvas(canvas)
  local r,g,b = 255,255,255
  love.graphics.clear((65*(r/255))/255, (65*(g/255))/255, (85*(b/255))/255,1)
  tiles.img:setFilter('nearest', 'nearest')
  local sec_tiles = {}
  for y=1,#map do
      for x=1, #map[y] do
          if map[y][x] == 0 and math.random(1,45) == 5 then
              -------------------less opacity ground tiles-----------#
              for i_y = 0,math.random(1,2) do 
                for i_x = 0,math.random(1,2) do
                  if map[y+i_y] ~= nil then
                    if map[y+i_y][x+i_x] == 0 then  
                      table.insert(sec_tiles, {x+i_x,y+i_y})
                    end
                  end
                end
              end
              
          end
          love.graphics.draw(tiles.img, tiles[tostring(map[y][x])], math.floor(x*16),math.floor(y*16))
      end
  end
  
  love.graphics.setColor((215*r/255)/255,(215*g/255)/255,(215*b/255)/255) 
  for i,v in ipairs(sec_tiles) do
    love.graphics.draw(tiles.img, tiles[tostring(0)], math.floor(v[1]*16),math.floor(v[2]*16))
  end
  love.graphics.setCanvas()
  
  return canvas
  
end

function love.load(...)
  
  local m_w, m_h = 800,800
  map,shadows = generate_map(m_w,m_h,16,16,m_w*0.5, 8)
  world = love.graphics.newCanvas(m_w*1.1, m_h*1.1)
  scale_x,scale_y=width/game_width, height/game_height
  cam={0,0}
  screen_shake_timer = 0
  shoot_timer=0.2
  
  powerUps['triple_bullets'][1] = {}
  
  --type,pos, scale, corpse_effect Animation timer
  corpses = {}
  cloth_pos = get_cloth_pos(map , 10)
  clothes = {}
  local obj_color = { {151/255, 82/255, 103/255}, {77/255, 127/255, 86/255}, {153/255, 155/255, 75/255}}
  for i,v in ipairs(cloth_pos) do
    local obj = ClothObj(rag)
    obj.scale = math.random(15,20) / 10
    obj.move_grounded(v)
    table.insert(clothes, {obj, obj_color[math.random(1,#obj_color)], v})
  end
  
  stones= generate_stones(map)
  butterflies= generate_plants(map)
  
  screen:setFilter("nearest", "nearest")
  player=Entity((#map[1]/2)*16, (#map/2)*16, 12, 14,1.545, 10)
  
  right,left,up,down=false,false,false,false
  
  bits={15,11,14,6,3,9,12,5,7,13,4,1,10,8,2,0,100}
  
  tiles = game.load_tileMap(folder..'/assests/tiles.png', 16, 16 , bits)
  bolt_img = love.graphics.newImage(folder..'/assests/line.png')
  bolt_img:setFilter('nearest', 'nearest')
  
  --controls
  controls = {}
  controls.up = game.rect(740,360,64,64,{1,1,0,0.5})
  controls.down = game.rect(740,430,64,64,{0,0,1,0.5})
  controls.left = game.rect(700,393,64,64,{0,1,0,0.5})
  controls.right = game.rect(780,393,64,64,{1,0,0,0.5})
  controls.magic = game.rect(740, 240, 64, 64, {1,0,1,0.5})
  
  player.load_animation(folder..'/assests/player_idle.png','idle',{10,10,10,10,10},{12,12})--12,12
  player.load_animation(folder..'/assests/player_run.png', 'run',{8,8,10,10},{12,12})
  a=0
  px,py=300,300
  
  enemies = {}
  enemies['worm'] = {}
  enemies['scorpion'] = {}
  
  no_of_scorpion, no_of_worm = 3, 14
  for i,v in ipairs(enemy_pos(map, no_of_scorpion)) do
    table.insert(enemies['scorpion'], Entity(v[1],v[2], 29,29 ,1.5, 65))
  end
  
  
  for i,v in ipairs(enemy_pos(map ,no_of_worm )) do 
    table.insert(enemies['worm'], Entity(v[1], v[2], 12, 8,1, 3)) end
  
  for i,v in pairs(enemies) do
    for ind,val in pairs(enemies[i]) do
      if i == 'worm' then
        val.load_animation(folder..'/assests/worm.png', 'idle', {15,10,10}, {13,9})
        val.blasted = false
      elseif i == 'scorpion' then
        val.load_animation(folder..'/assests/scorpion/scorpion.png', 'idle', {15,10,10}, {29,29})
      end
    end
  end
  
  no_of_enemies = 0
  transistion_timer = 3
  
  world:setFilter('nearest', 'nearest')
  world = draw_map(map, world, tiles)
  love.graphics.setColor(1,1,1)
  
  -------------------blitting stones --------------#
  love.graphics.setCanvas(world)
  love.graphics.setBlendMode('add')
  for i,v in ipairs(stones) do
      love.graphics.draw(stone_img.img,stone_img[tostring(v[1])],v[2],v[3],v[4], 1.2, 1.2)
  end
  love.graphics.setCanvas()
  love.graphics.setBlendMode('alpha')
  
  
  generate_bolt = false
  shooting = 0
  lightning_bolts = {}
  lightning_bolt_timer = 0
  screen_shake_range = {-2,2}
  mx,my = 0,0
  movement={0,0}
  player.scale = {1.25,1.25}
  run_particles = {}
  stick_light_radius = {4, 2}
  color_change_timer = 0
end

function love.draw(...)
  
  love.graphics.setCanvas(screen)
  love.graphics.clear(65/255, 65/255, 85/255,1) --25,40,65)
  love.graphics.push()
  
  px,py = player.center()[1], player.center()[2]
  deltaTime = love.timer.getDelta()
  
  -- moving camera
  cam={math.floor(cam[1]-(math.cos(angle)*(player.getDistance({mx,my})/25))), math.floor(cam[2]-(math.sin(angle)*(player.getDistance({mx,my})/25)))}
  
  if screen_shake_timer > 0 then 
    love.graphics.translate(cam[1]+math.random(screen_shake_range[1],screen_shake_range[2]), cam[2]+math.random(screen_shake_range[1],screen_shake_range[2]))
  else
    love.graphics.translate(cam[1], cam[2])
  end
  
  local d_n_cycle = math.sin(game_timer/60)*10
  local r,g,b;
  if d_n_cycle > -2 and d_n_cycle < 2 then
    r,g,b = 210 -(d_n_cycle*5) + (2 - math.sqrt(d_n_cycle^2))*118.5 ,210-(d_n_cycle*5),210-(d_n_cycle*5) 
  else
    r,g,b = 181 -(d_n_cycle*2.8) ,190-(d_n_cycle*2.8),190-(d_n_cycle*2.8)
  end
    
  love.graphics.setColor(r/255,g/255,b/255)  --153/255,161/255,165/255
  
  love.graphics.draw(world,0,0)
  
    if movement[1]~=0 and not(collision['right'] or collision['left']) or movement[2]~=0 and not(collision['up'] or collision['down']) then 
      player.set_action('run') 
      --------------running-particles-----------------#
      if math.random(1,14) <= 3 then 
        for i=0,1 * game_speed do
            local size =  math.random(2,4)
            if math.random(1,2) == 1 then
              table.insert(run_particles, {'2nd', {px, py+player.h/2}, {math.cos(math.rad(math.random(360))) * 0.9 * deltaTime * 60 * game_speed , math.sin(math.rad(math.random(360))) * 0.3 * deltaTime * 60 * game_speed }, size, {0 , size*2}})
            else
              table.insert(run_particles, {'3rd', {px, py+player.h/2}, {math.cos(math.rad(math.random(360))) * 0.9 * deltaTime * 60 * game_speed, math.sin(math.rad(math.random(360))) * 0.3 * deltaTime * 60 * game_speed}, size, {0 , size*2}})
            end
        end
      end
    else 
      player.set_action('idle') 
    end
      
    if math.cos(angle)<0 then player.flip={-1,1} else player.flip={1,1} end
    
    local surrounding_rects = get_surrounding_rects({player.x,player.y},map ,1)
    player.move(player.velocity, surrounding_rects)
    collision = player.move(movement, surrounding_rects)
    
    love.graphics.setColor(178/255,186/255,190/255,0.7125)
    love.graphics.draw(shadow_img,player.x,player.y+player.w)
    
    love.graphics.setBlendMode('add')
    love.graphics.setColor(1,1,1,1)
    for i,v in ipairs(butterflies) do
        love.graphics.draw(plant_img.img,plant_img[tostring(v[1])],v[2],v[3],math.min(math.cos(game_timer),math.sin(game_timer ) * math.cos(game_timer + v[4])) ,1.6 * math.cos(game_timer * 10), 1.6 * math.sin( game_timer * 10),3,3)
        local speed;
        if d_n_cycle > 2 then
          v[4] = v[4] + math.rad(0.8)
          speed = 0.5
        elseif d_n_cycle < -2 then
          v[4] = v[4] + math.rad(0.8)
          speed = 1
        else
          speed = 1
          v[4] = v[4] + math.rad(2)
        end
        v[2] = v[2] + math.cos(v[4]) * 2 * deltaTime * 60 * game_speed * speed
        v[3] = v[3] + math.sin(v[4]) * 2 * deltaTime * 60 * game_speed * speed
        if v[2] < 0 then v[2] = 0 elseif v[2] > #map[1] * 16 then v[2] = 0 end
        if v[3] < 0 then v[3] = 0 elseif v[3] > #map[1] * 16 then v[3] = 0 end
    end
    
    love.graphics.setBlendMode('alpha')
    
    
    love.graphics.setColor(205/255,205/255,205/255)
    
    no_of_enemies =0
    
    for i,v in ipairs(corpses) do
      love.graphics.setColor(150/255, 150/255,150/255)
      
      love.graphics.draw(corpses_imgs[v[1]], v[2] + (3 - (2 + v[4][1])) * (corpses_imgs[v[1]]:getWidth()/2), v[3], 0, v[4][1], v[4][2])
      if v[1] == 'worm' and v[5] > 240 then
        love.graphics.setColor(0,0,0)
        for c = 1, math.random(1, 2) do
          love.graphics.circle('fill', (v[2] +4 ) + math.cos(math.rad(v[5])*18) * (6- (c*10)) ,( v[3] - 8) + math.sin(math.rad(v[5])*10)*4, 1)
        end
      elseif v[1]  == 'scorpion' and v[5] > 220 then 
        love.graphics.setColor(0,0,0)
        for c = 1, math.random(1, 2) do
          love.graphics.circle('fill', (v[2] + 14 ) + math.cos(math.rad(v[5])*18) * (6- (c*10)) ,( v[3] - 8) + math.sin(math.rad(v[5])*10)*4, 1)
        end
      end
      corpses[i][5] = corpses[i][5] + deltaTime * game_speed *60
    end
    
    love.graphics.setColor(1,1,1,1)
    
    for i,v in pairs(enemies) do
      for ind,val in pairs(enemies[i]) do
      
      if i == 'worm' then
        if not val.dead then
          if val.velocity[1] ~= 0 or val.velocity[2] ~= 0 then
            val.damage = true
            val.scale[1] = 0.8
          else
            val.scale[1] = 1
            val.damage = false
          end
          
          val.render(val.scale, {0,0})
          val.update(deltaTime * game_speed, false)
          
          local target_angle = math.atan2(py - val.center()[2], px - val.center()[1]) +  val.random_angle
          local x_vel, y_vel =  math.cos(target_angle + (val.random_angle * math.sin(game_timer))) * val.speed, math.sin(target_angle + (val.random_angle * math.sin(game_timer))) * val.speed
          local surrounding_rects = get_surrounding_rects({val.x,val.y}, map, 3)
          
          if val.getDistance({px,py}) > 30 then 
            val.move({x_vel*(deltaTime * game_speed*60) , y_vel*(deltaTime * game_speed*60) } ,surrounding_rects)
          end
          
          val.move({ val.velocity[1]*(deltaTime * game_speed*60), val.velocity[2]*(deltaTime * game_speed*60)} , surrounding_rects) 
        
          if val.x < 16 or val.x > ((#map[1] - 1) *16) or val.y < 16 or val.y > ((#map - 1)*16) then val.dead = true end
        else
          table.remove(enemies[i], ind)
          table.insert(corpses, {i, val.x, val.y, {1,1}, math.random(15,45)})
          for i=1,4 do
              local speed = math.random(2,4)
              local size = math.random(2,5)
              table.insert(Explosion_Particles, {'2nd', {val.center()[1],val.center()[2]}, {math.cos(math.rad(math.random(360)))* speed, math.sin(math.rad(math.random(360)))* speed}, size, {0, size*5} })
          end
        end
      
      elseif i == 'scorpion' then
        
        if not val.dead then 
          love.graphics.setColor(225/255, 225/255, 225/255, 0.7)
          -------------------shadow-----------
          local center_pos = val.center()
          love.graphics.draw(shadow_img, center_pos[1]-val.w/3, center_pos[2]+val.h/3, 0, 2,2)
          -------------------flipping-----------#
          love.graphics.setColor(1,1,1,1)
          if math.cos(math.atan2(py - val.center()[2],px - val.center()[1])) > 0 then val.flip[1] = 1 else val.flip[1] = -1 end
          
          if val.velocity[1] ~= 0 or val.velocity[2] ~= 0 then
            val.damage = true
            val.scale[1] = 0.8
          else
            val.scale[1] = 1
            val.damage = false
          end
          
          val.render(val.scale, {0,0})
          val.update(deltaTime * game_speed, true)
          local x, y =  game.raycast({px, py},  center_pos, map , 16)
          if val.getDistanceFromCentre({x,y}) < 60 and val.shoot_timer <= 0 and not val.damage then 
            local num_bullets = math.random(5,8)
            for i = -num_bullets, num_bullets do
              table.insert(Projectiles,new_projectile(center_pos[1], center_pos[2] - 5, math.random(150,250), 1 , math.atan2(py - center_pos[2], px - center_pos[1]) + math.rad(i *8 + math.random(7)), projectile, 'enemy', {2.7,1.2}))
            end
            val.shoot_timer = math.random(5,15)
            val.scale[2] = 0.5
          else
            val.scale[2] = 1
          end
          
          if val.shoot_timer < 1 then 
            render_light({center_pos[1], center_pos[2] - 5},stick_light_radius,{1,0,0,0.99999},5,a*8)
          end
          
          if val.x < 16 or val.x > ((#map[1] - 1) *16) or val.y < 16 or val.y > ((#map - 1)*16) then val.x, val.y = (#map[1]/2)*16, (#map/2)*16 end
          
          local target_angle = math.atan2(val.center()[2]-py, val.center()[1]-px) 
          local surrounding_rects = get_surrounding_rects({val.x,val.y}, map, 3)
          local x_vel,y_vel =0,0
          
          if val.getDistance({px,py}) > 140 and not val.dead then
            x_vel, y_vel =  math.cos(target_angle + val.random_angle +math.rad(ind * 10)) * val.speed, math.sin(target_angle + val.random_angle + math.rad(ind * 10)) * val.speed
          else
            x_vel, y_vel = math.cos(val.random_angle + math.rad(ind * 30)) * val.speed, math.sin(val.random_angle + math.rad(ind * 30)) * val.speed
          end
          
          if val.getDistance({px,py}) > 20 then
            val.move({x_vel*(deltaTime * game_speed*60) , y_vel*(deltaTime * game_speed*60) } ,surrounding_rects)
          end
          
          val.move({ val.velocity[1]*(deltaTime * game_speed*60), val.velocity[2]*(deltaTime * game_speed*60)} , surrounding_rects)
      else
        
        table.remove(enemies[i], ind)
        table.insert(corpses, {i, val.x, val.y, val.flip, math.random(15,45)})
        for i=1,10 do
              local speed = math.random(3,6)
              local size = math.random(2,5)
              table.insert(Explosion_Particles, {'2nd', {val.center()[1],val.center()[2]}, {math.cos(math.rad(math.random(360)))* speed, math.sin(math.rad(math.random(360)))* speed}, size, {0, size*5} })
        end
        if math.random(1,3) == 1 then 
          table.insert(powerUps['triple_bullets'][1], {val.center()[1],val.center()[2]})
        end
      end
      end
      
      if not val.dead then
        no_of_enemies = no_of_enemies + 1 
      end
    end
  end
  
  
  for i,v in ipairs(clothes) do
    v[1].move_grounded(v[3])
    local ang = (math.sin(game_timer) + math.pi/2) * math.random(0,10)
    v[1].update({math.cos(ang) *0.1 , math.sin(ang) * 0.1 })
    v[1].update_sticks()
    v[1].render({0,0}, v[2])
  end
  
    for i,v in ipairs(Projectiles) do
      if v.tag == 'player' then
        v.render({1,1,1})
        v.update(deltaTime * game_speed, true)
        if player.getDistance({v.x,v.y})>350 then table.remove(Projectiles,i) end
        if  v.collided then table.remove(Projectiles,i) 
          for i=0,math.random(2,6)  do
            table.insert(sparks,Spark({v.x,v.y}, math.rad(math.random(math.deg(v.angle+math.pi/2),math.deg(v.angle-math.pi/2)))-math.pi, math.random(200,250), math.random(20,29)/1000,math.random(600,890), {125/255,245/255,235/255}))
          end
          
        end
        
        for e_i, enemy_type in pairs(enemies) do
          for e_x , enemy in pairs(enemies[e_i]) do
            if e_i == 'worm' then
              if enemy.getDistanceFromCentre({v.x, v.y}) < 10 and not enemy.dead then
                v.collided = true
                enemy.velocity = {math.cos( v.angle + math.rad(math.random(-15,15)))*5, math.sin( v.angle + math.rad(math.random(-15,15)))*5}
                enemy.health = enemy.health - 1
                if math.random(0,25) == 3 then game_speed = game_speed * 0.65 end
              end
              
            elseif e_i == 'scorpion' then
              
              if enemy.getDistanceFromCentre({v.x, v.y}) < 18 and not enemy.dead then
                v.collided = true
                enemy.velocity = {math.cos( v.angle + math.rad(math.random(-15,15)))*5, math.sin( v.angle + math.rad(math.random(-15,15)))*5}
                enemy.health = enemy.health - 1
                if math.random(0,25) == 3 then game_speed = game_speed * 0.65 end
              end
            end
          end
        end
        
      elseif v.tag == 'enemy' then
        love.graphics.setColor(1,0,0)
        v.render({0.8,0,0})
        v.update(deltaTime * game_speed , true)
        
        if v.collided then 
          table.remove(Projectiles, i) 
          for i=0,math.random(5,7)  do
            table.insert(sparks,Spark({v.x,v.y}, math.rad(math.random(math.deg(v.angle+math.pi/2),math.deg(v.angle-math.pi/2)))-math.pi, math.random(150,250), math.random(20,29)/1000,math.random(500,690), {1,0,0}))
          end
        end
        if player.getDistanceFromCentre({v.x,v.y}) < 10 then 
          v.collided = true 
          player.velocity = {math.cos(v.angle) * 4.5, math.sin(v.angle) * 4.5 } 
        end
      end
    end
    
    local x,y = px + math.random(-160, 160), py + math.random(-120, 120)
    if map[math.floor(y/16)] ~= nil then 
      if map[math.floor(y/16)][math.floor(x/16)] == 0 and math.random(1,59) == 5 then 
        for i=0,4 * game_speed do
            local size =  math.random(2,4)
            if math.random(1,2) == 1 then
              table.insert(run_particles, {'2nd', {x,y}, {math.cos(math.rad(math.random(-30,15))) * 2 * deltaTime * 60 * game_speed , math.sin(math.rad(math.random(-30, 15))) * 3 * deltaTime * 60 * game_speed }, size, {0 , size*5}})
        
              table.insert(run_particles, {'3rd', {x,y}, {math.cos(math.rad(math.random(-30, 15))) * 2 * deltaTime * 60 * game_speed , math.sin(math.rad(math.random(-30, 15))) * 3 * deltaTime * 60 * game_speed}, size, {0 , size*5}})
            end
        end
      end
    end
    
    update_explosion_particles(deltaTime * game_speed, run_particles)
    
    if player.velocity[1] ~= 0 or player.velocity[2] ~= 0 then 
      player.damage = true
    else
      player.damage = false
    end
    
    love.graphics.setColor(1,1,1)
    if math.sin(angle)>0 then 
      player.render(player.scale,{2,1}) 
      love.graphics.draw(stick,px,py+2,angle,1,1,0,4)
    else
      love.graphics.draw(stick,px,py+2,angle,1,1,0,4)
      player.render({1.25,1.25},{2,1}) 
    end
    -------------------#
    
    --tiles shadows---#
    love.graphics.setColor(0/255,0/255,0/255,0.4125)
    --local img_w,img_h=
    for i,v in pairs(shadows) do
      for j,k in ipairs(v) do 
        if game.onScreen({k[1],k[2]} ,{cam[1]+32,cam[2]+32},{370,300}) then
          local qx,qy,qw,qh = tiles[i]:getViewport()
          local shadowQuad = love.graphics.newQuad(qx,qy+4,qw,qh-4,tiles.img:getDimensions())
          love.graphics.draw(tiles.img,shadowQuad,k[1],k[2]) 
        end
        
      end
      
    end
  -----------------#
    
  love.graphics.setColor(1,1,1)
  
  -----------------lightning-------------#
  if generate_bolt then
    for i,v in pairs(enemies) do
      for e_i , e in pairs(v) do
        local cx,cy = e.center()[1], e.center()[2]
        if player.getDistance({cx,cy}) < 140 and e.health > 0  then
          table.insert(lightning_bolts ,bolt({px,py - game_height--[[math.ceil(px+math.cos(angle)*12),math.ceil(py+math.sin(angle)*12)]]}, {cx,cy})) 
          e.health = e.health - 70
          local enemy_angle = math.atan2(cy-py,cx-px)
          e.velocity = {math.cos(enemy_angle)*8, math.sin(enemy_angle)*8}
          
          for i=0,6 do
            table.insert(sparks,Spark({cx, cy},math.rad(math.random(360)), math.random(200,250), math.random(29,39)/1000 , math.random(200,300), {126/255,225/255,255/255}))
          end
          for i=1,10 do
              local speed = math.random(3,6)
              local size = math.random(3,6)
              table.insert(Explosion_Particles, {'core', {cx,cy}, {math.cos(math.rad(math.random(360)))* speed, math.sin(math.rad(math.random(-360,360)))* speed}, size, {0, size*10} })
          end
          lightning_bolt_timer = 0.12
        end
      end
    end
    generate_bolt = false
  end
  
  if lightning_bolt_timer > 0 then 
    screen_shake_timer = 0.3
    screen_shake_range = {-10,10}
    for i,v in ipairs(lightning_bolts) do
      draw_bolt(v, bolt_img, {106/255, 125/255 , 1})
    end
    lightning_bolt_timer = lightning_bolt_timer - deltaTime * game_speed
  else
    lightning_bolts = {}
  end
  
  -------------------updating-explosions-------------#
  update_explosion_particles(deltaTime * game_speed)
  
  --stick light     #
  render_light({(px+math.cos(angle)*14),(py+math.sin(angle)*14)},stick_light_radius,{125/255,245/255,125/255,0.89999},5,a*8)
  stick_light_radius = {4,2}
  
  for i,v in pairs(powerUps) do
    if i == 'triple_bullets' then
      for ind,pos in ipairs(v[1]) do
        render_light({pos[1], pos[2] + math.sin(game_timer * 4) * 10}, {4,2},{125/255,245/255,125/255,0.89999},5,a*8)
        local ang = math.atan2(py - pos[2], px - pos[1])
        if player.getDistanceFromCentre(pos) < 128 then 
          pos[1] = pos[1] + math.cos(ang) * 6
          pos[2] = pos[2] + math.sin(ang) * 6
        end
        if player.getDistanceFromCentre(pos) < 5 then 
          table.remove(powerUps[i][1], ind)
          powerUps[i][2] = powerUps[i][2] + 60
          color_change_timer = 0.5
        end
      end
    powerUps[i][2] = powerUps[i][2] - deltaTime * game_speed
    if powerUps[i][2] < 0 then powerUps[i][2] = 0 end
    color_change_timer = color_change_timer - deltaTime * game_speed
    if color_change_timer < 0 then color_change_timer = 0 end
    if color_change_timer > 0 then  player.custom_color = {125/255,245/255,125/255} else player.custom_color = {1,1,1} end
    end
  end
  love.graphics.setColor(1,1,1)
  
  for i,v in ipairs(sparks) do
    v.draw()
    v.move(deltaTime * game_speed)
    if not v.alive then table.remove(sparks,i) end
  end
  
  
  love.graphics.pop()
  
  love.graphics.setCanvas()
  
  love.graphics.setColor(1,1,1)
  
  love.graphics.setShader(light_shader)
  
  light_shader:send("screen",{world:getWidth(),world:getHeight()});--2400
  w_ratio = (world:getWidth()) / game_width
  h_ratio = (world:getHeight()) / game_height
  light_shader:send("num_lights",1)
  light_shader:send("lights[0].position",{(px+cam[1]) * w_ratio, (py+cam[2]) * h_ratio}) -- 2.6 = world width/game_width
  light_shader:send("lights[0].diffuse",{225/255,225/255,225/255})
  light_shader:send("lights[0].power",14 + d_n_cycle)
  
  love.graphics.draw(screen,0,0,0, scale_x, scale_y)
  love.graphics.setShader()
  
  --crosshair
  love.graphics.setColor(1,1,1)
  love.graphics.draw(crosshair,love.mouse.getX()-13, love.mouse.getY()-13, 0, 2, 2)
  
  love.graphics.setColor(1,0,0)
  
  for i,v in pairs(controls)  do
    love.graphics.setColor(v.r,v.g,v.b,v.a)
    love.graphics.rectangle('fill',v.x,v.y,v.w,v.h)
  end
  
  love.graphics.setColor(1,0,0,1)
  
  love.graphics.print(tostring(love.timer.getFPS()),30,30)
  love.graphics.print({mx,'   ',my},30,50)
  love.graphics.print(tostring(no_of_enemies),30,70)
  love.graphics.print(tostring(d_n_cycle),30,85)
  love.graphics.print(tostring(powerUps['triple_bullets'][2]),30,100)
  
end

function love.update(dt)
  
  if dt > 10/60 then
    return
  end
  
  game_speed = game_speed + (1 - game_speed)/20
  
  if math.abs(1 - game_speed) < 0.05 then game_speed = 1 end
  
  player.update(dt * game_speed, false)
  
  mx, my = love.mouse.getX(), love.mouse.getY()
  mx, my = math.floor((mx/scale_x)-cam[1]), math.floor((my/scale_y)-cam[2])
  
  local true_cam = {math.floor(cam[1]+ ((game_width/2-cam[1]-player.center()[1])/5)), math.floor(cam[2]+((game_height/2-cam[2]-player.center()[2])/5))}
  
  -- camera values are in negative so they work opposite
  if screen_shake_timer>0   then screen_shake_timer=screen_shake_timer - dt * game_speed end
  if shoot_timer>0 then shoot_timer=shoot_timer - dt * game_speed end
  game_timer=game_timer+dt * game_speed
  a=a+0.01*dt * game_speed*60
  
  if true_cam[1] >-24 then
      cam[1]=-24
  elseif true_cam[1] < -(#map[1]*16-326) then 
      cam[1]= -(#map[1]*16-326)
  else
      cam[1] = true_cam[1]
  end
  
  if true_cam[2] >-24 then
    cam[2]=-24
  elseif true_cam[2] <-(#map*16 -242 ) then 
    cam[2]=-(#map*16 -242 )
  else
    cam[2]=true_cam[2]
  end
  
  angle = math.atan2(my-player.y, mx-player.x)
  
  movement={0,0}
  
  tmx,tmy = love.mouse.getX(), love.mouse.getY()
  
  
    if love.keyboard.isDown('w') or controls.up.collidepoint(tmx,tmy) then up=true else up =false end
    if love.keyboard.isDown('s') or controls.down.collidepoint(tmx,tmy) then down=true else down=false end
    if love.keyboard.isDown('a') or controls.left.collidepoint(tmx,tmy) then left=true else left=false end
    if love.keyboard.isDown('d') or controls.right.collidepoint(tmx,tmy) then right=true else right=false 
    if controls.magic.collidepoint(tmx,tmy) then  generate_bolt = true end
  end
  
  local a =player.speed
  if right then movement[1]=a end
  if left then movement[1]=-a end
  if up then movement[2]=-a end
  if down then movement[2]=a end
  
  movement[1]=movement[1]*dt * game_speed*60
  movement[2]=movement[2]*dt * game_speed*60
  
  local projectile_angle = math.atan2(my-py,mx-px)
  local player_angle =  math.atan2(py-my,px-mx)
  if love.mouse.isDown(1) then  
    if shoot_timer <= 0 then
      --generate_bolt = true
      stick_light_radius = {8,6}
      if shooting > 4 then shooting = 4 end
      if powerUps['triple_bullets'][2] > 0 then 
        for i = -1 , 1 do
        table.insert(Projectiles,new_projectile(math.ceil(px+math.cos(angle)*12),math.ceil(py+math.sin(angle)*12),700, 1.01,projectile_angle  +math.rad(math.random(-shooting, shooting))+ math.rad(10 * i),projectile, 'player', {1.5,0.8}))
        end
      else
        table.insert(Projectiles,new_projectile(math.ceil(px+math.cos(angle)*12),math.ceil(py+math.sin(angle)*12), 700, 1.01 ,projectile_angle + math.rad(math.random(-shooting, shooting)),projectile, 'player', {1.5,0.8}))
      end
      screen_shake_timer = 0.2
      screen_shake_range = {-2,2}
      shoot_timer = 0.15
      shooting = shooting + 1
    end
    
  else
    shooting = 0
  end
  
  -------------------stick light sparks----#
  if shoot_timer>0 then 
    for i=0,  game_speed * 6 do
        table.insert(sparks,Spark({math.ceil(px+math.cos(angle)*14)+math.random(-6,6),math.ceil(py+math.sin(angle)*14)+math.random(-6,6)}, math.rad(math.random(-360)), math.random(0.2,0.6),2 , 5, {125/255,245/255,235/255}))
    end
  else
    for i=0, game_speed * 2 do
        table.insert(sparks,Spark({math.ceil(px+math.cos(angle)*14)+math.random(-3,3),math.ceil(py+math.sin(angle)*14)+math.random(-3,3)}, math.rad(math.random(0,360)), math.random(0.2,0.6),3 , 9, {125/255,245/255,235/255}))
    end
  end
  
  if no_of_enemies == 0 then    
    transistion_timer = transistion_timer - dt * game_speed
    if transistion_timer <= 0 then
      love.graphics.setColor(1,1,1,1)
      love.load()
    end
  end
  
  
end

function love.mousepressed()
  
end

function love.keypressed(k)
  
  if k=='x' then generate_bolt = true end
  
end

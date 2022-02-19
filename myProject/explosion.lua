--[type, pos, velocity, size, [timer,duration]]
Explosion_Particles = {}

function update_explosion_particles(dt, explosion_particles, color)
  
  if explosion_particles == nil then explosion_particles = Explosion_Particles end
  
  for index, particle in pairs(explosion_particles) do
    
    if particle[1] == '3rd' then
      
      size = (particle[5][2] - particle[5][1]) / particle[5][2] * particle[4]
      if particle[5][1] > 2 then
        love.graphics.setColor(141/255, 137/255, 163/255)
        love.graphics.circle('fill', particle[2][1], particle[2][2], size)
      end
      
    end
    
    if particle[1] == 'core' then
      
      particle[2][1] = particle[2][1] + (particle[3][1] * dt * 60)
      particle[3][2] = -particle[3][2] * 0.7
      particle[2][2] = particle[2][2] + (particle[3][2] * dt * 60)
      
      particle[3][2] = particle[3][2] + (0.3 * dt * 60)
      particle[3][2] = math.min(particle[3][2], 5)
      size = (particle[5][2] - particle[5][1]) / 10
      
      love.graphics.setColor(1,1,1)
      love.graphics.circle('fill',particle[2][1], particle[2][2], size)
      
      if math.random(1,2)  == 1 then 
        table.insert(explosion_particles, {'3rd', {particle[2][1], particle[2][2]} , {0,0} , size + 1, {0,16} }) 
      end
      
      if particle[5][1] < 12 then
        if math.random(1,3) == 1 then
          table.insert(explosion_particles, {'2nd', {particle[2][1], particle[2][2]}, {math.random(0,20) / 10 - 1,0}, math.random(8,16), { 0 , 30 + math.random(0,10) - particle[5][1] * 2.5 + 2}})
        end
      end
      
    end
    
    if particle[1] == '2nd' then
      if size == nil then size = particle[4] end
      particle[3][2] = particle[3][2] - (0.2*dt*60)
      particle[3][2] = math.max(particle[3][2], -2 * (size/8))
      particle[2][2] = particle[2][2] + (particle[3][2])
      particle[2][1] = particle[2][1] + (particle[3][1])
      
      if particle[5][1] < 4 then
        size = particle[4] * (particle[5][1] / 4)
      else
        size = particle[4] * ((particle[5][2] - particle[5][1])/particle[5][2])
      end
      
      if particle[5][1] > 20 then
        particle[5][1] = particle[5][1] - dt * 30
      end
      
      local color_offset = (particle[5][1] - particle[5][2]) * 30 * (1 + particle[4]/8)
      if color == nil then
        love.graphics.setColor((255 - color_offset * 1.1)/255, (255 - color_offset * 1.2)/255, (255 - color_offset)/255)
      else
        love.graphics.setColor(color[1],color[2],color[3])
      end
      love.graphics.circle('fill', particle[2][1], particle[2][2], size)
      
    end
    
    particle[5][1] = particle[5][1] + (dt*60)
    if particle[5][1] >= particle[5][2] then
      table.remove(explosion_particles, index)
    end
    
  end
  
end
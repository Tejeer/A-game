function render_light(loc, radius, color, segment, angle)
  
  if angle==nil then angle=0 end
  
  
  love.graphics.setBlendMode('add')
  love.graphics.setColor(color[1],color[2],color[3],color[4]) --color[4]=alpha value
  
  love.graphics.push()
  love.graphics.translate(loc[1],loc[2])
  
  love.graphics.rotate(angle)
  
  if segment~=nil then 
    love.graphics.circle('fill',0,0,radius[1]+math.random(-0.5,0.5),segment)
  else
    love.graphics.circle('fill',0,0,radius[1]+math.random(-0.5,0.5))
  end
  
  love.graphics.circle('fill',0,0,radius[2]+math.random(-1,1))
  love.graphics.pop()
  
  love.graphics.setBlendMode('alpha')
  
end

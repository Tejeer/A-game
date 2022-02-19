function Animation(Path,w,h,durations)
  
  local animation={}
  animation.img = love.graphics.newImage(Path)
  animation.img:setFilter('nearest','nearest')
  
  animation.frames={}
  
  local img_w,img_h=animation.img:getDimensions()
  local x,y=0,0
  
  for ind,dur in ipairs(durations) do
    
    local quad=love.graphics.newQuad(x,y,w,h,img_w,img_h)
    
    for i=1,dur do
      table.insert(animation.frames,quad)
    end
    
    x=x+w
    
    if x>= img_w then x=0 y=y+h end
    if y>= img_h then y=0 end
  end
  
  return animation
  
end
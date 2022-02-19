function generate_stones(map)
  local stones={}
  
  while (#stones<30) do
    local y_pos, x_pos = math.random(1, #map - 1), math.random(1, #map[1] - 1)
    if map[y_pos][x_pos] == 0 then table.insert(stones,{math.random(1,4),(x_pos*16)+math.random(3,16), (y_pos*16)+math.random(3,16),math.random(0,3)*(math.pi/2)}) end
  end
  
  return stones
  
end

function generate_plants(map)
  local plants={}
  
  while (#plants<10) do
    local y_pos, x_pos = math.random(1, #map - 1), math.random(1, #map[1] - 1)
    if map[y_pos][x_pos] == 0 then table.insert(plants,{math.random(1,4),(x_pos*16)+math.random(8,16), (y_pos*16)+math.random(8,16),math.random(0,3)*(math.pi/2)}) end
  end
  
  return plants
end

function enemy_pos(map, number_of_enemies)
  local pos = {}
    
  while (#pos<number_of_enemies) do
    local y_pos, x_pos = math.random(1, #map - 1), math.random(1, #map[1] - 1)
    if map[y_pos][x_pos] == 0 then table.insert(pos,{(x_pos*16)+2, (y_pos*16)+2}) end
  end
  
  return pos
  
end

function get_cloth_pos(map , number_of_clothes)
  local pos = {}
    
  while (#pos<number_of_clothes) do
    local y_pos, x_pos = math.random(1, #map - 1), math.random(1, #map[1] - 1)
    if map[y_pos][x_pos] == 8 or map[y_pos][x_pos] == 2 then table.insert(pos,{(x_pos*16) + math.random(2,8), (y_pos*16)+16}) end
  end
  
  return pos
end
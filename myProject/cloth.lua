rag = {["points"]={[1]={[1]=-1,[2]=0},[2]={[1]=0,[2]=0},[3]={[1]=1,[2]=0},[4]={[1]=2,[2]=0},[5]={[1]=-1,[2]=1},[6]={[1]=0.5,[2]=1},[7]={[1]=1.8,[2]=1},[8]={[1]=-0.8,[2]=2},[9]={[1]=0.5,[2]=2},[10]={[1]=1.6,[2]=2},[11]={[1]=-0.6,[2]=3},[12]={[1]=1.4,[2]=3},[13]={[1]=-0.4,[2]=4},[14]={[1]=1.2,[2]=4},[15]={[1]=0.4,[2]=4.5},[16]={[1]=-0.2,[2]=5},[17]={[1]=1,[2]=5},[18]={[1]=0,[2]=6},[19]={[1]=0.8,[2]=6},[20]={[1]=0.4,[2]=8}},["scale"]=15,["connections"]={[1]={[1]=1,[2]=2},[2]={[1]=2,[2]=3},[3]={[1]=3,[2]=4},[4]={[1]=4,[2]=7},[5]={[1]=7,[2]=10},[6]={[1]=10,[2]=12},[7]={[1]=12,[2]=14},[8]={[1]=14,[2]=17},[9]={[1]=17,[2]=19},[10]={[1]=19,[2]=20},[11]={[1]=20,[2]=18},[12]={[1]=18,[2]=16},[13]={[1]=16,[2]=13},[14]={[1]=13,[2]=11},[15]={[1]=11,[2]=8},[16]={[1]=8,[2]=5},[17]={[1]=5,[2]=1},[18]={[1]=2,[2]=6},[19]={[1]=6,[2]=3},[20]={[1]=6,[2]=9},[21]={[1]=9,[2]=15},[22]={[1]=15,[2]=20},[23]={[1]=15,[2]=19},[24]={[1]=15,[2]=18},[25]={[1]=15,[2]=13},[26]={[1]=15,[2]=14},[27]={[1]=9,[2]=11},[28]={[1]=9,[2]=12},[29]={[1]=9,[2]=7},[30]={[1]=9,[2]=5},[31]={[1]=13,[2]=12},[32]={[1]=14,[2]=11},[33]={[1]=6,[2]=1},[34]={[1]=6,[2]=4}},["color"]={[1]=15,[2]=106,[3]=99},["grounded"]={[1]=1,[2]=2,[3]=3,[4]=4}}

function dis(p1, p2)
  return math.sqrt((p2[2] - p1[2])^2 + (p2[1] - p1[1])^2)
end

function ClothObj(rag)
  local self = {}
  self.points = {}
  self.sticks = {}
  self.orig_points = {}
  self.scale = rag['scale']
  self.grounded = rag['grounded']
  self.add_stick = function (points)
    table.insert(self.sticks, {points[1], points[2], dis( {self.points[points[1]][1], self.points[points[1]][2]}, {self.points[points[2]][1], self.points[points[2]][2]} ) })
  end
  
  
  self.move_grounded = function (offset)
    for i,v in ipairs(self.grounded) do
      self.points[v][1] = self.orig_points[v][1] + offset[1] / self.scale
      self.points[v][2] = self.orig_points[v][2] + offset[2] / self.scale
      self.points[v][3] = self.points[v][1]
      self.points[v][4] = self.points[v][2]
    end
  end
  
  for i,v in ipairs(rag['points']) do
    table.insert(self.points, {v[1], v[2], v[1], v[2]})
    table.insert(self.orig_points, {v[1], v[2]})
  end
  
  for i,v in ipairs(rag['connections']) do
    self.add_stick(v)
  end
  
  self.update = function (velocity)
    for i, point in ipairs(self.points) do
      if self.grounded[i] == nil then 
        local dx, dy = point[1] - point[3], point[2] - point[4]
        self.points[i][3] = self.points[i][1]
        self.points[i][4] = self.points[i][2]
        self.points[i][1] = self.points[i][1] + dx 
        self.points[i][2] = self.points[i][2] + dy
        self.points[i][2] = self.points[i][2] + 0.05
        if velocity~= nil then 
          self.points[i][1] = self.points[i][1] + velocity[1]
          self.points[i][2] = self.points[i][2] + velocity[2]
        end
      end
    end
  end
  
  self.update_sticks = function()
    for i, stick in ipairs(self.sticks) do
      local dist = dis({self.points[stick[1]][1], self.points[stick[1]][2]}, {self.points[stick[2]][1], self.points[stick[2]][2]})
      local ratio = (stick[3] - dist) / dist / 2
      local dx, dy = self.points[stick[2]][1] - self.points[stick[1]][1], self.points[stick[2]][2] - self.points[stick[1]][2]
      self.points[stick[1]][1] = self.points[stick[1]][1] - (dx * ratio * 0.85)
      self.points[stick[1]][2] = self.points[stick[1]][2] - (dy * ratio * 0.85)
      self.points[stick[2]][1] = self.points[stick[2]][1] + (dx * ratio * 0.85)
      self.points[stick[2]][2] = self.points[stick[2]][2] + (dy * ratio * 0.85)
    end
  end
  
  self.render = function(offset, color, render_sticks)
    love.graphics.setColor(color[1], color[2], color[3])
    local render_points = {}
    for i,v in ipairs(self.points) do
        table.insert(render_points, {v[1] * self.scale + offset[1], v[2] * self.scale + offset[2]})
    end
    local p_points = {}
    for i,stick in ipairs(self.sticks) do
      if render_sticks then 
        love.graphics.line({render_points[stick[1]][1], render_points[stick[1]][2],  render_points[stick[2]][1], render_points[stick[2]][2]})
     end
      table.insert(p_points, render_points[stick[1]][1])
      table.insert(p_points, render_points[stick[1]][2])
    end
    love.graphics.polygon('fill', p_points)
  end
  
  return self
end

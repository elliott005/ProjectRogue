Game = Object:extend()

function Game:load()
    self.joystick = nil
    self.player = Player(0, 0)
    self.background = Background()

    self.world_size = 20

    self.maps_folder_path = "maps/exports/"

    self.available_maps_names = {}
    for i, map_file in ipairs(love.filesystem.getDirectoryItems(self.maps_folder_path)) do
        table.insert(self.available_maps_names, string.sub(map_file, 1, -5))
    end
    self.maps = {}
    for x = -self.world_size / 2, self.world_size / 2 - 1 do
        table.insert(self.maps, Map(vector(x * Globals.tilemap_size.x, 0), self.maps_folder_path .. self.available_maps_names[love.math.random(#self.available_maps_names)]))
    end

    for i, map in ipairs(self.maps) do
        neighbors = {0, 0}
        if i > 1 then
            neighbors[1] = self.maps[i - 1]
        end
        if i < #self.maps then
            neighbors[2] = self.maps[i + 1]
        end
        map:init(neighbors)
    end
end

function Game:update(dt)
    for i, map in ipairs(self.maps) do
        map:update(dt)
    end
    self.player:update(dt, self.joystick, self.maps)
end

function Game:draw()
    self.background:draw(self.player.position)
    self.player:updateCamera()
    for i, map in ipairs(self.maps) do
        map:draw()
    end
    self.player:draw()

    love.graphics.origin()
    love.graphics.print(love.timer.getFPS(), 25, 25)
end

function Game:joystickadded(joystick)
    self.joystick = joystick
end
Tile = Object:extend()

Tile.air = {
    id = 0
}

local tiles_image = love.graphics.newImage("assets/Tiles/Tilesheet - WOODS.png")

local g = anim8.newGrid(32, 32, tiles_image:getWidth(), tiles_image:getHeight())
Tile.dirt = {
    id = 1,
    image = tiles_image,
    grid = g,
    anim_speed = 1
}

function setDefault(t, d)
    local mt = {__index = function () return d end}
    setmetatable(t, mt)
end
Tile.gid_to_tile = {
    [0] = Tile.air,
    [18] = Tile.dirt
}
setDefault(Tile.gid_to_tile, Tile.air)

function Tile:new(x, y, tile_type)
    self.position = vector(x, y)
    self.tile_type = tile_type
    self.image_x = 0
    self.image_y = 0
end

function Tile:init(neighbors)
    if self.tile_type == Tile.air then
        return
    end
    pos = check_neighbors(neighbors, self.tile_type)
    if self.tile_type == Tile.dirt then
        self.image_x = pos.x
        self.image_y = pos.y
    end
    self.animation = anim8.newAnimation(self.tile_type.grid(self.image_x, self.image_y), self.tile_type.anim_speed)
end

function Tile:update(dt)
    if self.tile_type == Tile.air then
        return
    end
    self.animation:update(dt)
end

function Tile:draw()
    --love.graphics.rectangle("fill", self.position.x, self.position.y, Globals.tile_size, Globals.tile_size)
    if self.tile_type == Tile.air then
        return
    end
    self.animation:draw(self.tile_type.image, self.position:unpack())
end

function check_neighbors(neighbors, tile_type)-- neighbors is a list of 4 tiles: above, left, right, below
    image_x = 0
    image_y = 0
    -- 0 neighbors
    if neighbors[1] ~= tile_type and neighbors[2] ~= tile_type and neighbors[3] ~= tile_type and neighbors[4] ~= tile_type then
        image_x = 2
        image_y = 2
    -- 1 neighbor
    elseif neighbors[1] == tile_type and neighbors[2] ~= tile_type and neighbors[3] ~= tile_type and neighbors[4] ~= tile_type then
        image_x = 2
        image_y = 8
    elseif neighbors[1] ~= tile_type and neighbors[2] == tile_type and neighbors[3] ~= tile_type and neighbors[4] ~= tile_type then
        image_x = 15
        image_y = 5
    elseif neighbors[1] ~= tile_type and neighbors[2] ~= tile_type and neighbors[3] == tile_type and neighbors[4] ~= tile_type then
        image_x = 13
        image_y = 5
    elseif neighbors[1] ~= tile_type and neighbors[2] ~= tile_type and neighbors[3] ~= tile_type and neighbors[4] == tile_type then
        image_x = 2
        image_y = 6
    -- 2 neighbors
    elseif neighbors[1] == tile_type and neighbors[2] == tile_type and neighbors[3] ~= tile_type and neighbors[4] ~= tile_type then
        image_x = 3
        image_y = 3
    elseif neighbors[1] == tile_type and neighbors[2] ~= tile_type and neighbors[3] == tile_type and neighbors[4] ~= tile_type then
        image_x = 1
        image_y = 3
    elseif neighbors[1] == tile_type and neighbors[2] ~= tile_type and neighbors[3] ~= tile_type and neighbors[4] == tile_type then
        image_x = 2
        image_y = 7
    elseif neighbors[1] ~= tile_type and neighbors[2] == tile_type and neighbors[3] == tile_type and neighbors[4] ~= tile_type then
        image_x = 14
        image_y = 5
    elseif neighbors[1] ~= tile_type and neighbors[2] == tile_type and neighbors[3] ~= tile_type and neighbors[4] == tile_type then
        image_x = 3
        image_y = 1
    elseif neighbors[1] ~= tile_type and neighbors[2] ~= tile_type and neighbors[3] == tile_type and neighbors[4] == tile_type then
        image_x = 1
        image_y = 1
    -- 3 neighbors
    elseif neighbors[1] == tile_type and neighbors[2] == tile_type and neighbors[3] == tile_type and neighbors[4] ~= tile_type then
        image_x = 2
        image_y = 3
    elseif neighbors[1] == tile_type and neighbors[2] == tile_type and neighbors[3] ~= tile_type and neighbors[4] == tile_type then
        image_x = 3
        image_y = 2
    elseif neighbors[1] == tile_type and neighbors[2] ~= tile_type and neighbors[3] == tile_type and neighbors[4] == tile_type then
        image_x = 1
        image_y = 2
    elseif neighbors[1] ~= tile_type and neighbors[2] == tile_type and neighbors[3] == tile_type and neighbors[4] == tile_type then
        image_x = 2
        image_y = 1
    -- 4 neighbors
    elseif neighbors[1] == tile_type and neighbors[2] == tile_type and neighbors[3] == tile_type and neighbors[4] == tile_type then
        image_x = 2
        image_y = 2
    end

    return vector(image_x, image_y)
end
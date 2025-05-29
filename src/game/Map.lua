Map = Object:extend()

function Map:new(pos, path)
    self.position = pos
    self.data = require(path)
    
    self.optional_layer_chance = 50

    self.base_layer = 0
    self.optional_layers = {}
    self.decorations_layer = 0
    self.optional_decorations_layers = {}
    for i, v in ipairs(self.data.layers) do
        if string.lower(v.name) == "base" then
            self.base_layer = v
        elseif string.lower(v.name) == "decorations" then
            self.decorations_layer = v
        elseif string.find(string.lower(v.name), "optional") ~= nil and string.find(string.lower(v.name), "decorations") ~= nil then
            table.insert(self.optional_decorations_layers, v)
        elseif string.find(string.lower(v.name), "optional") ~= nil then
            table.insert(self.optional_layers, v)
        end
    end
    assert(self.base_layer ~= 0, "tilemap " .. path .. " does not contain a base layer!")

    self.tilemap = {}
    for x = 1, self.base_layer.width do
        table.insert(self.tilemap, {})
        for y = 1, self.base_layer.height do
            table.insert(self.tilemap[x], 
                Tile(
                    (self.position.x + x - 1) * Globals.tile_size,
                    (self.position.y + y - 1) * Globals.tile_size,
                    Tile.gid_to_tile[self.base_layer.data[(y - 1) * self.base_layer.width + x]]
                )
            )
        end
    end

    for i, layer in ipairs(self.optional_layers) do
        if love.math.random(100) <= self.optional_layer_chance then
            for x = 1, layer.width do
                for y = 1, layer.height do
                    local tile_type = Tile.gid_to_tile[layer.data[(y - 1) * layer.width + x]]
                    if tile_type ~= Tile.air then
                        self.tilemap[x][y] = Tile(
                            (self.position.x + x - 1) * Globals.tile_size,
                            (self.position.y + y - 1) * Globals.tile_size,
                            tile_type
                        )
                    end
                end
            end
        end
    end

    self.possible_decorations = {
        {img = love.graphics.newImage("assets/Decorations/GRASS 1-1.png"), offset = vector(0, 14)},
        {img = love.graphics.newImage("assets/Decorations/GRASS 1-2.png"), offset = vector(0, 14)},
        {img = love.graphics.newImage("assets/Decorations/GRASS 2-1.png"), offset = vector(-1, 12)},
        {img = love.graphics.newImage("assets/Decorations/GRASS 2-2.png"), offset = vector(-1, 12)},
        {img = love.graphics.newImage("assets/Decorations/GRASS 3-1.png"), offset = vector(0, 21)},
        {img = love.graphics.newImage("assets/Decorations/GRASS 3-2.png"), offset = vector(0, 21)},
        {img = love.graphics.newImage("assets/Decorations/MUSHROOM 1-1.png"), offset = vector(0, 15)},
        {img = love.graphics.newImage("assets/Decorations/MUSHROOM 1-2.png"), offset = vector(0, 15)},
        {img = love.graphics.newImage("assets/Decorations/MUSHROOM 2-1.png"), offset = vector(10, 23)}
    }
    self.decorations = {}
    if self.decorations_layer ~= 0 then
        for i, obj in ipairs(self.decorations_layer.objects) do
            table.insert(self.decorations, {decoration_idx = love.math.random(#self.possible_decorations), position = vector(obj.x, obj.y)})
        end
    end
    for i, layer in ipairs(self.optional_decorations_layers) do
        if love.math.random(100) <= self.optional_layer_chance then
            for i, obj in ipairs(layer.objects) do
                table.insert(self.decorations, {decoration_idx = love.math.random(#self.possible_decorations), position = vector(obj.x, obj.y)})
            end
        end
    end
end

function Map:init(map_neighbors) -- neigbors is a table of 2 maps: left, right
    for x, column in ipairs(self.tilemap) do
        for y, tile in ipairs(column) do
            neighbors = {Tile.air, Tile.air, Tile.air, Tile.air}
            if x > 1 then
                neighbors[2] = self.tilemap[x - 1][y].tile_type
            elseif map_neighbors[1] ~= 0 then
                neighbors[2] = map_neighbors[1].tilemap[#map_neighbors[1].tilemap][y].tile_type
            end
            if x < #self.tilemap then
                neighbors[3] = self.tilemap[x + 1][y].tile_type
            elseif map_neighbors[2] ~= 0 then
                neighbors[3] = map_neighbors[2].tilemap[1][y].tile_type
            end
            if y > 1 then
                neighbors[1] = self.tilemap[x][y - 1].tile_type
            end
            if y < #column then
                neighbors[4] = self.tilemap[x][y + 1].tile_type
            end
            tile:init(neighbors)
        end
    end
end

function Map:update(dt)
    for x, column in ipairs(self.tilemap) do
        for y, tile in ipairs(column) do
            tile:update(dt)
        end
    end
end

function Map:draw()
    for x, column in ipairs(self.tilemap) do
        for y, tile in ipairs(column) do
            tile:draw()
            --[[  if tile.tile_type == Tile.dirt then
            love.graphics.print(tostring(x) .. " " .. tostring(y), tile.position:unpack())
        end ]]
        end
    end
    for i, decoration in ipairs(self.decorations) do
        love.graphics.draw(self.possible_decorations[decoration.decoration_idx].img, (self.position * Globals.tile_size + decoration.position + self.possible_decorations[decoration.decoration_idx].offset):unpack())
    end
end
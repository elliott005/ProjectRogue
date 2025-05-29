Background = Object:extend()

function Background:new()
    self.layers = {
        love.graphics.newImage("assets/Backgrounds/BACKGROUND.png"),
        love.graphics.newImage("assets/Backgrounds/BUSH - BACKGROUND.png"),
        love.graphics.newImage("assets/Backgrounds/VINES - Second.png"),
        love.graphics.newImage("assets/Backgrounds/WOODS - Second.png"),
        love.graphics.newImage("assets/Backgrounds/WOODS - First.png"),
    }
    self.layer_offsets = {
        0,
        0.4,
        0.4,
        0.5,
        0.6,
    }
    
    self.pos_y = -400

    self.height_img_buffer = 500
    self.layer_quads = {}
    for i, layer in ipairs(self.layers) do
        layer:setWrap("clamp", "clamp")
        table.insert(self.layer_quads, love.graphics.newQuad(0, -self.height_img_buffer / 2, layer:getWidth(), layer:getHeight() + self.height_img_buffer / 2, layer:getDimensions()))
    end
end

function Background:draw(player_position)
    local width, height, flags = love.window.getMode()
    for i, layer in ipairs(self.layers) do
        scale = vector(width / layer:getWidth(), height / layer:getHeight())
        local base_pos = player_position * self.layer_offsets[i]
        for j = 0, 1 do
            love.graphics.draw(
                layer,
                self.layer_quads[i],
                -(base_pos.x % width) + j * width,
                self.pos_y - player_position.y,
                0,
                scale:unpack()
            )
        end
    end
end
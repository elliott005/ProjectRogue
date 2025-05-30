EnemyBase = Object:extend()

enemy_types = {
    boar = require("src/enemies/Boar")
}

function EnemyBase:new(x, y, width, height)
    self.position = vector(x, y)
    self.collision_size = vector(width, height)

    -- movement variables
    self.velocity = vector(0, 0)
    self.max_speed = vector(150, 256)
    self.acceleration = 300
    self.friction = 400
    self.gravity = 600
    self.collision_buffer = vector(0.1, 0.2)
    self.grounded = false
    self.movement_locked = false

    -- drawing variables
    self.draw_offset = vector(0, 0)
    self.animations = {}
    self.current_animation = "idle"
    self.facingLeft = false
    self.frame_width = 128
    self.frame_height = 64
end

function EnemyBase:draw()
    draw_pos = vector(
        self.position.x - self.draw_offset.x, self.position.y - self.draw_offset.y
    )
    if not self.facingLeft then
        draw_pos.x = draw_pos.x + self.frame_width
    end
    self.animations[self.current_animation]["anim"]:draw(
        self.animations[self.current_animation]["image"],
        draw_pos.x, draw_pos.y,
        0,
        self.facingLeft and 1 or -1, 1
    )
end

function EnemyBase:accelerate(dt, x)
    if (x ~= 0 and lume.sign(x) ~= lume.sign(self.velocity.x) and self.velocity.x ~= 0) or x == 0 then
        self.velocity.x = lume.sign(self.velocity.x) * math.max(0, math.abs(self.velocity.x) - self.friction * dt)
    end
    self.velocity.x = lume.clamp(self.velocity.x + self.acceleration * x * dt, -self.max_speed.x * math.abs(x), self.max_speed.x * math.abs(x))
end

function EnemyBase:apply_gravity(dt)
    self.velocity.y = math.min(self.max_speed.y, self.velocity.y + self.gravity * dt)
end

function EnemyBase:update_animation(dt)
    if self.velocity.x > 0 then
        self.facingLeft = false
    elseif self.velocity.x < 0 then
        self.facingLeft = true
    end
    self.animations[self.current_animation]["anim"]:update(dt)
end

function EnemyBase:loadAnim(name, asset_path, frame_width, frame_height, anim_speed, frames)
    self.animations[name] = {}
    self.animations[name]["image"] = love.graphics.newImage(asset_path)
    local g = anim8.newGrid(frame_width, frame_height, self.animations[name]["image"]:getWidth(), self.animations[name]["image"]:getHeight(), 1, 1)
    self.animations[name]["anim"] = anim8.newAnimation(g(unpack(frames)), anim_speed)
end

function EnemyBase:move(dt, maps)
    local tilemaps = {}
    for i = math.floor((self.position.x - maps[1].position.x * Globals.tile_size) / Globals.tilemap_size_pixels.x) + 1,
    math.ceil((self.position.x + self.collision_size.x) / Globals.tilemap_size_pixels.x) - maps[1].position.x / Globals.tilemap_size.x + 1 do
        if i > 0 and i <= #maps then
            table.insert(tilemaps, maps[i])
        end
    end
    self:check_collision_x(dt, tilemaps)
    self:check_collision_y(dt, tilemaps)
end

function EnemyBase:check_collision_x(dt, tilemaps)
    if #tilemaps == 0 then
        self.position.x = self.position.x + self.velocity.x * dt
        return
    end
    collided = false
    if self.velocity.x ~= 0 then
        offset = 0
        if self.velocity.x > 0 then
            offset = self.collision_size.x
        end
        rect = {
            pos = self.position,
            size = vector(offset + self.velocity.x * dt, self.collision_size.y)
        }
        for x = math.floor((rect.pos.x) / Globals.tile_size) + 1, math.floor((rect.pos.x + rect.size.x) / Globals.tile_size) + 1, lume.sign(self.velocity.x) do
            local current_map = tilemaps[1].tilemap
            local map_x = x - tilemaps[1].position.x
            --print(temp_x, tilemaps[1].position.x + Globals.tilemap_size.x)
            if map_x > Globals.tilemap_size.x and tilemaps[2] ~= nil then
                current_map = tilemaps[2].tilemap
                map_x = x - tilemaps[2].position.x
            end
            for y = math.floor((rect.pos.y + self.collision_buffer.y) / Globals.tile_size) + 1, math.floor((rect.pos.y + rect.size.y - self.collision_buffer.y) / Globals.tile_size) + 1 do
                if map_x > 0 and map_x <= #current_map and y > 0 and y <= #current_map[map_x] then
                    if current_map[map_x][y].tile_type ~= Tile.air then
                        collided = true
                        pos_x = x * Globals.tile_size
                        if self.velocity.x > 0 then
                            self.position.x = pos_x - self.collision_size.x - self.collision_buffer.x - Globals.tile_size
                        else
                            self.position.x = pos_x + self.collision_buffer.x
                        end
                    end
                end
                if collided then
                    break
                end
            end
            if collided then
                break
            end
        end
    end
    if collided then
        self.velocity.x = 0
    else
        self.position.x = self.position.x + self.velocity.x * dt
    end
end

function EnemyBase:check_collision_y(dt, tilemaps)
    if #tilemaps == 0 then
        self.position.y = self.position.y + self.velocity.y * dt
        return
    end
    collided = false
    if self.velocity.y ~= 0 then
        rect = {
            pos = self.position,
            size = vector(self.collision_size.x, self.collision_size.y + self.velocity.y * dt)
        }
        offset = 0
        if self.velocity.y < 0 then
            offset = -Globals.tile_size * 1.5
        end
        for x = math.floor((rect.pos.x + self.collision_buffer.x) / Globals.tile_size) + 1, math.floor((rect.pos.x - self.collision_buffer.x + rect.size.x) / Globals.tile_size) + 1 do
            local current_map = tilemaps[1].tilemap
            local map_x = x - tilemaps[1].position.x
            --print(temp_x, tilemaps[1].position.x + Globals.tilemap_size.x)
            if map_x > Globals.tilemap_size.x and tilemaps[2] ~= nil then
                current_map = tilemaps[2].tilemap
                map_x = x - tilemaps[2].position.x
            end
            for y = math.floor(rect.pos.y / Globals.tile_size) + 1, math.ceil((rect.pos.y + rect.size.y + offset) / Globals.tile_size), lume.sign(self.velocity.y) do
                if map_x > 0 and map_x <= #current_map and y > 0 and y <= #current_map[map_x] then
                    if current_map[map_x][y].tile_type ~= Tile.air then
                        collided = true
                        --print(x * Globals.tile_size)
                        pos_y = y * Globals.tile_size
                        if self.velocity.y > 0 then
                            self.position.y = pos_y - self.collision_size.y - Globals.tile_size -- self.collision_buffer.y
                        else
                            self.position.y = pos_y + self.collision_buffer.y
                        end
                    end
                end
                if collided then
                    break
                end
            end
            if collided then
                break
            end
        end
    end
    self.grounded = false
    if collided then
        if self.velocity.y > 0.0 then
            self.grounded = true
        end
        self.velocity.y = 0
    else
        self.position.y = self.position.y + self.velocity.y * dt
    end
end
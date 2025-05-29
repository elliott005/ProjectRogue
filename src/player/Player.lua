Player = Object:extend()

function Player:new(x, y)
    self.position = vector(x, y)
    self.collision_size = vector(16, 45)

    -- movement variables
    self.velocity = vector(0, 0)
    self.max_speed = vector(150, 256)
    self.acceleration = 300
    self.friction = 400
    self.jump_gravity = 400
    self.gravity = 600
    self.collision_buffer = vector(0.2, 0.1)
    self.grounded = false
    self.jump_speed = -250
    self.coyote_time = 0.2
    self.coyote_timer = 0.0

    -- drawing variables
    self.draw_offset = vector(57, 18)
    self.frame_width = 128
    self.frame_height = 64
    self.animations = {}
    self:loadAnim("idle", "assets/SL_character/Idle.png", self.frame_width, self.frame_height, 0.1, {"1-2", "1-4"})
    self:loadAnim("run", "assets/SL_character/Run.png", self.frame_width, self.frame_height, 0.1, {"1-2", "1-4"})
    self:loadAnim("jump_up", "assets/SL_character/Jump.png", self.frame_width, self.frame_height, 0.2, {"1-2", "1-2"})
    self:loadAnim("jump_end", "assets/SL_character/Jump.png", self.frame_width, self.frame_height, 0.2, {1, 3})
    self.current_animation = "idle"
    self.facingRight = false
    self.camera_position = vector(0, 0)
    self.jump_animation_finished = false
end

function Player:update(dt, joystick, maps)
    tilemaps = {}
    for i = math.floor((self.position.x - maps[1].position.x * Globals.tile_size) / Globals.tilemap_size_pixels.x) + 1,
    math.ceil((self.position.x + self.collision_size.x) / Globals.tilemap_size_pixels.x) - maps[1].position.x / Globals.tilemap_size.x + 1 do
        if i > 0 and i <= #maps then
            table.insert(tilemaps, maps[i])
        end
    end
    
    -- movement
    local was_grounded = self.grounded
    self:move(dt, joystick, tilemaps)
    if self.coyote_timer > 0.0 then
        self.coyote_timer = self.coyote_timer + dt
        if self.coyote_timer > self.coyote_time then
            self.coyote_timer = 0.0
        end
    end
    if was_grounded and not self.grounded and self.velocity.y > 0.0 then
        self.coyote_timer = dt
    end

    -- update animations
    if self.velocity.x > 0 then
        self.facingRight = true
    elseif self.velocity.x < 0 then
        self.facingRight = false
    end
    local anim_speed = dt
    if self.grounded then
        if math.abs(self.velocity.x) > self.max_speed.x / 5 then
            self.current_animation = "run"
            anim_speed = anim_speed * self.velocity.x / self.max_speed.x
        else
            self.current_animation = "idle"
        end
        self.jump_animation_finished = false
    else
        if not self.jump_animation_finished then
            if self.current_animation ~= "jump_up" then
                self.animations["jump_up"]["anim"]:gotoFrame(1)
            end
            self.current_animation = "jump_up"
        else
            self.current_animation = "jump_end"
        end        
    end

    self.animations[self.current_animation]["anim"]:update(anim_speed)
    if self.current_animation == "jump_up" and self.animations[self.current_animation]["anim"].loop_ended then
        self.current_animation = "idle"
        self.jump_animation_finished = true
    end

    -- update camera
    local width, height, flags = love.window.getMode()
    self.camera_position.x = self.position.x - width / 2 - self.collision_size.x / 2
    self.camera_position.y = self.position.y - height / 2 - self.collision_size.y / 2
end

function Player:draw()
    --love.graphics.rectangle("fill", self.position.x, self.position.y, self.collision_size:unpack())
    draw_pos = vector(
        self.position.x - self.draw_offset.x, self.position.y - self.draw_offset.y
    )
    if not self.facingRight then
        draw_pos.x = draw_pos.x + self.frame_width
    end
    self.animations[self.current_animation]["anim"]:draw(
        self.animations[self.current_animation]["image"],
        draw_pos.x, draw_pos.y,
        0,
        self.facingRight and 1 or -1, 1
    )
end

function Player:updateCamera()
    love.graphics.translate((self.camera_position * -1):unpack())
end

function Player:loadAnim(name, asset_path, frame_width, frame_height, anim_speed, frames)
    self.animations[name] = {}
    self.animations[name]["image"] = love.graphics.newImage(asset_path)
    local g = anim8.newGrid(frame_width, frame_height, self.animations[name]["image"]:getWidth(), self.animations[name]["image"]:getHeight(), 1, 1)
    self.animations[name]["anim"] = anim8.newAnimation(g(unpack(frames)), anim_speed)
end

function Player:move(dt, joystick, tilemaps)
    input_left = inputs:checkInput(inputs.left, joystick)
    input_right = inputs:checkInput(inputs.right, joystick)
    input_delta = input_right - input_left
    if (input_delta ~= 0 and lume.sign(input_delta) ~= lume.sign(self.velocity.x) and self.velocity.x ~= 0) or input_delta == 0 then
        self.velocity.x = lume.sign(self.velocity.x) * math.max(0, math.abs(self.velocity.x) - self.friction * dt)
    end
    self.velocity.x = lume.clamp(self.velocity.x + self.acceleration * input_delta * dt, -self.max_speed.x * math.abs(input_delta), self.max_speed.x * math.abs(input_delta))
    
    local grav = self.gravity
    if self.velocity.y < 0 then
        grav = self.jump_gravity
    end
    self.velocity.y = math.min(self.max_speed.y, self.velocity.y + grav * dt)
    
    input_jump = inputs:checkInput(inputs.jump, joystick)
    if input_jump ~= 0 and (self.grounded or self.coyote_timer > 0.0) then
        self.velocity.y = self.jump_speed
        self.coyote_timer = 0.0
    end
    if #tilemaps == 0 then
        self.position = self.position + self.velocity * dt
    else
        self:check_collision(dt, tilemaps)
    end
end

function Player:check_collision(dt, tilemaps)
    collided = false
    if self.velocity.x ~= 0 then
        rect = {
            pos = self.position,
            size = vector(self.collision_size.x + self.velocity.x * dt, self.collision_size.y)
        }
        offset = 0
        if self.velocity.x < 0 then
            offset = -Globals.tile_size / 2
        end
        for x = math.floor(rect.pos.x / Globals.tile_size) + 1, math.ceil((rect.pos.x + offset + rect.size.x) / Globals.tile_size), lume.sign(self.velocity.x) do
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
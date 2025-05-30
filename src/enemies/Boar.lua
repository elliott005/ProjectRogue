local Boar = EnemyBase:extend()

function Boar:new(x, y)
    Boar.super.new(self, x, y, 48, 32)

    self.frame_width = 48
    self.frame_height = 32

    self:loadAnim("idle", "assets/Mob/Boar/Idle/Idle-Sheet.png", 48, 32, 0.1, {"1-4", 1})
    self:loadAnim("walk", "assets/Mob/Boar/Walk/Walk-Base-Sheet.png", 48, 32, 0.1, {"1-4", 1})
end

function Boar:update(dt, maps, player_position)
    self.super.accelerate(self, dt, lume.sign(player_position.x - self.position.x))
    self.super.apply_gravity(self, dt)
    self.super.move(self, dt, maps)
    anim_speed = dt
    if self.velocity.x ~= 0.0 then
        self.current_animation = "walk"
        anim_speed = anim_speed * self.velocity.x / self.max_speed.x
    end
    self.super.update_animation(self, anim_speed)
end

function Boar:draw()
    self.super.draw(self)
end

return Boar
local Inputs = {}

Inputs.left = {
    keyboard = {"left"},
    gamepad = {"dpleft"},
    gamepad_axis_negative = {"leftx"},
}

Inputs.right = {
    keyboard = {"right"},
    gamepad = {"dpright"},
    gamepad_axis_positive = {"leftx"},
}

Inputs.jump = {
    keyboard = {"space", "w"},
    gamepad = {"a"}
}

Inputs.attack = {
    keyboard = {"d"},
    gamepad = {"b"}
}

function Inputs:checkInput(input, joystick)
    if input.keyboard then
        if love.keyboard.isDown(input.keyboard) then
            return 1
        end
    end
    if input.mouse then
        if love.mouse.isDown(input.mouse) then
            return 1
        end
    end
    if joystick then
        if input.gamepad then
            if joystick:isGamepadDown(input.gamepad) then
                return 1
            end
        end
        if input.gamepad_axis_negative then
            for i, v in ipairs(input.gamepad_axis_negative) do
                local val = joystick:getGamepadAxis(v)
                if val < 0 then
                    return math.abs(val)
                end
            end
        end
        if input.gamepad_axis_positive then
            for i, v in ipairs(input.gamepad_axis_positive) do
                local val = joystick:getGamepadAxis(v)
                if val > 0 then
                    return val
                end
            end
        end
    end

    return 0
end

return Inputs
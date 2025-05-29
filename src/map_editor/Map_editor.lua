Map_editor = Object:extend()

function Map_editor:load()
    self.current_file = ""
    self.maps_folder_path = "maps/"
    self.buttons = {}
    self.file_rect_size = vector(100, 50)
    self.deleting = false
    self.deleting_what = ""
    self.delete_text = ""
    self:check_files()
end

function Map_editor:update(dt)
    if self.current_file == "" then
        if inputs:checkInput(inputs.map_editor_select) ~= 0 then
            local x, y = love.mouse.getPosition()
            for i, button in ipairs(self.buttons) do
                if x > button.pos.x and x < button.pos.x + button.size.x and y > button.pos.y and y < button.pos.y + button.size.y then
                    if button.name:find("^delete: ") then
                        self.deleting_what = string.sub(button.name, 9, #button.name)
                        self.deleting = true
                    else
                        self.current_file = button.name
                    end
                    break
                end
            end
        end
    else

    end
end

function Map_editor:draw()
    if self.current_file == "" then
        local width, height, flags = love.window.getMode()
        if not self.deleting then
            love.graphics.setColor(1, 1, 1)
            for i, button in ipairs(self.buttons) do
                love.graphics.rectangle("line", button.pos.x, button.pos.y, button.size:unpack())
                local name = button.name
                if name:find("^delete: ") then
                    name = "delete"
                end
                love.graphics.print(name, button.pos.x + 5, button.pos.y + 5)
            end
        else
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 50, 50, width - 100, height - 100)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(self.delete_text, 100, 100)
        end
    else
        
    end
end

function Map_editor:keypressed(key, scancode, isrepeat)
    if self.deleting then
        if key == "escape" then
            self.deleting = false
            self.delete_text = ""
        elseif key == "backspace" then
            self.delete_text = string.sub(self.delete_text, 1, #self.delete_text - 1)
        elseif key == "return" then
            if string.lower(self.delete_text) == "delete" then
                print(self.maps_folder_path .. self.deleting_what)
                contents = love.filesystem.read(self.maps_folder_path .. self.deleting_what)
                print(contents)
                self.deleting = false
                self.delete_text = ""
            end
        else
            self.delete_text = self.delete_text .. key
        end
    end
end

function Map_editor:check_files()
    files = love.filesystem.getDirectoryItems(self.maps_folder_path)
    for i, file in ipairs(files) do
        table.insert(self.buttons, {
            name = file,
            pos = vector(self.file_rect_size.x * (i - 1) + 25, 25),
            size = self.file_rect_size
        })
        table.insert(self.buttons, {
            name = "delete: " .. file,
            pos = vector(self.file_rect_size.x * (i - 1) + 25, 30 + self.file_rect_size.y),
            size = vector(self.file_rect_size.x, 25)
        })
    end
end
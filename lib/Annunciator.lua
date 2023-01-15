Annunciator = {
    x=0, y=0,
    text = nil,
    canvas = nil,
    width = 62, -- pixels
    heigth = 18, -- pixels
    color = 'white',
    is_visible = false,
    active_timer = nil,
    blink_delay = 200, -- milliseconds
    
    draw_strip = function(self, canvas) -- draw horizontal strip gauges
        canvas_draw(canvas, function()
         _rect(0, 0, self.width, self.heigth)
         _fill(self.color)
        end)
    end,

    init = function (self, x, y, label, color)
        self.x = x
        self.y = y
        self.color = color
        self.canvas = canvas_add(x, y, self.width, self.heigth)
        self:draw_strip(self.canvas)
        self.text = txt_add(label, annunciator_txtstyle, x, y, self.width, self.heigth)
    end,

    visible = function (self, is_visible)
        visible(self.canvas, is_visible)
        visible(self.text, is_visible)
    end,

    switch_visibility = function (self)
        self.is_visible = not self.is_visible
        self:visible(self.is_visible)
    end,

    active = function (self, is_active)
        self:visible(is_active)

        -- setup timer for blinking
       --[[  if(is_active and not active_timer) then
            self.active_timer = timer_start(0, self.blink_delay, self.switch_visibility)
        else
            if(active_timer) then
                timer_stop(self.active_timer)
                self.is_visible = false
                self:visible(self.is_visible)
            end
        end ]]
    end
}

function Annunciator:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end
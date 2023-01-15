StripGauge = {
    x=0, y=0,
    digital = nil,
    canvas = nil,
    strip_length = 204-9, -- pixels
    strip_min = 0,
    strip_yellow_bottom = 0,
    strip_yellow_top = 0,
    strip_max = 9999,
    indicator = nil,
    indicator_w = 19, -- pixels
    indicator_h = 13, -- pixels

    draw_strip = function(self, canvas) -- draw horizontal strip gauges
        canvas_draw(canvas, function()
         right_x = self.strip_length
         thickness = 5 -- pixels
    
         -- draw green line
         _move_to(0, 11) -- starting point
         _line_to(self.strip_length,11)
         _stroke(green_hex, thickness)
         
         if(self.strip_yellow_bottom ~= 0) then 
            yellow_x = self.strip_yellow_bottom
            _move_to(0, 11) -- starting point
            _line_to(yellow_x,11)
            _stroke(yellow_hex, thickness)
         end
         
         -- top yellow portion
         if(self.strip_yellow_top ~= 0) then
            yellow_x = self.strip_yellow_top
            _move_to(yellow_x,11) -- reset cursor
            _line_to(self.strip_length,11)
            _stroke(yellow_hex, thickness)
         end
        end)
    end,

    init = function (self, x, y, label, unit)
        self.digital = DigitalGauge:new()
        self.x = x
        self.y = y
        self.digital:init(x+9, y+12, label, unit)
        self.canvas = canvas_add(x+9, y, self.strip_length + 2, 20)
        self:draw_strip(self.canvas)
        self.indicator = img_add("strip_indicator.png", x, y, self.indicator_w, self.indicator_h)
    end,

    update = function (self, value)
        self.digital:update(value)
        value_capped = var_cap(value, self.strip_min, self.strip_max)
        value_percent = (value_capped - self.strip_min) / (self.strip_max - self.strip_min)
        value_percent = var_cap(value_percent,0,1) 
        x = self.x + (self.strip_length * value_percent)
        move(self.indicator, x, self.y, self.indicator_w, self.indicator_h)
    end,

    visible = function (self, is_visible)
        self.digital:visible(is_visible)
        visible(self.indicator, is_visible)
        visible(self.canvas, is_visible)
    end,

    set_decimals = function (self, decimals)
        self.digital:set_decimals(decimals)
    end,

    set_minmax = function (self, min, max)
        self.strip_min = min
        self.strip_max = max
    end
}

function StripGauge:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end
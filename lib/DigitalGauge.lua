DigitalGauge = { 
    x=0,  y=0, -- top left corner
    decimals=1, -- rounding user for 
    lbl = nil,
    lbl_width = 70,
    value_txt = nil,
    units = nil,
    init = function (self, x, y, label, unit)
        self.x = x
        self.y = y
        lbl_x_offset = self.lbl_width + 5
        self.lbl = txt_add(label, label_txtstyle, x, y+7, self.lbl_width, 20)
        self.value_txt = txt_add("9999", green_txtstyle, x + lbl_x_offset, y, 85, 26)
        self.units = txt_add(unit, units_txtstyle, x + lbl_x_offset + 90, y+12, 30, 14)
        end,
    update = function (self, number)
        txt_set(self.value_txt, var_format(number, self.decimals))
        end,
    set_decimals = function (self, decimals)
        self.decimals = decimals
        end,
    visible = function (self, is_visible)
        visible(self.lbl, is_visible)
        visible(self.value_txt, is_visible)
        visible(self.units, is_visible)
    end
}

function DigitalGauge:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

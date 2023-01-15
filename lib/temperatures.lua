-- TODO temp_units_property = user_prop_add_enum("Temperature Units", "C,F", "C", "Choose which temperature units to use (C = Celsius, F = Fahrenheit).")

local cht_bar_min = 100 -- celsius
local cht_bar_yellow = 230 -- celsius
local cht_bar_max = 300 -- celsius
local egt_bar_min = 100 -- celsius
local egt_bar_max = 900 -- celsius
local egt_peak = 0 -- temperature_unit

local operation_txt = nil
local mode_txt = nil

local bar_elements_group = nil
local egt_bar_lbl = nil
local cht_bar_lbl = nil
local bar_canvas = nil
local bar_canvas_w = 200

local egt_digital_gauge = nil
local cht_digital_gauge = nil

function convertRankineToCelsius(temp_r)
    return ((temp_r - 491.67) * 5 / 9)
end

-- function convertRankineToFahrenheit(temp_r)
--     return (temp_r − 459.67)
-- end

-- function convertCelsiusToFahrenheit(temp_c)
--     return (temp_c * 9/5 + 32)
-- end

function update_bar_chart(egtCelsius, chtCelsius)
    egt_percent = (egtCelsius - egt_bar_min) / (egt_bar_max - egt_bar_min)
    egt_percent = var_cap(egt_percent, 0, 1)
    egt_x = egt_percent * bar_canvas_w

    egt_peak_percent = (egt_peak - egt_bar_min) / (egt_bar_max - egt_bar_min)
    egt_peak_percent = var_cap(egt_peak_percent, 0, 1)
    egt_peak_x = egt_peak_percent * bar_canvas_w

    cht_percent = (chtCelsius - cht_bar_min) / (cht_bar_max - cht_bar_min)
    cht_percent = var_cap(cht_percent, 0, 1)
    cht_x = cht_percent * bar_canvas_w / 2

    canvas_draw(bar_canvas, function () 
        _move_to(0,12)
        _line_to(egt_x, 12)
        _stroke(blue_hex, 24)
        -- EGT peak
        _move_to(egt_peak_x, 0)
        _line_to(egt_peak_x, 26)
        _stroke("white", 1)

        _move_to(0,72)
        _line_to(cht_x, 72)
        _stroke(green_hex, 18)
        -- CHT limit
        _move_to(bar_canvas_w / 2 - 5, 49)
        _line_to(bar_canvas_w / 2, 49)
        _stroke(red_hex, 1)
        _move_to(bar_canvas_w / 2, 49)
        _line_to(bar_canvas_w / 2, 81)
        _stroke(red_hex, 1)
    end)
end

function update_temperatures_fsx(egtRankine, genericEGT_rankine, chtCelsius)
    if(egtRankine > 0) then
        egtCelsius = convertRankineToCelsius(egtRankine)
    else
        egtCelsius = convertRankineToCelsius(genericEGT_rankine)
    end
    if(egtCelsius > egt_peak) then
        egt_peak = egtCelsius
    end
    
    egt_digital_gauge:update(egtCelsius)
    cht_digital_gauge:update(chtCelsius)

    update_bar_chart(egtCelsius, chtCelsius)

    local peak_diff = egtCelsius - egt_peak
    local peak_diff_txt = "PK " .. var_format(peak_diff, 0)
    txt_set(mode_txt, peak_diff_txt)
end

function bar_chart_init()
    operation_txt = txt_add("LEAN-LOP", label_txtstyle, 50, 188, 95, 25)
    mode_txt = txt_add("PK -42", white_txtstyle, 145, 188, 100, 25)

    egt_bar_lbl = txt_add("EGT", white_txtstyle, 38, 237, 35, 25)
    cht_bar_lbl = txt_add("CHT", white_txtstyle, 38, 296, 35, 25)
    bar_canvas = canvas_add(50, 260, bar_canvas_w, 90)

    bar_elements_group = group_add(operation_txt, mode_txt, egt_bar_lbl, cht_bar_lbl, bar_canvas)
end

function digital_init()
    egt_digital_gauge = DigitalGauge:new()
    egt_digital_gauge.lbl_width = 60
    egt_digital_gauge.decimals = 0
    egt_digital_gauge:init(80, 370, "EGT:", "*C")

    cht_digital_gauge = DigitalGauge:new()
    cht_digital_gauge.lbl_width = 60
    cht_digital_gauge:init(270, 370, "CHT:", "*C")
end

function temps_init(engine)
    bar_chart_init()
    digital_init()
    
    if(engine == "1") then
        fsx_variable_subscribe("ENG EXHAUST GAS TEMPERATURE:1", "Rankine",
                            "GENERAL ENG EXHAUST GAS TEMPERATURE:1", "Rankine",
                            "RECIP ENG CYLINDER HEAD TEMPERATURE:1", "Celsius",update_temperatures_fsx)    
    elseif(engine == "2") then
        fsx_variable_subscribe("ENG EXHAUST GAS TEMPERATURE:2", "Rankine",
                            "GENERAL ENG EXHAUST GAS TEMPERATURE:2", "Rankine",
                            "RECIP ENG CYLINDER HEAD TEMPERATURE:2", "Celsius",update_temperatures_fsx)
    else
        print("Error: unknown engine")
    end
end

function temps_visible(is_visible)
    visible(bar_elements_group, is_visible)

    egt_digital_gauge:visible(is_visible)
    cht_digital_gauge:visible(is_visible)
end
local rpm_min = 500
local rpm_yellow = 2600
local rpm_red = 2800
local rpm_max = 3500
local rpm_range = rpm_max - rpm_min

local rpm_lbl = nil
local rpm_txt = nil
local rpm_indicator = nil

local mp_min = 10
local mp_yellow = 51
local mp_red = 61
local mp_max = 62
local mp_range = mp_max - mp_min

local mp_units_lbl = nil
local mp_lbl = nil
local mp_txt = nil
local mp_indicator = nil

local arc_canvas = nil
local arc_start_angle = 204
local arc_end_angle = 336
local arc_deg = arc_end_angle - arc_start_angle

function rotate_mp_indicator(map)
    map = var_cap(map, mp_min, mp_max)
    offset = map - mp_min
    rotation = arc_deg * offset / mp_range
    rotate(mp_indicator, rotation)
end

function rotate_rpm_indicator(rpm)
    rpm = var_cap(rpm, rpm_min, rpm_max)
    offset = rpm - rpm_min
    rotation = arc_deg * offset / rpm_range
    rotate(rpm_indicator, rotation)
end

function engine_system_fsx(map,rpm)
    map_rnd = var_format(map, 1)
    txt_set(mp_txt, map_rnd)
    rotate_mp_indicator(map)

    rpm_rnd = var_format(rpm, 0)
    txt_set(rpm_txt, rpm_rnd)
    rotate_rpm_indicator(rpm)
end

function arc_gauges_init(engine)
    arc_canvas = canvas_add(33,67,444,217)
    canvas_draw(arc_canvas, function() -- draw arcs for MP and RPM indication
        arc_yellow_angle_mp = (mp_yellow - mp_min)/mp_range * arc_deg + arc_start_angle
        arc_red_angle_mp = (mp_red - mp_min)/mp_range * arc_deg + arc_start_angle
        _arc(123, 114, arc_start_angle, arc_yellow_angle_mp-1, 97)
        _stroke(green_hex, 6)
        _arc(123, 114, arc_yellow_angle_mp, arc_red_angle_mp-1, 97)
        _stroke(yellow_hex, 6)
        _arc(123, 114, arc_red_angle_mp, arc_end_angle, 97)
        _stroke(red_hex, 6)
    
        arc_yellow_angle_rpm = (rpm_yellow - rpm_min)/rpm_range * arc_deg + arc_start_angle
        arc_red_angle_rpm = (rpm_red - rpm_min)/rpm_range * arc_deg + arc_start_angle
        _arc(320, 114, arc_start_angle, arc_yellow_angle_rpm-1, 97)
        _stroke(green_hex, 6)
        _arc(320, 114, arc_yellow_angle_rpm, arc_red_angle_rpm-1, 97)
        _stroke(yellow_hex, 6)
        _arc(320, 114, arc_red_angle_rpm, arc_end_angle, 97)
        _stroke(red_hex, 6)
    end)
    
    mp_units_lbl = txt_add("inHG", units_txtstyle, 215,161,30,12)
    mp_lbl = txt_add("MP", label_txtstyle, 137,108,31,19)
    mp_txt = txt_add("23.8", large_txtstyle, 85,132,126,45)
    mp_indicator = img_add("main_needle.png",56,78,200,200)
    
    rpm_lbl = txt_add("RPM", label_txtstyle, 334,108,44,19)
    rpm_txt = txt_add("2410", large_txtstyle, 280,132,126,45)
    rpm_indicator = img_add("main_needle.png",253,78,200,200)

    if(engine == "1") then
        fsx_variable_subscribe("RECIP ENG MANIFOLD PRESSURE:1", "inHg",
        "PROP RPM:1", "RPM",engine_system_fsx)
    elseif(engine == "2") then
        fsx_variable_subscribe("RECIP ENG MANIFOLD PRESSURE:2", "inHg",
                           "PROP RPM:2", "RPM",engine_system_fsx)
    else
        print("Error: unknown engine")
    end
end

function arc_gauges_visible(is_visible)
    visible(rpm_lbl, is_visible)
    visible(rpm_txt, is_visible)
    visible(rpm_indicator, is_visible)

    visible(mp_units_lbl, is_visible)
    visible(mp_lbl, is_visible)
    visible(mp_txt, is_visible)
    visible(mp_indicator, is_visible)

    visible(arc_canvas, is_visible)
end
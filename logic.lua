--------------------------------------------------
--            CGR-30P Engine Monitor            --
-- Thijmen de Gooijer                           --
--                                              --
-- Limitations: supports max two engines        --
-- like the real CGR-30P (twin package)         --
--                                              --
-- Flying lean-of-peak video:                   --
-- https://www.youtube.com/watch?v=h3bATVXMHQg  --
--------------------------------------------------

eng_selector_property = user_prop_add_enum("Engine", "1,2", "1", "Select which engine the instrument should connect to (1 = Left/Single, 2 = Right).")
power_gauge_property = user_prop_add_enum("Power gauge", "HP,BMEP", "BMEP", "Select whether to show the generic engine power calculation in Horse Power (HP), or \
    the BMEP for the P&W R2800 engines.")

bg_img = img_add_fullscreen("CGR-30P-background.png")

red_hex = "#EA0000FF"
green_hex = "#00FD00FF"
blue_hex = "#00F0F1FF"
yellow_hex = "yellow" -- "#FFFF01FF"

units_txtstyle = "font:roboto_bold.ttf; size:12; color: white; halign:left;"
label_txtstyle = "font:roboto_bold.ttf; size:18; color: white; halign:left;"
large_txtstyle = "font:roboto_bold.ttf; size:44; color: #00FD00; halign:right;"

green_txtstyle = "font:roboto_bold.ttf; size:26; color: #00FD00; halign:right;"
blue_txtstyle = "font:roboto_bold.ttf; size:26; color: #00F0F1; halign:right;"
white_txtstyle = "font:roboto_regular.ttf; size:18; color: white; halign:right;"

annunciator_txtstyle = "font:roboto_regular.ttf; size:15; color: black; halign:center;"

mainscreen_canvas = canvas_add(33,184,444,218) --478 --402
-- draw basic grid
canvas_draw(mainscreen_canvas, function()
    _move_to(0, 2)
    _line_to(444, 2)
    _stroke("white", 2)
    _move_to(222,2)
    _line_to(222,218)
    _stroke("white", 2)
    _move_to(23,183)
    _line_to(426,183)
    _stroke("white", 2)
end)

function system_visible(is_visible)
    arc_gauges_visible(is_visible)
    temps_visible(is_visible)
    strip_gauges_visible(is_visible)
    visible(mainscreen_canvas, is_visible)
    visible(bg_img, true)
end

function system_state_fsx(avionics_on,battery_on)
    systems_on = avionics_on and battery_on
    system_visible(systems_on)
end

fsx_variable_subscribe("AVIONICS MASTER SWITCH", "Bool",
        "ELECTRICAL MASTER BATTERY", "Bool",system_state_fsx)

engine = user_prop_get(eng_selector_property)
power_gauge = user_prop_get(power_gauge_property)
temps_init(engine)
strip_gauges_init(engine, power_gauge)
arc_gauges_init(engine)

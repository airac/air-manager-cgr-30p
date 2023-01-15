power_min_property = user_prop_add_integer("Power strip min (HP)", 0, 500, 0, "Left most value for the power strip gauge.") 
power_max_property = user_prop_add_integer("Power strip max (HP)", 5, 9999, 2500, "Right most value for the power strip gauge.") 
local power_strip = nil

function calculate_power(torque_ftlbs, rpm)
    -- https://en.wikipedia.org/wiki/Torque
    return (torque_ftlbs * 2 * 3.141592 * rpm) / 33000
end

function update_strip_powerHP(torque_ftlbs,rpm)
    power_hp = calculate_power(torque_ftlbs, rpm)
    power_strip:update(power_hp)
end

function init_strip_powerHP(engine, x, y)
    power_min = user_prop_get(power_min_property)
    power_max = user_prop_get(power_max_property)
    power_strip = StripGauge:new()
    -- based on engine ratings for the metropolitan in https://www.thisdayinaviation.com/tag/convair-440-metropolitan/
    -- 1800 HP nominal power, 2500 HP take-off power
    power_strip.strip_yellow_top = 1800 / 2500 * power_strip.strip_length
    power_strip:init(x, y, "POWER", "HP")
    power_strip:set_decimals(0)
    power_strip:set_minmax(power_min, power_max)

    if(engine == "1") then
        fsx_variable_subscribe("ENG TORQUE:1", "Foot pounds",
                            "PROP RPM:1", "Rpm",
                            update_strip_powerHP)    
    elseif(engine == "2") then
        fsx_variable_subscribe("ENG TORQUE:2", "Foot pounds",
                            "PROP RPM:2", "Rpm",
                            update_strip_powerHP)
    else
        print("Error: unknown engine")
    end
end

function strip_powerHP_visible(is_visible)
    power_strip:visible(is_visible)
end
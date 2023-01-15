--[[ 

BMEP research:
https://en.wikipedia.org/wiki/Mean_effective_pressure
http://calclassic.proboards.com/thread/418/calculate-bmep
http://www.epi-eng.com/piston_engine_technology/bmep_performance_yardstick.htm
]]


bmep_min_property = user_prop_add_integer("Power strip min (BMEP PSI)", 0, 500, 60, "Left most value for the power strip gauge.") 
bmep_max_property = user_prop_add_integer("Power strip max (BMEP PSI)", 5, 9999, 260, "Right most value for the power strip gauge.") 
local power_strip = nil

function update_strip_powerBMEP(brakepwr,rpm)
    L0 = brakepwr / 550 -- Brake Power in HP
    L0 = L0 * 283
    L0 = L0 / rpm       -- BMEP In Lbs-Sq In
    power_bmep = L0     -- Send BMEP Value to Label
    power_strip:update(power_bmep)
end

function init_strip_powerBMEP(engine, x, y)
    power_min = user_prop_get(bmep_min_property)
    power_max = user_prop_get(bmep_max_property)
    power_strip = StripGauge:new()
    -- based on engine ratings for the metropolitan in https://www.thisdayinaviation.com/tag/convair-440-metropolitan/
    -- 1800 HP nominal power, 2500 HP take-off power
    power_strip.strip_yellow_top = 1800 / 2500 * power_strip.strip_length
    power_strip:init(x, y, "BMEP", "PSI")
    power_strip:set_decimals(0)
    power_strip:set_minmax(power_min, power_max)

    if(engine == "1") then
        fsx_variable_subscribe("RECIP ENG BRAKE POWER:1", "Foot pounds",
                            "PROP RPM:1", "Rpm",
                            update_strip_powerBMEP)    
    elseif(engine == "2") then
        fsx_variable_subscribe("RECIP ENG BRAKE POWER:2", "Foot pounds",
                            "PROP RPM:2", "Rpm",
                            update_strip_powerBMEP)
    else
        print("Error: unknown engine")
    end
end

function strip_powerBMEP_visible(is_visible)
    power_strip:visible(is_visible)
end
local right_column_strip_x = 261 -- pixels
local top_strip_y = 196 -- pixels
local middle_strip_y = 248 -- pixels
local lower_strip_y = 300 -- pixels

local power_indicator_y = top_strip_y
local fuelflow_indicator_y = middle_strip_y
local fuel_level_indicator_y = lower_strip_y

local powergaugetype = nil
local fuel_annunciator = nil

fuelflow_min_property = user_prop_add_integer("Fuelflow strip min (KG/H)", 0, 500, 100, "Left most value for the fuel flow strip gauge.") 
fuelflow_max_property = user_prop_add_integer("Fuelflow strip max (KG/H)", 1, 5000, 1000, "Right most value for the fuel flow strip gauge.") 
local fuelflow_strip = nil

local fuel_level_max = nil -- not a user property, FS X can tell us the max fuel quantity.
local fuel_level_strip = nil


function update_strip_gauges_fsx(fuelflow, fuel_levelremaining_gallons, poundsPerGallon, fuel_capacity_gallons)
    fuelflowKilogram = fuelflow / 2.2046 -- gauge label is kg/h 
    fuelflow_strip:update(fuelflowKilogram)

    fuel_capacity_kg = fuel_capacity_gallons * poundsPerGallon / 2.2046
    fuel_level_strip:set_minmax(0, fuel_capacity_kg)
    fuel_level_kg = fuel_levelremaining_gallons * poundsPerGallon / 2.2046
    fuel_level_strip:update(fuel_level_kg)

    if(fuel_level_kg < 0.75 * fuelflowKilogram) then -- less than 45 min fuel
        fuel_annunciator:active(true)
    else
        fuel_annunciator:active(false)
    end
end

function strip_gauges_init(engine, powergauge)
    powergaugetype = powergauge
    if(powergaugetype == 'BMEP') then
        init_strip_powerBMEP(engine, right_column_strip_x, power_indicator_y)
    else
        init_strip_powerHP(engine, right_column_strip_x, power_indicator_y)
    end
    fuelflow_min = user_prop_get(fuelflow_min_property)
    fuelflow_max = user_prop_get(fuelflow_max_property)
    fuelflow_strip = StripGauge:new()
    fuelflow_strip:init(right_column_strip_x, fuelflow_indicator_y, "F FLOW", "KG/H")
    fuelflow_strip:set_minmax(fuelflow_min, fuelflow_max)

    fuel_level_strip = StripGauge:new()
    fuel_level_strip.strip_yellow_bottom = 23
    fuel_level_strip:init(right_column_strip_x, fuel_level_indicator_y, "F REM", "KG")
    fuel_level_strip:set_decimals(0)
    
    fuel_annunciator = Annunciator:new()
    fuel_annunciator:init((512-fuel_annunciator.width)/2, 72, "FUEL", 'ghostwhite')

    if(engine == "1") then
        fsx_variable_subscribe("RECIP ENG FUEL FLOW:1", "Pounds per hour",
                            "FUEL TOTAL QUANTITY", "Gallons",
                            "FUEL WEIGHT PER GALLON", "Pounds",
                            "FUEL TOTAL CAPACITY", "Gallons",update_strip_gauges_fsx)    
    elseif(engine == "2") then
        fsx_variable_subscribe("RECIP ENG FUEL FLOW:2", "Pounds per hour",
                            "FUEL TOTAL QUANTITY", "Gallons",
                            "FUEL WEIGHT PER GALLON", "Pounds",
                            "FUEL TOTAL CAPACITY", "Gallons",update_strip_gauges_fsx)
    else
        print("Error: unknown engine")
    end
end

function strip_gauges_visible(is_visible)
    if(powergaugetype == 'BMEP') then
        strip_powerBMEP_visible(is_visible)
    else
        strip_powerHP_visible(is_visible)
    end
    fuelflow_strip:visible(is_visible)
    fuel_level_strip:visible(is_visible)
end
    
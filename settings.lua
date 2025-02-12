
local thicknesses = {
  "factorio-like-belt-indicator",
  "factorio-like-pipe-indicator",
  "double-thick-line",
  "double-thin-line",
  "extra-thick-line",
  "thick-line",
  "thin-line"
}

local colors = {
  "white",
  "red",
  "blue",
  "green",
  "yellow",
  "magenta",
  "cyan"
}

data:extend({
  {
    type = "string-setting",
    name = "underground-indicators-belt-thickness",
    setting_type = "runtime-global",
    default_value = "factorio-like-belt-indicator",
    allow_blank = false,
    allowed_values = thicknesses,
    order = "underground-indicators-aa",
  },
  {
    type = "string-setting",
    name = "underground-indicators-pipe-thickness",
    setting_type = "runtime-global",
    default_value = "factorio-like-pipe-indicator",
    allow_blank = false,
    allowed_values = thicknesses,
    order = "underground-indicators-ab",
  },
  {
    type = "int-setting",
    name = "underground-indicators-range",
    setting_type = "runtime-global",
    default_value = 40,
    maximum_value = 250,
    minimum_value = 1,
    order = "underground-indicators-b",
  },
  {
    type = "string-setting",
    name = "underground-indicators-color-normal",
    setting_type = "runtime-global",
    default_value = "white",
    allow_blank = false,
    allowed_values = colors,
    order = "underground-indicators-c",
  },
  {
    type = "string-setting",
    name = "underground-indicators-color-blocked",
    setting_type = "runtime-global",
    default_value = "red",
    allow_blank = false,
    allowed_values = colors,
    order = "underground-indicators-d",
  },
  {
    type = "string-setting",
    name = "underground-indicators-color-replaceable",
    setting_type = "runtime-global",
    default_value = "yellow",
    allow_blank = false,
    allowed_values = colors,
    order = "underground-indicators-e",
  },
  {
    type = "bool-setting",
    name = "underground-indicators-placement-indicator",
    setting_type = "startup",
    default_value = true,
    order = "underground-indicators-a",
  },
  {
    type = "string-setting",
    name = "underground-indicators-placement-belt",
    setting_type = "startup",
    default_value = "factorio-like-belt-indicator",
    allow_blank = false,
    allowed_values = thicknesses,
    order = "underground-indicators-b",
  },
  {
    type = "string-setting",
    name = "underground-indicators-placement-pipe",
    setting_type = "startup",
    default_value = "factorio-like-pipe-indicator",
    allow_blank = false,
    allowed_values = thicknesses,
    order = "underground-indicators-c",
  },
  {
    type = "string-setting",
    name = "underground-indicators-placement-color",
    setting_type = "startup",
    default_value = "white",
    allow_blank = false,
    allowed_values = colors,
    order = "underground-indicators-d",
  }
})
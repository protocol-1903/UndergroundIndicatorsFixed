
local thicknesses = {
  "double-thick",
  "double-thin",
  "extra-thick",
  "thick",
  "thin"
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
    default_value = "thick",
    allow_blank = false,
    allowed_values = thicknesses,
    order = "underground-indicators-aa",
  },
  {
    type = "string-setting",
    name = "underground-indicators-pipe-thickness",
    setting_type = "runtime-global",
    default_value = "double-thin",
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
  }
})
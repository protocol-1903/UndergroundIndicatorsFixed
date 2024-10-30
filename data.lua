local function makeParticle(name, graphic, rect)
  data:extend({{
    type = 'corpse',
    name = 'underground-indicators-' .. name,
    flags = {'not-on-map', 'placeable-off-grid', 'not-deconstructable', 'not-blueprintable'},
    selectable_in_game = false,
    time_before_shading_off = 1.4 * 60,
    time_before_removed = (2 + (rect and 0.5 or 0)) * 60,
    final_render_layer = 'object',
    --bending_type = 'straight',
    animation = {{
      filename = '__UndergroundIndicatorsFixed__/graphics/' .. graphic .. '.png',
      priority = 'extra-high',
      width = 32,
      height = 64,
      direction_count = 1,
      flags = {"smoke"},
      frame_count = 1,
      animation_speed = 1,
      scale = 1.0,
      render_layer = 'object'
    }}
  }})
end

local function makeColoredParticles(color, thickness)
  makeParticle('dash-' .. color .. '-' .. thickness, thickness .. '/' .. 'dash_' .. color, false)
  makeParticle('dash-' .. color .. '-' .. thickness .. '-vertical', thickness .. '/' .. 'dash_' .. color .. '_vertical', false)
  makeParticle('rect-' .. color .. '-' .. thickness, thickness .. '/' .. 'rect_' .. color, true)
end

local thicknesses = {
  'double-thick',
  'double-thin',
  'extra-thick',
  'thick',
  'thin'
}

local colors = {
  'white',
  'red',
  'green',
  'blue',
  'yellow',
  'magenta',
  'cyan'
}

for _, color in pairs(colors) do
  for _, thickness in pairs(thicknesses) do
    makeColoredParticles(color, thickness)
  end
end

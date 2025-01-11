local function makeParticle(color, thickness, rgb, rect)
end

local thicknesses = {
  "double-thick",
  "double-thin",
  "extra-thick",
  "thick",
  "thin"
}

local colors = {
  ["white"] = {1.0, 1.0, 1.0},
  ["red"] = {1.0, 0.0, 0.0},
  ["green"] = {0.0, 1.0, 0.0},
  ["blue"] = {0.0, 0.0, 1.0},
  ["yellow"] = {1.0, 1.0, 0.0},
  ["magenta"] = {1.0, 0.0, 1.0},
  ["cyan"] = {0.0, 1.0, 1.0}
}

for color, rgb in pairs(colors) do
  for _, thickness in pairs(thicknesses) do
    data:extend({
      {
        type = "corpse",
        name = "underground-indicators-dash-" .. color .. "-" .. thickness,
        flags = {"not-on-map", "placeable-off-grid", "not-deconstructable", "not-blueprintable"},
        selectable_in_game = false,
        time_before_shading_off = 1.6 * 60,
        time_before_removed = (2 + (rect and 0.5 or 0)) * 60,
        final_render_layer = "air-object",
        hidden_in_factoriopedia = true,
        animation = {{
          filename = "__UndergroundIndicatorsFixed__/graphics/" .. thickness .. "-dash.png",
          priority = "extra-high",
          width = 32,
          height = 32,
          direction_count = 4,
          line_length = 4,
          -- axially_symmetrical = true,
          -- flags = {"smoke"},
          frame_count = 1,
          -- animation_speed = 1,
          -- scale = 1.0,
          -- shift = { 0, 0.5 },
          -- render_layer = "object",
          tint = rgb
        }}
      },
      {
        type = "corpse",
        name = "underground-indicators-rect-" .. color .. "-" .. thickness,
        flags = {"not-on-map", "placeable-off-grid", "not-deconstructable", "not-blueprintable"},
        selectable_in_game = false,
        time_before_shading_off = 1.6 * 60,
        time_before_removed = (2 + (rect and 0.5 or 0)) * 60,
        final_render_layer = "air-object",
        hidden_in_factoriopedia = true,
        animation = {{
          filename = "__UndergroundIndicatorsFixed__/graphics/" .. thickness .. "-rect.png",
          priority = "extra-high",
          width = 32,
          height = 32,
          -- flags = {"smoke"},
          frame_count = 1,
          -- animation_speed = 1,
          -- scale = 1.0,
          -- shift = { 0, 0.5 },
          -- render_layer = "object",
          tint = rgb
        }}
      }
    })
  end
end

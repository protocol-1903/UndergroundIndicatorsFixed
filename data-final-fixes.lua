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
        time_before_shading_off = 96,
        time_before_removed = 120,
        animation_render_layer = "air-object",
        hidden_in_factoriopedia = true,
        animation = {{
          filename = "__UndergroundIndicatorsFixed__/graphics/" .. thickness .. "-dash.png",
          width = 64,
          height = 64,
          direction_count = 4,
          line_length = 4,
          frame_count = 1,
          scale = 0.5,
          tint = rgb,
          
        }}
      },
      {
        type = "corpse",
        name = "underground-indicators-rect-" .. color .. "-" .. thickness,
        flags = {"not-on-map", "placeable-off-grid", "not-deconstructable", "not-blueprintable"},
        selectable_in_game = false,
        time_before_shading_off = 96,
        time_before_removed = 150,
        final_render_layer = "air-object",
        hidden_in_factoriopedia = true,
        animation = {{
          filename = "__UndergroundIndicatorsFixed__/graphics/" .. thickness .. "-rect.png",
          width = 64,
          height = 64,
          frame_count = 1,
          scale = 0.5,
          tint = rgb
        }}
      }
    })
  end
end

if settings.startup["underground-indicators-placement-indicator"] then
  for u, underground in pairs(data.raw["underground-belt"]) do
    underground.radius_visualisation_specification = {
      sprite =  {
        filename = "__UndergroundIndicatorsFixed__/graphics/" .. settings.startup["underground-indicators-placement-belt"].value .. "-rect.png",
        size = 64,
        scale = 1,
        tint = colors[settings.startup["underground-indicators-placement-color"].value]
      },
      distance = 0.5,
      offset = {0, -underground.max_distance},
      draw_on_selection = false
    }
  end

  for u, underground in pairs(data.raw["pipe-to-ground"]) do
    if #underground.fluid_box.pipe_connections > 1 and underground.fluid_box.pipe_connections[2].max_underground_distance then
      underground.radius_visualisation_specification = {
        sprite =  {
          filename = "__UndergroundIndicatorsFixed__/graphics/" .. settings.startup["underground-indicators-placement-pipe"].value .. "-rect.png",
          size = 64,
          scale = 1,
          tint = colors[settings.startup["underground-indicators-placement-color"].value]
        },
        distance = 0.5,
        offset = {0, underground.fluid_box.pipe_connections[2].max_underground_distance},
        draw_on_selection = false
      }
    end
  end
end
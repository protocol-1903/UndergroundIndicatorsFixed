local function check_connections(entity)

  -- add to list if not already existing
  if not storage.viability[entity] then
    storage.viability[entity] = {
      checked = {
        [entity] = {allowed = true} -- it can obviously connect to itself
      }
    }
  end

  -- reruns every time the save loads, this is fine
  if not storage.viability[entity].connection_categories then
    storage.viability[entity].connection_categories = {}
    for _, connection in pairs(prototypes.entity[entity].fluidbox_prototypes[1].pipe_connections) do
      if connection.connection_type == "underground" then
        if type(connection.connection_category) == "table" then
          for _, category in pairs(connection.connection_category) do
            storage.viability[entity].connection_categories[category] = true
          end
        else
          game.print(connection.connection_category)
          storage.viability[entity].connection_categories[connection.connection_category or "default"] = true
        end
      end
    end
  end
end

-- done i think
local function render_tracker(surface, position, name, force, direction, type, cap)

  occupied = not surface.can_place_entity({
    name = name,
    position = position,
    force = force,
  })
  replaceable = surface.can_fast_replace({
    name = name,
    position = position,
    direction = (direction + 8) % 16, -- reverse direction
    force = force,
  })

  thickness = type == "underground-belt" and settings.global["underground-indicators-belt-thickness"].value or settings.global["underground-indicators-pipe-thickness"].value
  color = occupied and replaceable and settings.global["underground-indicators-color-replaceable"].value or
      occupied and settings.global["underground-indicators-color-blocked"].value or
      settings.global["underground-indicators-color-normal"].value

  surface.create_entity({
    name = "underground-indicators-" .. (cap and "rect-" or "dash-") .. color .. "-" .. thickness,
    position = {
      x = position[1],
      y = position[2]
    },
    direction = direction
  })
end

-- done i think
local function render_for_player(player, new_scan)

  -- if they are not holding any item, return
  if player.is_cursor_empty() then return end

  -- get the item stack of whatever they are holding
  stack = player.cursor_ghost or player.cursor_stack

  if not stack.name then return end

  -- get the prototype, which is "name" for cursor_ghost for whatever reason
  stack = prototypes.item[player.cursor_ghost and stack.name.name or stack.name]

  -- if the item they are holding is not an underground belt or a pipe-to-ground, return
  place_result = stack.place_result
  if (not place_result)
  or (place_result.type ~= "pipe-to-ground"
  and place_result.type ~= "underground-belt") then
    return
  end

  -- fetch all entities in a square range around the player that are related to the held item stack
  dist = settings.global["underground-indicators-range"].value
  position = player.position
  entities = place_result.type == "underground-belt" and player.surface.find_entities_filtered({
    name = place_result.name,
    area = {
      {position.x - dist, position.y - dist},
      {position.x + dist, position.y + dist}
    }
  }) or player.surface.find_entities_filtered({
    type = place_result.type,
    area = {
      {position.x - dist, position.y - dist},
      {position.x + dist, position.y + dist}
    }
  })

  if place_result.type == "pipe-to-ground" then
    -- check stored data
    check_connections(place_result.name)
  end

  -- if new scan requested, then save entities to tracker storage
  if new_scan then
    -- iterate over each entity
    for _, entity in pairs(entities) do

      if entity.type == "pipe-to-ground" then
        -- check stored data
        check_connections(entity.name)

        -- if not checked against the current entity searching for
        if not storage.viability[place_result.name].checked[entity.name] then
          local allowed = false
          for category, _ in pairs(storage.viability[place_result.name].connection_categories) do
            if storage.viability[entity.name].connection_categories[category] then
              allowed = true
              break
            end
          end
          storage.viability[place_result.name].checked[entity.name] = {allowed = allowed}
          storage.viability[entity.name].checked[place_result.name] = {allowed = allowed}
        end
      end

      if entity.type == "pipe-to-ground" and storage.viability[place_result.name].checked[entity.name].allowed then
        -- pipe-to-ground with unknown connections
        -- side note, this doesn't work with other entities that have underground connections
        -- may need to fix eventually
  
        -- get each fluidbox
        for i=1, #entity.fluidbox do

          -- empty table for storing possible fluidbox trackers
          local trackers = {}

          for j, pipe_connection in pairs(entity.fluidbox.get_pipe_connections(1)) do
            -- must not have a connection and must be underground type
            if not pipe_connection.target and pipe_connection.connection_type == "underground" then

              if pipe_connection.position.x == pipe_connection.target_position.x then
                direction = pipe_connection.position.y < pipe_connection.target_position.y and 8 or 0
              else
                direction = pipe_connection.position.x < pipe_connection.target_position.x and 4 or 12
              end

              -- check if connection is udnerground and if it has no neighbour
              -- if true, add to tracker
              trackers[#trackers+1] = {
                direction = direction,
                offset = {0, 0},
                max_distance = entity.prototype.fluidbox_prototypes[i].pipe_connections[j].max_underground_distance
              }
            end
          end

          -- add tracker if table is non-empty exist
          if #trackers > 0 then
            storage.uif_trackers[entity.unit_number] = {
              trackers = trackers,
              entity = entity,
              last_scan = game.tick
            }
          end
        end
  
      elseif entity.neighbours == nil and entity.type == "underground-belt" then
        -- underground belt with no connection
  
        -- save a tracker
        storage.uif_trackers[entity.unit_number] = {
          trackers = {{
            direction = entity.direction,
            offset = {0, 0},
            max_distance = entity.prototype.max_underground_distance
          }},
          entity = entity,
          last_scan = game.tick
        }
      end
    end
  end
  
  -- which particle to render, only calculated once per player
  local index = math.floor(game.tick % 90 / 15) + 1

  for _, entity in pairs(entities) do

    local tracker = storage.uif_trackers[entity.unit_number]

    -- if traker exists, render it
    if tracker then
      -- render each subtracker
      for _, subtracker in pairs(tracker.trackers) do

        local reverse = ((entity.prototype.type == "underground-belt" and entity.belt_to_ground_type == "output") and -1 or 1) -- whether or not to render indicators in reverse (only used for underground belt outputs)

        -- direction unit vector relative to entity position
        dir = {
          subtracker.direction == 4 and 1 or subtracker.direction == 12 and -1 or 0,
          subtracker.direction == 0 and -1 or subtracker.direction == 8 and 1 or 0
        }
        -- position relative to entity position
        pos = {
          entity.position.x + subtracker.offset[1] + dir[1]*(reverse == 1 and 0 or -1)*subtracker.max_distance,
          entity.position.y + subtracker.offset[2] + dir[2]*(reverse == 1 and 0 or -1)*subtracker.max_distance
        }
        
        local start = reverse == 1 and 0 or -math.floor(subtracker.max_distance / 6)
        local finish = reverse == -1 and 0 or math.floor(subtracker.max_distance / 6)

        -- repeat every 6 tiles
        for i = 0, math.floor(subtracker.max_distance / 6) do
          -- do every time up until the last tile
          if 6*i+index < subtracker.max_distance then
            -- render offset by 6*i+index in the direction of the unit vector
            render_tracker(entity.surface, {pos[1] + dir[1]*(6*i+index), pos[2] + dir[2]*(6*i+index)}, entity.name, entity.force, subtracker.direction, entity.type, false)
          end
        end
      
        -- render offset by length in the direction of the unit vector
        render_tracker(entity.surface, {pos[1] + (reverse == 1 and dir[1]*subtracker.max_distance or 0), pos[2] + (reverse == 1 and dir[2]*subtracker.max_distance or 0)}, entity.name, entity.force, subtracker.direction, entity.type, true)

      end
    end
  end
end

--[[ Events ]]

script.on_init(function()
  storage.uif_trackers = {}
  storage.viability = {}
end)

script.on_configuration_changed(function()
  storage.viability = {}
end)

script.on_event(defines.events.on_tick, function(event)
  -- runs six times every second
  if event.tick % 15 == 0 then
    -- purge trackers that have existed for longer than 60 ticks
    for entityID, tracker in pairs(storage.uif_trackers) do
      if game.tick - tracker.last_scan > 120 then
        storage.uif_trackers[entityID] = nil
      end
    end

    -- render trackers
    for _, player in pairs(game.connected_players) do
      render_for_player(player, event.tick % 120 == 0)
    end
  end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  -- render everything around the player, and scan the area for new orphans
  render_for_player(game.players[event.player_index], true)
end)
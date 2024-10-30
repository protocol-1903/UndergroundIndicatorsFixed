local function getArea(entity)

  dist = entity.prototype.max_underground_distance
  pos = entity.position

  if entity.prototype.type == 'underground-belt' and entity.belt_to_ground_type == 'input' then
    if entity.direction == defines.direction.north then
      return {{x=pos.x, y=pos.y-dist}, {x=pos.x, y=pos.y}}, true
    elseif entity.direction == defines.direction.east then
      return {{x=pos.x, y=pos.y}, {x=pos.x+dist, y=pos.y}}, false
    elseif entity.direction == defines.direction.south then
      return {{x=pos.x, y=pos.y}, {x=pos.x, y=pos.y+dist}}, true
    elseif entity.direction == defines.direction.west then
      return {{x=pos.x-dist, y=pos.y}, {x=pos.x, y=pos.y}}, false
    end
  else
    if entity.direction == defines.direction.north then
      return {{x=pos.x, y=pos.y}, {x=pos.x, y=pos.y+dist}}, true
    elseif entity.direction == defines.direction.east then
      return {{x=pos.x-dist, y=pos.y}, {x=pos.x, y=pos.y}}, false
    elseif entity.direction == defines.direction.south then
      return {{x=pos.x, y=pos.y-dist}, {x=pos.x, y=pos.y}}, true
    elseif entity.direction == defines.direction.west then
      return {{x=pos.x, y=pos.y}, {x=pos.x+dist, y=pos.y}}, false
    end
  end
end

local function getDistance(posA, posB)
  return math.sqrt(math.pow(posA.x - posB.x, 2) + math.pow(posA.y - posB.y, 2))
end

local function sortTilesByDistance(tiles, origin)
  table.sort(tiles, function(a, b)
    distA = getDistance(a, origin)
    distB = getDistance(b, origin)
    return distA < distB
  end)
end

local function getPartner(entity)
  if entity.prototype.type == 'underground-belt' then
    return entity.neighbours
  elseif entity.prototype.type == 'pipe-to-ground' then
    dir = entity.direction
    pos = entity.position

    for _, neighbours in pairs(entity.neighbours) do
      for _, subneighbour in pairs(neighbours) do
        if subneighbour.name == entity.name then
          spos = subneighbour.position
          if (dir == 8 and spos.y < pos.y)
          or (dir == 4 and spos.x < pos.x)
          or (dir == 0 and spos.y > pos.y)
          or (dir == 12 and spos.x > pos.x) then
            return subneighbour
          end
        end
      end
    end
  end
end

local function getTracker(entity)
    return storage.trackers[entity.unit_number]
end

local function createTracker(entity)

  area, vertical = getArea(entity)

  start = area[1]
  stop = area[2]

  start.start = true
  stop.start = false

  vertexTiles = {
    {
      x = start.x,
      y = start.y,
      hide = false,
    },
    {
      x = stop.x,
      y = stop.y,
      hide = false,
    }
  }
  edgeTiles = {}

  for x = start.x, stop.x, 1 do
    for y = start.y, stop.y, 1 do
      if (not (x == start.x and y == start.y))
      and (not (x == stop.x and y == stop.y)) then
        table.insert(edgeTiles, {x = x, y = y})
      end
    end
  end

  sortTilesByDistance(vertexTiles, entity.position)
  vertexTiles[1].hide = true
  sortTilesByDistance(edgeTiles, entity.position)

  -- Create the tracker
  tracker = {
    entity = entity,
    area = area,
    vertexTiles = vertexTiles,
    edgeTiles = edgeTiles,
    vertical = vertical,
    index = 1,
    updated = game.tick,
  }

  -- Save it
  storage.trackers[entity.unit_number] = tracker

  return tracker
end

local function deleteTracker(entity)
  storage.trackers[entity.unit_number] = nil
end

local function renderParticle(surface, tile, name, force, vertical, vertex, type)

  occupied = not surface.can_place_entity({
    name = name,
    position = tile,
    force = force,
  })
  replaceable = surface.can_fast_replace({
    name = name,
    position = tile,
    direction = vertical and defines.direction.north or defines.direction.east,
    force = force,
  })

  thickness = type == "underground-belt" and settings.global['underground-indicators-belt-thickness'].value or settings.global['underground-indicators-pipe-thickness'].value
  color = settings.global['underground-indicators-color-normal'].value
  if occupied then
    color = settings.global['underground-indicators-color-blocked'].value
    if replaceable then
      color = settings.global['underground-indicators-color-replaceable'].value
    end
  end

  if color and string.len(color) > 0 then
    surface.create_entity({
      name = 'underground-indicators-' .. (vertex and 'rect' or 'dash') .. '-' .. color .. '-' .. thickness .. (((not vertex) and vertical) and '-vertical' or ''),
      position = {
        x = tile.x,
        y = tile.y + 0.5,
      }
    })
  end
end

local function renderTracker(tracker, tick)
  tiles = tracker.tiles
  index = tracker.index
  name = tracker.entity.prototype.name
  force = tracker.entity.force
  surface = tracker.entity.surface
  vertical = tracker.vertical

  -- Spawn the rectangles
  for _, tile in pairs(tracker.vertexTiles) do
    if not tile.hide then
      renderParticle(surface, tile, name, force, vertical, true, tracker.entity.type)
    end
  end

  -- Spawn the dashes
  for i, tile in pairs(tracker.edgeTiles) do
    if i % 8 == index then
      renderParticle(surface, tile, name, force, vertical, false, tracker.entity.type)
    end
  end

  -- Increase index by one
  index = index + 1
  if index >= 8 then
    index = 0
  end
  tracker.index = index

  -- Update the timestamp
  tracker.updated = tick
end

local function renderPlayer(player, scan)
  -- Get the item stack of whatever they are holding
  stack = player.cursor_stack

  -- If they are not holding any item, return
  if (not stack) or (not stack.valid_for_read) then return end

  -- If the item they are holding is not an underground
  -- belt or a pipe-to-ground, return
  placeResult = stack.prototype.place_result
  if (not placeResult)
  or (stack.prototype.place_result.type ~= 'pipe-to-ground'
  and stack.prototype.place_result.type ~= 'underground-belt') then
    return
  end

  -- Fetch all entities in a 50x50 range around the player
  -- that are related to the held item stack
  dist = settings.global['underground-indicators-range'].value
  position = player.position
  entities = player.surface.find_entities_filtered({
    name = placeResult.name,
    --type = stack.prototype.place_result.type,
    area = {
      {position.x - dist, position.y - dist},
      {position.x + dist, position.y + dist},
    },
  })

  -- Get current game tick
  tick = game.tick

  -- Iterate over each entity
  for _, entity in pairs(entities) do

    -- Retrieve their tracker
    tracker = storage.trackers[entity.unit_number]

    -- If they don't have one, check if they should.
    if (not tracker) and (getPartner(entity) == nil) then
      tracker = createTracker(entity)
    end

    if tracker then
      renderTracker(tracker, tick)
    end
  end
end

local function onEntitySpawn(entity)

  -- Find partner
  partner = getPartner(entity)

  -- Create a tracker only if this entity has no partner.
  if not partner then
    createTracker(entity)
    return
  end

  -- If it DOES have a partner however, we need to
  -- delete their tracker as it is no longer an orphan.
  deleteTracker(partner)
end

local function onEntityDestroy(entity)

  -- Delete tracker if exists and return
  if storage.trackers[entity.unit_number] then
    deleteTracker(entity)
    return
  end

  -- Find partner
  partner = getPartner(entity)

  if not partner or partner.type == "entity-ghost" then return end

  -- Create tracker for partner since they are now an orphan
  if partner then
    createTracker(partner)
  end
end

--[[ Events ]]

-- First run
script.on_init(function()
  storage.trackers = {}
end)

-- Every run
-- script.on_load(function()
--     -- Metatable fixing
-- end)

-- Config changed / mods changed
-- script.on_configuration_changed(function(event)
--   local changes = event.mod_changes['UndergroundIndicatorsFixed']
--   if changes and changes.old_version ~= changes.new_version then
--     for _, tracker in pairs(storage.trackers) do
--       tracker.vertical = (tracker.entity.direction == defines.direction.north
--         or tracker.entity.direction == defines.direction.south)
--     end
--   end

--   -- Update settings
--   -- Metatable fixing
-- end)

script.on_event(defines.events.on_tick, function(event)
  -- Run six times per second
  if event.tick % 10 == 0 then
    for id, player in pairs(game.connected_players) do
      renderPlayer(player, event.tick % 60 == 0)
    end
  end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)

  -- Render everything around the player, and scan the area for new orphans
  player = game.players[event.player_index]
  renderPlayer(player, true)

  -- Purge useless data
  tick = game.tick
  for entityID, tracker in pairs(storage.trackers) do
    if tick - tracker.updated > 10 then
      storage.trackers[entityID] = nil
    end
  end
end)

script.on_event(defines.events.on_built_entity, function(event) onEntitySpawn(event.entity) end, {{filter = "type", type = "underground_belt"}, {filter = "type", type = "pipe_to_ground"}})
script.on_event(defines.events.on_robot_built_entity, function(event) onEntitySpawn(event.entity) end, {{filter = "type", type = "underground_belt"}, {filter = "type", type = "pipe_to_ground"}})
script.on_event(defines.events.script_raised_built, function(event) onEntitySpawn(event.entity) end, {{filter = "type", type = "underground_belt"}, {filter = "type", type = "pipe_to_ground"}})
-- script.on_event(defines.events.on_trigger_created_entity, function(event) onEntitySpawn(event.entity) end)

script.on_event(defines.events.on_entity_died, function(event) onEntityDestroy(event.entity) end, {{filter = "type", type = "underground_belt"}, {filter = "type", type = "pipe_to_ground"}})
script.on_event(defines.events.on_player_mined_entity, function(event) onEntityDestroy(event.entity) end, {{filter = "type", type = "underground_belt"}, {filter = "type", type = "pipe_to_ground"}})
script.on_event(defines.events.on_robot_mined_entity, function(event) onEntityDestroy(event.entity) end, {{filter = "type", type = "underground_belt"}, {filter = "type", type = "pipe_to_ground"}})
script.on_event(defines.events.script_raised_destroy, function(event) onEntityDestroy(event.entity) end, {{filter = "type", type = "underground_belt"}, {filter = "type", type = "pipe_to_ground"}})
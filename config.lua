local config = {}

config.block_size = 48   -- responsible for zoom level
config.t_size     = 64   -- responsible for texture size

config.step_time = 0.03

config.audio_scale = 400

config.tiles = {
    TREE   = 0,
    GRASS  = 1,
    GRASS2 = 2,
    BLACK  = 3,
    STONE  = 4,
    PINE   = 5,
    HOUSE  = 6,
    TREE2  = 7,
}

config.world = {
    width        = 200,
    height       = 200,
    complexity   = 120,
    stones_min   = 50,
    stones_max   = 100,
    enemies_min  = 13,
    enemies_max  = 18,
    house_radius = 4,
}

config.speed = {
    default       = 6,
    enemy         = 6.0,
    happyend_girl = 4.0,
    happyend_hero = 2.0,
}

config.enemy = {
    trigger_distance = 25,  -- todo: must depend on screen resolution
    kill_distance    = 1,
}

config.color = {
    background = { 155, 155, 155 },
}

return config

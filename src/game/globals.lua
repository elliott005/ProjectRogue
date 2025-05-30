Globals = {
    tile_size = 32,
    tilemap_size = vector(20, 20)
}

Globals.tilemap_size_pixels = Globals.tilemap_size * Globals.tile_size

function table.clone(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 2, direction = "pinchin", action = "fullscreen" })
hl.gesture({ fingers = 2, direction = "pinchout", action = "float" })

--Abre um overview das janelas e espaços
hl.gesture({
    fingers = 3,
    direction = "up",
    action = function()
        hl.dsp.global("overview:toggle")
    end
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 2, direction = "pinch", action = "fullscreen" })

--Abre um overview das janelas e espaços
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = function()
        hl.dispatch(hl.dsp.global("overview:toggle"))
    end
})

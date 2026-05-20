--Monitores
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("dbus-update-activation-enviroment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("firefox", { workspace = "2 silent" })
    hl.exec_cmd("alacritty -e zsh -c fastfetch")
end)

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 0,
        resize_on_border = true,
        allow_tearing = false,
        layout = "scrolling",

        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = { colors = { "rgba(595959aa)" } },
        }
    },

    --Decorações gerais
    decoration = {
        rounding = 0,
        active_opacity = 0,
        inactive_opacity = 0,

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            contrast = 1.8,
            brightness = 1,
        }

    },

    --Desativa decorações padrões
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },

    --Configurações de teclado e mouse
    input = {
        kb_layout = "br",
        kb_model = "abnt2",

        numlock_by_default = true,
        follow_mouse = 1,

        --Velocidade de repetição de tecla
        repeat_delay = 400,
        repeat_rate = 50,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        }

    }
})

-- Ignora eventos de maximização em todos os aplicativos
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})

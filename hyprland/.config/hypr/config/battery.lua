-- Battery percentage thresholds
local low_levels = { 15, 20 }
local critical_levels = { 3, 5, 10 }

local bat_path = "/sys/class/power_supply/BAT0"
local capacity_file = bat_path .. "/capacity"
local sec = 1000 -- 1 segundo = 1000 ms

-- Fallback paths if battery is found
local last_notify = 100

-- Safely read the battery file capacity
local function read_battery_level()
    local file = io.open(capacity_file, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()

    local clean_content = content:match("^%s*(.-)%s*$")
    local num = tonumber(clean_content)
    return num or nil
end

local function is_charging()
    local status_file = bat_path .. "/status"
    local file = io.open(status_file, "r")
    if not file then
        return false
    end

    local content = file:read("*all")
    file:close()

    local clean_status = content:match("^%s*(.-)%s*$")

    if clean_status == "Charging" then
        return true
    end

    return false
end

local function check_battery_level()
    local bat_lvl = read_battery_level()

    if not bat_lvl then
        print("[Hyprland Battery Loop] Falha ao ler a bateria!")
        return
    end

    if is_charging() then
        last_notify = 100
        return
    end

    local home = os.getenv("HOME") or ""
    local img_path = home .. "/.config/hypr/icons"

    for _, critical_level in ipairs(critical_levels) do
        if bat_lvl <= critical_level and critical_level < last_notify then
            local critical_level_img = img_path .. "/critical_battery_level.png"
            local notify_parts = {
                "notify-send -u critical",
                '"ATENÇÃO: Bateria em estado crítico!"',
                string.format('"Bateria abaixo de %d%%. Conecte ao carregador imediatamente!"', critical_level),
                "-i " .. critical_level_img,
                "-t " .. 5 * sec,
            }

            local notify_cmd = table.concat(notify_parts, " ")
            hl.dispatch(hl.dsp.exec_cmd(notify_cmd))

            -- 2. Audio trigger (using Hyprland dispatcher for execution)
            hl.dispatch(hl.dsp.exec_cmd("paplay /usr/share/sounds/gnome/default/alarms/ping-ping.oga"))

            last_notify = critical_level
            return
        end
    end

    for _, low_level in ipairs(low_levels) do
        if bat_lvl <= low_level and low_level < last_notify then
            local low_level_img = img_path .. "/low_battery_level.png"
            local notify_cmd = string.format(
                'notify-send -u critical "ATENÇÃO: Bateria baixa!"  "Bateria abaixo de %d%%" -i "%s" -t %d',
                low_level, low_level_img, 5 * sec
            )
            hl.dispatch(hl.dsp.exec_cmd(notify_cmd))

            -- 2. Audio trigger (using Hyprland dispatcher for execution)
            hl.dispatch(hl.dsp.exec_cmd("paplay /usr/share/sounds/freedesktop/stereo/service-logout.oga"))

            last_notify = low_level
            return
        end
    end
end

local function battery_exists()
    local file = io.open(capacity_file, "r")
    if not file then
        return false
    else
        file:close()
        return true
    end
end

-- Checa se há bateria antes de executar o timer
if not battery_exists() then
    print("[Hyprland Config Warning] Nenhuma bateria encontrada!")
else
    hl.timer(check_battery_level, { timeout = 10 * sec, type = "repeat" })
end

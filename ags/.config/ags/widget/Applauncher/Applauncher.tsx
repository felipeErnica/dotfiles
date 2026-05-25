import { For, createState } from "ags"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import AstalApps from "gi://AstalApps"
import Graphene from "gi://Graphene"


const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

export default function Applauncher() {
    let contentbox: Gtk.Box
    let searchentry: Gtk.Entry
    let win: Astal.Window


    const apps = new AstalApps.Apps()
    const [list, setList] = createState(apps.list)

    function search(text: string) {
        if (text === "") setList(apps.list)
        else setList(apps.fuzzy_query(text))
    }

    function launch(app?: AstalApps.Application) {
        if (app) {
            win.hide()
            app.launch()
        }
    }

    // close on ESC
    // handle alt + number key
    function onKey(
        _e: Gtk.EventControllerKey,
        keyval: number,
        _: number,
        mod: number,
    ) {
        if (keyval === Gdk.KEY_Escape) {
            win.visible = false
            return
        }

        if (mod === Gdk.ModifierType.ALT_MASK) {
            for (const i of [1, 2, 3, 4, 5, 6, 7, 8, 9] as const) {
                if (keyval === Gdk[`KEY_${i}`]) {
                    return launch(list.get()[i - 1])
                }
            }
        }
    }

    // close on clickaway
    function onClick(_e: Gtk.GestureClick, _: number, x: number, y: number) {
        const [, rect] = contentbox.compute_bounds(win)
        const position = new Graphene.Point({ x, y })

        if (!rect.contains_point(position)) {
            win.visible = false
            return true
        }
    }

    return (
        <window
            name="launcher"
            class="launcher"
            $={(ref) => {
                win = ref
                app.add_window(ref)
            }}
            anchor={TOP | BOTTOM | LEFT | RIGHT}
            exclusivity={Astal.Exclusivity.IGNORE}
            keymode={Astal.Keymode.EXCLUSIVE}
            onNotifyVisible={({ visible }) => {
                if (visible) searchentry.grab_focus()
                else searchentry.set_text("")
            }}
        >
            <Gtk.EventControllerKey onKeyPressed={onKey} />
            <Gtk.GestureClick onPressed={onClick} />
            <box
                $={(ref) => (contentbox = ref)}
                class="launcher-content"
                valign={Gtk.Align.CENTER}
                halign={Gtk.Align.CENTER}
                orientation={Gtk.Orientation.VERTICAL}
                widthRequest={700}
            >
                <entry
                    $={(ref) => (searchentry = ref)}
                    class="launcher-entry"
                    onNotifyText={({ text }) => search(text)}
                    placeholderText="  Pesquisar aplicação..."
                    heightRequest={40}
                />
                <Gtk.ScrolledWindow 
                    class="launcher-scroll" 
                    heightRequest={500}
                    vscrollbarPolicy={Gtk.PolicyType.ALWAYS}
                >
                    <box orientation={Gtk.Orientation.VERTICAL}>
                        <For each={list}>
                            {(app) => (
                                <button 
                                    class="launcher-button" 
                                    onClicked={() => launch(app)}
                                    heightRequest={75}
                                >
                                    <box>
                                        <image
                                            pixelSize={35}
                                            iconName={app.iconName}
                                            class="launcher-button-icon"
                                        />
                                        <label
                                            class="launcher-button-label"
                                            label={app.name}
                                            hexpand
                                            halign={Gtk.Align.START}
                                        />
                                    </box>
                                </button>
                            )}
                        </For>
                    </box>
                </Gtk.ScrolledWindow>
            </box>
        </window>
    )
}

import app from "ags/gtk4/app"
import style from './style.scss';
import Applauncher from "./widget/Applauncher/Applauncher"

app.start({
    css: style,
    main() {
        Applauncher()
    },
})

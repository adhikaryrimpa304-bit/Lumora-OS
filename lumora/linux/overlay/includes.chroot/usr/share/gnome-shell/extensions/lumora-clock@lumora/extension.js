import St from 'gi://St';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const SIZE = 240;
const PURPLE = [0.690, 0.149, 1.0];
const PURPLE_LIGHT = [0.847, 0.651, 1.0];
const CYAN = [0.0, 0.941, 1.0];
const BG = [0.075, 0.043, 0.125];
const GAP = 0.12;

export default class LumoraClock extends Extension {
    enable() {
        this._settings = new Gio.Settings({schema_id: 'org.gnome.desktop.interface'});
        this._settingsId = this._settings.connect('changed::clock-format', () => this._tick());

        this._box = new St.Widget({
            layout_manager: new Clutter.BinLayout(),
            width: SIZE,
            height: SIZE,
            reactive: false,
        });

        this._ring = new St.DrawingArea({x_expand: true, y_expand: true});
        this._ring.connect('repaint', area => this._draw(area));
        this._box.add_child(this._ring);

        const col = new St.BoxLayout({
            vertical: true,
            x_expand: true,
            y_expand: true,
            x_align: Clutter.ActorAlign.CENTER,
            y_align: Clutter.ActorAlign.CENTER,
        });
        const row = new St.BoxLayout({x_align: Clutter.ActorAlign.CENTER});

        this._h = new St.Label({style: 'font-size: 46px; font-weight: 700; color: #B026FF;'});
        const colon = new St.Label({text: ':', style: 'font-size: 46px; font-weight: 300; color: #A998C9; padding: 0 2px;'});
        this._m = new St.Label({style: 'font-size: 46px; font-weight: 700; color: #00F0FF;'});
        this._date = new St.Label({
            x_align: Clutter.ActorAlign.CENTER,
            style: 'font-size: 13px; color: #A998C9; padding-top: 2px;',
        });

        row.add_child(this._h);
        row.add_child(colon);
        row.add_child(this._m);
        col.add_child(row);
        col.add_child(this._date);
        this._box.add_child(col);

        Main.layoutManager._backgroundGroup.add_child(this._box);
        this._place();
        this._monitorsId = Main.layoutManager.connect('monitors-changed', () => this._place());

        this._tick();
        this._timeoutId = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
            this._tick();
            return GLib.SOURCE_CONTINUE;
        });
    }

    disable() {
        if (this._timeoutId) {
            GLib.source_remove(this._timeoutId);
            this._timeoutId = null;
        }
        if (this._monitorsId) {
            Main.layoutManager.disconnect(this._monitorsId);
            this._monitorsId = null;
        }
        if (this._settingsId) {
            this._settings.disconnect(this._settingsId);
            this._settingsId = null;
        }
        this._settings = null;
        this._box?.destroy();
        this._box = null;
        this._ring = null;
    }

    _place() {
        const m = Main.layoutManager.primaryMonitor;
        if (!m)
            return;
        this._box.set_position(m.x + m.width - SIZE - 64, m.y + 72);
    }

    _tick() {
        if (!this._box)
            return;
        const now = GLib.DateTime.new_now_local();
        const is12 = this._settings.get_string('clock-format') === '12h';
        this._h.set_text(now.format(is12 ? '%I' : '%H'));
        this._m.set_text(now.format('%M'));
        this._date.set_text(now.format(is12 ? '%a %d %b · %p' : '%a %d %b'));
        this._ring.queue_repaint();
    }

    _draw(area) {
        const cr = area.get_context();
        const [w] = area.get_surface_size();
        const cx = w / 2;
        const cy = w / 2;
        const r = w / 2 - 16;
        const sec = GLib.DateTime.new_now_local().get_second();

        cr.setSourceRGBA(...BG, 0.6);
        cr.arc(cx, cy, r - 6, 0, 2 * Math.PI);
        cr.fill();

        cr.setLineWidth(10);
        cr.setLineCap(1);

        cr.setSourceRGBA(...PURPLE, 1);
        cr.arc(cx, cy, r, Math.PI / 2 + GAP, 3 * Math.PI / 2 - GAP);
        cr.stroke();

        cr.setSourceRGBA(...CYAN, 1);
        cr.arc(cx, cy, r, -Math.PI / 2 + GAP, Math.PI / 2 - GAP);
        cr.stroke();

        cr.setLineWidth(2);
        cr.setSourceRGBA(...PURPLE_LIGHT, 0.35);
        for (let i = 0; i < 12; i++) {
            const a = i * Math.PI / 6;
            cr.moveTo(cx + Math.cos(a) * (r - 20), cy + Math.sin(a) * (r - 20));
            cr.lineTo(cx + Math.cos(a) * (r - 28), cy + Math.sin(a) * (r - 28));
            cr.stroke();
        }

        const a = -Math.PI / 2 + (sec / 60) * 2 * Math.PI;
        const px = cx + Math.cos(a) * r;
        const py = cy + Math.sin(a) * r;
        cr.setSourceRGBA(1, 1, 1, 0.25);
        cr.arc(px, py, 11, 0, 2 * Math.PI);
        cr.fill();
        cr.setSourceRGBA(...PURPLE_LIGHT, 1);
        cr.arc(px, py, 6, 0, 2 * Math.PI);
        cr.fill();

        cr.$dispose();
    }
}

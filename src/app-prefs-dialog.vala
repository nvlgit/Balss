/* app-prefs-dialog.vala *
 *
 * Copyright (C) 2018 Nick *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Balss {

    [GtkTemplate (ui = "/com/github/nvlgit/Balss/prefs.ui")]
    public class AppPrefs : Gtk.Window {


        public AppPrefs (PlayerAppWindow window) {
            GLib.Object (transient_for: window);

            //settings = new GLib.Settings ("com.github.nvlgit.Balss");
          //  settings.bind ("f", f, "f",
            //               GLib.SettingsBindFlags.DEFAULT);
            //settings.bind ("tr", tr, "active-id",
              //             GLib.SettingsBindFlags.DEFAULT);
        }
    }

}
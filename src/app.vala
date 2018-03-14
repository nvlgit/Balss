/* app.vala
 *
 * Copyright (C) 2018 Nick
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

    const string APP_ID = "com.github.nvlgit.Balss";
    const string APP_VERISON = "0.0.1";
    const string APP_ICON = "balss";

    public class App : Gtk.Application {

    	/* The application actions */
    	private const ActionEntry[] actions = {

		{ "openfile",  open_cb       },
		{ "prefs",     prefs_cb      },
		{ "shortcuts", shortcuts_cb  },
		{ "about",     about_cb      },
		{ "quit",      quit_cb       }
    	};

        private PlayerAppWindow win;

        public App () {

		application_id = APP_ID;
		flags |= GLib.ApplicationFlags.HANDLES_OPEN;

        }

    	private void prefs_cb (SimpleAction action, Variant? parameter) {

		var prefs = new AppPrefs ( (PlayerAppWindow) this.active_window );
		prefs.present ();
    	}

    	void shortcuts_cb (SimpleAction action, Variant? parameter) {
/*
		var builder = new Gtk.Builder.from_resource (
		                           "/com/github/nvlgit/Balss/shortcuts-window.ui");
		var shortcuts_window = (Gtk.Window) builder.get_object ("shortcuts-window");
		shortcuts_window.show ();
*/
    	}

    	void about_cb (SimpleAction action, Variant? parameter) {

    		AppAbout about = new AppAbout (get_active_window () );
    		about.present ();
        }

    	void quit_cb (SimpleAction action, Variant? parameter) {

    		this.quit ();
    	}

    	public override void startup () {

    		base.startup ();

    		var css_provider = new Gtk.CssProvider ();
       		css_provider.load_from_resource ("/com/github/nvlgit/Balss/style.css");
       		Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
            						  css_provider,
		                                          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    		Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
    		icon_theme.add_resource_path("/com/github/nvlgit/Balss/icons");

    		this.add_action_entries (actions, this);
        	var builder = new Gtk.Builder.from_resource ("/com/github/nvlgit/Balss/app-menu.ui");
        	var appmenu = (GLib.MenuModel) builder.get_object ("app-menu");
    		this.set_app_menu (appmenu);



    	}

        protected override void activate () {

                base.activate ();
                win = (PlayerAppWindow) this.active_window;
                if (win == null)
                    win = new PlayerAppWindow (this);
                win.mp_set_uri("file:///home/vic/Music/gonki.m4b");
    		win.present ();
        }

        public override void open (GLib.File[] files,
                                   string      hint) {

                win = (PlayerAppWindow) this.active_window;
                if (win == null)
                    win = new PlayerAppWindow (this);
                win.open (files[0]);
    		win.present ();

        }
	
        private void open_cb (SimpleAction action, Variant? parameter) {

    		var dialog = new OpenDialog ();
    		dialog.set_transient_for ( (PlayerAppWindow) this.active_window );

    		var uri = dialog.get_file ();

    		stdout.printf ("Selected:  %s\n", uri);
    		win.mp_set_uri (uri);
    		dialog.close();
        }
    }
}

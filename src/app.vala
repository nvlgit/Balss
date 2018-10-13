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

	const string APP_ID = "com.gitlab.nvlgit.Balss";


	public class App : Gtk.Application {


		private PlayerWindow win;
		public static Prefs preferences;

		private const ActionEntry[] actions = {

			{ "open",      open_cb       },
			{ "prefs",     prefs_cb      },
			{ "shortcuts", shortcuts_cb  },
			{ "about",     about_cb      },
			{ "quit",      quit_cb       }
		};



		public App () {

			application_id = APP_ID;
			flags |= GLib.ApplicationFlags.HANDLES_OPEN;
		}



		private void open_cb (SimpleAction action, Variant? parameter) {

			win = (PlayerWindow) this.active_window;
			win.show_page ("main");

			var chooser = new Gtk.FileChooserDialog ("Select file",
			                                         win as PlayerWindow,
			                                         Gtk.FileChooserAction.OPEN,
			                                         _("_Cancel"),
			                                         Gtk.ResponseType.CANCEL,
			                                         _("_Open"),
			                                         Gtk.ResponseType.ACCEPT,
			                                         null);
			var filter = new Gtk.FileFilter ();
			filter.set_filter_name (_("m4b books") );
			filter.add_pattern ("*.m4b");
			filter.add_pattern ("*.M4B");
			filter.add_pattern ("*.M4b");
			filter.add_pattern ("*.m4B");
			chooser.add_filter (filter);

			filter = new Gtk.FileFilter ();
			filter.set_filter_name (_("All audio files") );
			filter.add_mime_type ("audio/*");
			chooser.add_filter (filter);

			filter = new Gtk.FileFilter ();
			filter.set_filter_name (_("All files") );
			filter.add_pattern ("*");
			chooser.add_filter (filter);

			chooser.local_only = true;
			chooser.select_multiple = false;
			chooser.set_modal (true);

			chooser.response.connect ( (fc, r) => {

				var c = fc  as Gtk.FileChooserDialog;
				if (r == Gtk.ResponseType.ACCEPT)
					win.open (c.get_uri () );
				chooser.destroy ();
			});

			chooser.show ();
		}



		private void prefs_cb (SimpleAction action, Variant? parameter) {

			win = (PlayerWindow) this.active_window;
			win.show_page ("prefs");
		}



		private void shortcuts_cb (SimpleAction action, Variant? parameter) {

			var builder = new Gtk.Builder.from_resource (
			                  "/com/gitlab/nvlgit/Balss/shortcuts-window.ui");
			var shortcuts_window = (Gtk.Window) builder.get_object ("shortcuts-window");
			shortcuts_window.show ();
		}



		void about_cb (SimpleAction action, Variant? parameter) {

			AppAbout about = new AppAbout (get_active_window () );
			about.present ();
		}



		void quit_cb (SimpleAction action, Variant? parameter) {

			this.win.on_close_window ();
			this.quit ();
		}



		private void notify_desktop (string title, string body) {

			var n = new GLib.Notification (title);
			n.set_body (body);
			( (GLib.Application) this).send_notification (null, n);
		}



		public override void startup () {

			base.startup ();
			preferences = new Prefs ();

			var css_provider = new Gtk.CssProvider ();
			css_provider.load_from_resource ("/com/gitlab/nvlgit/Balss/style.css");
			Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
			                                          css_provider,
			                                          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

			Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
			icon_theme.add_resource_path("/com/gitlab/nvlgit/Balss/icons");

			this.add_action_entries (actions, this);
		}



		protected override void activate () {

			//base.activate ();
			win = (PlayerWindow) this.active_window;
			if (win == null) {
				win = new PlayerWindow (this);
				win.new_notification.connect (notify_desktop);
			}
			win.present ();
		}



		public override void open (GLib.File[] files,
		                           string      hint) {

			win = (PlayerWindow) this.active_window;
			if (win == null)
				win = new PlayerWindow (this);

			string uri = files[0].get_uri ();
			win.open (uri);
			win.present ();
		}
	}
}

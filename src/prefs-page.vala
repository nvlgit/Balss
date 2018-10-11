/* prefs-page.vala
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

	[GtkTemplate (ui = "/com/gitlab/nvlgit/Balss/prefs-page.ui")]
	public class PrefsPage : Gtk.Box {


		[GtkChild] private Gtk.Switch play_last_switch;
		[GtkChild] private Gtk.SpinButton rate_spinbutton;
		[GtkChild] private Gtk.Switch dark_theme_switch;
		[GtkChild] private Gtk.Switch mpris_switch;
		[GtkChild] private Gtk.Switch notification_switch;
		[GtkChild] private Gtk.ListBox pb_listbox;
		[GtkChild] private Gtk.ListBoxRow play_last_row;
		[GtkChild] private Gtk.ListBoxRow rate_row;
		[GtkChild] private Gtk.ListBox appearence_listbox;
		[GtkChild] private Gtk.ListBoxRow dark_theme_row;
		[GtkChild] private Gtk.ListBox features_listbox;
		[GtkChild] private Gtk.ListBoxRow mpris_row;
		[GtkChild] private Gtk.ListBoxRow notify_row;



		construct {

			add_separators (this.pb_listbox);
			add_separators (this.features_listbox);
			connect_prefs_signals ();
			connect_rows_signals ();
		}



		public PrefsPage () {

			dark_theme_switch.active = App.preferences.dark_theme;
			notification_switch.active = App.preferences.show_notifications;
			play_last_switch.active = App.preferences.play_last;
			rate_spinbutton.value = App.preferences.playback_rate;
		}



		public void update_gtk_theme () {

			var gtk_settings = Gtk.Settings.get_default ();
			gtk_settings.gtk_application_prefer_dark_theme = App.preferences.dark_theme;
		}



		private void add_separators (Gtk.ListBox lbox) {

			lbox.set_header_func (update_header_fn);
		}



		private void update_header_fn (Gtk.ListBoxRow row, Gtk.ListBoxRow? before){

			Gtk.Widget? current;

			if (before == null) {
				row.set_header (null);
				return;
			}

			current = row.get_header ();
			if (current == null) {
				current = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
				current.show ();
				row.set_header (current);
			}
		}



		private void connect_prefs_signals () {

			App.preferences.notify["dark-theme"].connect (update_gtk_theme);

			dark_theme_switch.state_set.connect( () => {
				App.preferences.dark_theme = dark_theme_switch.active;
				return false;
			});

			play_last_switch.state_set.connect( () => {
				App.preferences.play_last = play_last_switch.active;
				return false;
			});

			notification_switch.state_set.connect( () => {
				App.preferences.show_notifications = notification_switch.active;
				return false;
			});

			rate_spinbutton.value_changed.connect( () => {
				App.preferences.playback_rate = rate_spinbutton.value;
			});
		}


		private void connect_rows_signals () {

			this.pb_listbox.row_activated.connect ( (row) => {

				if (row == play_last_row)
						play_last_switch.active = !play_last_switch.active;
				if (row == rate_row)
						rate_spinbutton.grab_focus ();
			});

			this.appearence_listbox.row_activated.connect ( (row) => {

				if (row == dark_theme_row)
					dark_theme_switch.active = !dark_theme_switch.active;
			});

			this.features_listbox.row_activated.connect ( (row) => {

				if (row == mpris_row)
					mpris_switch.active = !mpris_switch.active;
				if (row == notify_row)
					notification_switch.active = !notification_switch.active;
			});
		}

	}
}

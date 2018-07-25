/* window.vala
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

	[GtkTemplate (ui = "/com/gitlab/nvlgit/Balss/window.ui")]
	public class PlayerWindow : Gtk.ApplicationWindow {

		public signal void new_notification (string title, string body);

		private Player? player;
		private InfoDisplay? info;
		private GLib.List<Chapter?>? list;
		private ChapterListBox? lb;
		private Gtk.Builder builder;

		private double duration;
		private double current_chapter_offset;
		private double current_chapter_duration;

		private bool audiobook;
		private string basename;
		private string uri;
		private string last_uri;
		private double last_position;

		[GtkChild] private Gtk.Stack win_stack;
		[GtkChild] private Gtk.Stack header_stack;
		[GtkChild] private Gtk.Button button_play;
		[GtkChild] private Gtk.Button button_previous;
		[GtkChild] private Gtk.Button button_next;
		[GtkChild] private Gtk.Image pause_image;
		[GtkChild] private Gtk.Image play_image;
		[GtkChild] private Gtk.VolumeButton volume_button;
		[GtkChild] private Gtk.ProgressBar progress;
		[GtkChild] private Gtk.Scale seek_bar;
		[GtkChild] private Gtk.Box display_placeholder_box;
		[GtkChild] private Gtk.Box chapter_list_placeholder_box;
		[GtkChild] private Gtk.MenuButton button_menu;
		[GtkChild] private Gtk.Switch dark_theme_switch;
		[GtkChild] private Gtk.Switch notification_switch;
		[GtkChild] private Gtk.Switch play_last_switch;
		[GtkChild] private Gtk.SpinButton prefs_speed_spin_button;
		[GtkChild] private Gtk.SpinButton playback_speed_spin_button;


		construct {

			this.duration = 0;
			this.current_chapter_offset = 0;
			this.current_chapter_duration = 0;
			this.audiobook = false;

			this.player = new Player ();

			bind_menu_to_button_menu ();

			this.info = new InfoDisplay ();
			display_placeholder_box.pack_start (info, false, true, 0);
		}



		public PlayerWindow (Gtk.Application app) {
			GLib.Object (application: app);

			update_gtk_theme ();
			App.preferences.notify["dark-theme"].connect (update_gtk_theme);
			dark_theme_switch.active = App.preferences.dark_theme;

			notification_switch.active = App.preferences.show_notifications;
			play_last_switch.active = App.preferences.play_last;
			this.last_uri = App.preferences.last_uri;
			this.last_position = App.preferences.last_position;

			prefs_speed_spin_button.value = App.preferences.playback_speed;
			playback_speed_spin_button.value = App.preferences.playback_speed;
			speed_changed_cb (App.preferences.playback_speed); // display value

			this.set_default_size (App.preferences.window_width, App.preferences.window_height);
			this.delete_event.connect (window_delete_event_cb);

			connect_prefs_signals ();
		}



		public void open (string uri) {

			basename = File.new_for_uri (uri).get_basename ();
			if (player != null) {
				player.destroy_context ();
				player = null;
				player = new Player ();
				clear_ui_interface ();
				connect_player_signals ();
			}
			player.load_uri (uri, 100.0); //FIXME Play last position
			player.set_speed ( (double) App.preferences.playback_speed);
		}



		public void show_page (string page_name) {

		win_stack.set_visible_child_name (page_name);
		header_stack.set_visible_child_name (page_name);
		}



		private void clear_ui_interface () {

			if (info != null)
				info.clear ();
			if (lb != null) {
				( (Gtk. Container) chapter_list_placeholder_box).remove (lb);
				lb = null;
			}
			this.button_next.sensitive = false;
			this.button_previous.sensitive = false;
		}



		private void connect_player_signals () {

			player.position_updated.connect (position_updated_cb);
			player.duration_changed.connect (duration_changed_cb);
			player.speed_changed.connect (speed_changed_cb);
			player.metadata_updated.connect (metadata_updated_cb);
			player.volume_changed.connect (volume_changed_cb);
			player.chapter_changed.connect (chapter_changed_cb);
			player.pause_changed.connect (pause_changed_cb);

			player.mute_changed.connect ( (m) => {
				//debug ("Mute: %s\n", (m == false) ? "Unmuted" : "Muted" ); //FIXME
			});
			player.end_of_stream.connect ( () => { //FIXME

				player.set_position (0);
				player.pause();
			});
		}



		private void update_gtk_theme () {

			var gtk_settings = Gtk.Settings.get_default ();
			gtk_settings.gtk_application_prefer_dark_theme = App.preferences.dark_theme;
		}



		private void connect_prefs_signals () {

			dark_theme_switch.state_set.connect(() => {
				App.preferences.dark_theme = dark_theme_switch.active;
				return false;
			});

			play_last_switch.state_set.connect(() => {
				App.preferences.play_last = play_last_switch.active;
				return false;
			});

			notification_switch.state_set.connect(() => {
				App.preferences.show_notifications = notification_switch.active;
				return false;
			});

			prefs_speed_spin_button.value_changed.connect(() => {
				App.preferences.playback_speed = prefs_speed_spin_button.value;
			});
		}



		private void bind_menu_to_button_menu () {

			builder = new Gtk.Builder ();
			try {
				builder.add_from_resource ("/com/gitlab/nvlgit/Balss/app-menu.ui");
				var menu = (GLib.MenuModel) builder.get_object ("app-menu") as MenuModel;
				button_menu.set_menu_model (menu);
			} catch (Error e) {
				error ("%s", e.message);
			}

		}



		private void show_chapter_list () {

			this.lb = new ChapterListBox ();
			chapter_list_placeholder_box.pack_end (lb, true, true, 0);
			this.lb.hexpand = true;
			int n = 0;

			this.list.foreach ( (c) => {

				var row = new ChapterRow ();
				n++;
				row.number = n.to_string ();
				row.title = c.title;
				row.duration = to_hhmmss (c.end - c.offset);
				this.lb.add_row (row);
			});

			this.lb.chapter_row_activated.connect ( (i) => {

				player.set_chapter (i);
				player.set_chapter (i);
			});
		}



		[GtkCallback]
		private void show_main_page_cb () {

			show_page ("main");
		}



		[GtkCallback]
		private void playback_speed_spin_button_value_changed_cb (){

			float val =  (float) playback_speed_spin_button.get_value ();
			info.speed = "%g×".printf (val);
			player.set_speed ( (double) val);
		}



		[GtkCallback] private void button_play_clicked_cb () {

			if (player.get_pause () == true) {
				player.play ();
			} else {
				player.pause ();
			}
		}



		[GtkCallback] private void button_next_clicked_cb () {

			player.set_next_chapter ();
		}



		[GtkCallback] private void button_previous_clicked_cb () {

			player.set_previous_chapter ();
		}



		[GtkCallback] private void volume_button_value_changed_cb (double val) {

		player.set_volume (val * 100);
		}



		[GtkCallback] private void seek_bar_value_changed_cb () {

			player.set_position (seek_bar.get_value () );
		}


		private bool window_delete_event_cb (Gtk.Widget widget, Gdk.EventAny event) {

			int w;
			int h;
			this.get_size (out w, out h);
			App.preferences.window_width = w;
			App.preferences.window_height = h;
			return false;
		}



		private void pause_changed_cb (bool p) {

			if (p == true) {
				pause_image.visible = false;
				play_image.visible = true;
			} else {
				play_image.visible = false;
				pause_image.visible = true;
			}
		}



		private void duration_changed_cb (double dur) {

			this.lb = null;
			this.duration = dur;

			if (0 < player.get_chapter_count () )
				this.audiobook = true;
			else
				this.audiobook = false;

			if (this.audiobook) {
				this.list = new GLib.List<Chapter?> ();
				this.list = player.get_chapter_list();
				this.progress.visible = true;
				show_chapter_list ();
			} else {
				this.progress.visible = false;
				this.seek_bar.set_range (0, this.duration);
			}
			volume_changed_cb (this.player.get_volume () ); //not always emitted
		}



		private void volume_changed_cb (double val) {

			double cur_val = this.volume_button.get_value ();
			double new_val = (val / 100);
			if (GLib.Math.fabs (cur_val - new_val) > 0.001) {

				GLib.Idle.add ( () => {

					volume_button.value_changed.disconnect (volume_button_value_changed_cb);
					volume_button.set_value (new_val);
					volume_button.value_changed.connect (volume_button_value_changed_cb);

					return false;
				});
			}
		}



		private void speed_changed_cb (double val) {

			info.speed = "%g×".printf (val);
		}



		private void metadata_updated_cb () {

			info.title = (player.metadata.title != null) ? player.metadata.title : this.basename;
			info.artist = (player.metadata.artist != null) ? player.metadata.artist : "";
			string genre = (player.metadata.genre != null) ? player.metadata.genre : "";
			string year = (player.metadata.date != null) ? player.metadata.date.substring (0, 4) : "";
			info.genre = "%s   %s".printf (genre, year);
		}



		private void position_updated_cb (double pos) {

			set_progress_fraction (pos);
			info.total_time = "%s / %s".printf (
			                               to_hhmmss (pos),
			                               to_hhmmss(this.duration)
			                            );
			seek_bar.value_changed.disconnect (seek_bar_value_changed_cb);
			seek_bar.set_value (pos);
			seek_bar.value_changed.connect (seek_bar_value_changed_cb);

			if (audiobook) {

				info.chapter_time = "%s / %s".printf (
				        to_hhmmss (pos - this.current_chapter_offset),
				        to_hhmmss (this.current_chapter_duration) );
			}
		}



		private void chapter_changed_cb (int i) {

			int count = player.get_chapter_count ();

			info.chapter_index = "%d / %d".printf ( i + 1, count);
			info.chapter_title = this.list.nth_data (i).title;

			this.current_chapter_offset = this.list.nth_data (i).offset;
			this.current_chapter_duration =
			           this.list.nth_data (i).end - this.current_chapter_offset;

			seek_bar.value_changed.disconnect (seek_bar_value_changed_cb);
			this.seek_bar.set_range (
			                    this.list.nth_data (i).offset,
			                    this.list.nth_data (i).end );
			seek_bar.value_changed.connect (seek_bar_value_changed_cb);

			this.lb.select_row_at_index (i);

			this.button_next.sensitive = true;
			this.button_previous.sensitive = true;

			if (i == 0) {
				this.button_previous.sensitive = false;
			}
			if (i+1 == count) {
				this.button_next.sensitive = false;
			}

			bool notify = App.preferences.show_notifications;
			if (notify) {
				string body = "%d. %s".printf (i+1, this.list.nth_data (i).title);
				new_notification (player.metadata.title, body); // emit signal
			}
		}


		private void set_progress_fraction (double pos) {

			if (duration == 0)
				return;

			if (pos == 0)
				progress.set_fraction (0);
			else
				progress.set_fraction (pos/duration);
		}



		private string to_hhmmss (double seconds) {

			string ret = "00:00:00";
			int hh = 0, mm = 0, ss = 0;

			int64 secs = (int64) GLib.Math.llround (seconds);

			hh = (int) secs / (60 * 60);
			mm = (int) secs / 60  - (hh * 60);
			ss = (int) secs % 60;

			if (hh > 0)
				ret = "%d:%02d:%02d".printf (hh, mm, ss);
			else
				ret = "%d:%02d".printf (mm, ss);

			return ret;
		}

/*************** TODO *****************/

		public double get_speed () {

			return player.get_speed ();
		}

		public double get_volume () {

			return player.get_volume ();
		}

		public void set_volume (double vol) {

			player.set_volume (vol);
		}




	}
}
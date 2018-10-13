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

		[GtkChild] private Gtk.Stack win_stack;
		[GtkChild] private Gtk.Stack header_stack;
		[GtkChild] private Gtk.HeaderBar header_main;
		[GtkChild] private Gtk.Button button_play;
		[GtkChild] private Gtk.Button seek_forward_button;
		[GtkChild] private Gtk.Button seek_backward_button;
		[GtkChild] private Gtk.Image pause_image;
		[GtkChild] private Gtk.Image play_image;
		[GtkChild] private Gtk.Scale volume_scale;
		[GtkChild] private Gtk.Box chapter_list_placeholder_box;
		[GtkChild] private Gtk.MenuButton controls_button;
		[GtkChild] private Gtk.SpinButton playback_rate_spin_button;
		[GtkChild] private Gtk.Box bottom_placeholder_box;
		[GtkChild] private Gtk.Box prefs_placeholder_box;

		private Player? player;
		private GLib.List<Chapter?>? list;
		private ChapterListBox? lb;
		private ChapterIndicator indicator;
		private PrefsPage prefs_page;
		private Gtk.Builder builder;

		private double duration;
		private bool audiobook;
		private string basename;
		private int64 rounded_seconds;
		private double current_chapter_offset;
		private double current_chapter_duration;
		private bool speed_was_setted;
		private bool was_eos;
		private bool initial_volume_was_setted;
		private bool seek_needed;
		private bool chapter_changed_init;



		construct {

			this.duration = 0;
			this.rounded_seconds = -1;
			this.current_chapter_offset = 0;
			this.current_chapter_duration = 0;
			this.audiobook = false;
			temp = false;

			this.speed_was_setted = false;
			this.seek_needed = false;
			this.was_eos = false;
			this.initial_volume_was_setted = false;
			this.chapter_changed_init =false;

			indicator = new ChapterIndicator ();
			indicator.button_clicked.connect (indicator_button_clicked);
			bottom_placeholder_box.pack_start (this.indicator, true, true, 0);
			prefs_page = new PrefsPage ();
			prefs_page.update_gtk_theme ();
			prefs_placeholder_box.pack_start (this.prefs_page, true, true, 0);
		}


		public PlayerWindow (Gtk.Application app) {
			GLib.Object (application: app);

			this.set_default_size (App.preferences.window_width, App.preferences.window_height);
			this.delete_event.connect (window_delete_event_cb);

			if (App.preferences.play_last) { // when startup without argument
				if (App.preferences.last_uri.length > 6) {
					this.seek_needed = true;
					open (App.preferences.last_uri);
				}
			}
		}



		public void open (string uri) {

			if (App.preferences.play_last) {
				if (uri == App.preferences.last_uri) {
					this.seek_needed = true;
				}
			}
			if (App.preferences.last_uri != uri) {
				App.preferences.last_uri = uri;
			}
			this.basename = File.new_for_uri (uri).get_basename ();
			player_check_reinit ();
			activate_buttons ();
			this.speed_was_setted = false;
			player.load_uri (uri);
		}




		private void activate_buttons () {

		button_play.sensitive = true;
		seek_forward_button.sensitive = true;
		seek_backward_button.sensitive = true;
		controls_button.visible = true;
		player.rate_changed.disconnect (player_rate_changed_cb);
		playback_rate_spin_button.value = App.preferences.playback_rate;
		player.rate_changed.connect (player_rate_changed_cb);


		}
		public void show_page (string page_name) {

			win_stack.set_visible_child_name (page_name);
			header_stack.set_visible_child_name (page_name);
		}



		private void clear_ui_interface () {

			if (lb != null) {
				( (Gtk. Container) chapter_list_placeholder_box).remove (lb);
				lb = null;
			}
			this.indicator.clear ();
		}



		private void connect_player_signals () {

			player.position_updated.connect (player_position_updated_cb);
			player.duration_changed.connect (player_duration_changed_cb);
			player.rate_changed.connect     (player_rate_changed_cb);
			player.metadata_updated.connect (player_metadata_updated_cb);
			player.volume_changed.connect   (player_volume_changed_cb);
			player.chapter_changed.connect  (player_chapter_changed_cb);
			player.pause_changed.connect    (player_pause_changed_cb);
			player.end_of_stream.connect    (player_end_of_stream_cb);

			player.mute_changed.connect ( (m) => { //FIXME Needed?
				//debug ("Mute: %s\n", (m == false) ? "Unmuted" : "Muted" );
			});
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
			this.lb.chapter_row_activated.connect (lb_chapter_row_activated_cb);
			this.lb.seek_changed.connect (seekbar_value_changed_cb);
		}



		private void lb_chapter_row_activated_cb (int index){

			if (this.player == null) return;

			this.player.set_chapter (index);

			if (this.player.get_pause () )
				this.player.play ();
		}



		private void show_one_list_item () {

			this.lb = new ChapterListBox ();
			chapter_list_placeholder_box.pack_end (lb, true, true, 0);
			this.lb.hexpand = true;

			var row = new ChapterRow ();
			row.number = "";
			row.title = this.basename;
			row.duration = to_hhmmss (this.duration);
			this.lb.add_row (row);
			this.lb.seek_changed.connect (seekbar_value_changed_cb);
			this.lb.mark_row_at_index (0);
			this.lb.set_range (0, this.duration );
		}



		private void indicator_button_clicked (int direction){

			if (this.player == null) return;

			if (direction < 0)
				player.set_previous_chapter ();
			else
				player.set_next_chapter ();
		}



		[GtkCallback] private void show_main_page_cb () {

			show_page ("main");
		}



		[GtkCallback]
		private void playback_rate_spin_button_value_changed_cb (){

			if (this.player == null) return;

			float val =  (float) playback_rate_spin_button.get_value ();
			//this.button_rate_label.label = "%g×".printf (val);
			player.set_rate ( (double) val);
		}



		[GtkCallback] private void button_play_clicked_cb () {

			if (this.player == null) return;

			if (player.get_pause () == true) {
				player.play ();
			} else {
				player.pause ();
			}
		}



		[GtkCallback] private void seek_forward_button_clicked_cb () {

			if (this.player == null) return;

			double pos = player.get_position () + 5;
			if (pos < this.duration)
				this.player.set_position (pos);
		}



		[GtkCallback] private void seek_backward_button_clicked_cb () {

			if (this.player == null) return;

			double pos = player.get_position ();
			if (pos < 5)
				pos = 0;
			else
				pos = pos -5;
			this.player.set_position (pos);
		}



		[GtkCallback] private void volume_scale_value_changed_cb () {

		double val = this.volume_scale.get_value ();
		player.set_volume (val * 100);
		}



		private void seekbar_value_changed_cb (double val) {

			if (this.player == null) return;

			player.set_position (val);
		}



		private void player_check_reinit () {

			if (this.player != null) {
				this.player.destroy_context ();
				this.player = null;
			}
			this.player = new Player ();
			connect_player_signals ();
		}

		private bool window_delete_event_cb (Gtk.Widget widget,
		                                     Gdk.EventAny event) {
			on_close_window ();
			return false;
		}



		public void on_close_window () {

			int w, h;
			player.pause ();
			App.preferences.last_position = player.get_position ();
			this.get_size (out w, out h);
			App.preferences.window_width = w;
			App.preferences.window_height = h;
			player.destroy_context ();
			player = null;
		}



		private void player_pause_changed_cb (bool p) {

			if (p == true) {
				pause_image.visible = false;
				play_image.visible = true;
			} else {
				play_image.visible = false;
				pause_image.visible = true;
			}
			debug ("pause_changed");
		}



		private void player_duration_changed_cb (double dur) {

			clear_ui_interface ();
			this.duration = dur;

			if (0 < player.get_chapter_count () )
				this.audiobook = true;
			else
				this.audiobook = false;

			if (this.audiobook) {
				this.list = new GLib.List<Chapter?> ();
				this.list = player.get_chapter_list();
				show_chapter_list ();
			} else {
				show_one_list_item ();
			}
			//this.lb.set_range (0, this.duration);
			debug ("duration_changed");

		}

		private bool temp;

		private void player_position_updated_cb (double pos) {

			if (!temp) {
			debug ("position_changed");
			temp = true;
			}
			check_and_apply_initial_stuffs ();

			int64 rounded_pos = GLib.Math.llround (pos);
			if (this.rounded_seconds != rounded_pos) {

				set_lb_position (pos);
				set_progress_fraction (pos);
				this.rounded_seconds = rounded_pos;
			}

/*			GLib.Idle.add ( () => {

				set_lb_position (pos);
				set_progress_fraction (pos);
				//this.rounded_seconds = rounded_pos;
				return false;
			});
*/
		}



		private void check_and_apply_initial_stuffs () {

			if (this.was_eos) {
				player.pause ();
				this.was_eos = false;
			}
			if (!this.speed_was_setted) {
				player.set_rate ( (double) App.preferences.playback_rate);
				this.speed_was_setted = true;
			}
			if (!initial_volume_was_setted) {
				set_volume_scale_value (this.player.get_volume () / 100);
				initial_volume_was_setted = true;
			}
			if (this.seek_needed) {
				//this.player.set_soft_mute (true);
				player.pause ();
				player.set_position (App.preferences.last_position);
				this.seek_needed = false;
				player.play();
				//this.player.set_soft_mute (false);
			}
		}



		private void player_chapter_changed_cb (int i) {

			debug ("chapter_changed");

			if (i < 0) { //FIXME sametimes -1
				debug ("Negative chapter index: %d", i);
				i = 0;
			}

			int count = player.get_chapter_count ();

			this.current_chapter_offset = this.list.nth_data (i).offset;
			this.current_chapter_duration =
			           this.list.nth_data (i).end - this.current_chapter_offset;

			this.lb.mark_row_at_index (i);
			this.lb.set_range (this.list.nth_data (i).offset,
			                   this.list.nth_data (i).end );
			this.chapter_changed_init = true;//!!!!!!!

			this.indicator.set_info (i+1, count);

			bool notify = App.preferences.show_notifications;
			if (notify) {
				string body = "%d. %s".printf (i+1, this.list.nth_data (i).title);
				new_notification (player.metadata.title, body); // emit signal
			}
		}



		private void player_volume_changed_cb (double val) {

			debug ("volume_changed");
			double cur_val = this.volume_scale.get_value ();
			double new_val = (val / 100);

			if (GLib.Math.fabs (cur_val - new_val) > 0.001)
				set_volume_scale_value (new_val);
		}

		private void set_volume_scale_value (double val) {

			this.volume_scale.value_changed.disconnect (volume_scale_value_changed_cb);
			volume_scale.set_value (val);
			volume_scale.value_changed.connect (volume_scale_value_changed_cb);
		}

		private void player_rate_changed_cb (double val) {

			debug ("rate_changed");
			//this.button_rate_label.label = "%g×".printf (val);
		}



		private void player_metadata_updated_cb () {

			debug ("metadata_changed");
			this.header_main.title =
			   (player.metadata.title != "") ? player.metadata.title : this.basename;

			string artist =
			   (player.metadata.artist != "") ? player.metadata.artist : "";

			string genre =
			    (player.metadata.genre != "") ? player.metadata.genre : "";

			string year = "";
			if (player.metadata.date.length > 3) {
				year = player.metadata.date.substring (0, 4);
			}
			this.header_main.subtitle = "%s   %s   %s".printf (artist, genre, year);
		}



		private void player_end_of_stream_cb () {

			debug ("end of stream");
			was_eos = true;
			player_check_reinit ();
			this.player.load_uri (App.preferences.last_uri);
		}



		private void set_lb_position (double pos) {

			if (this.lb == null) return;

			this.lb.set_position (pos);

			if (audiobook) {
				this.lb.set_time (to_hhmmss (pos - this.current_chapter_offset) );
			} else {
				this.lb.set_time (to_hhmmss (pos) );
			}
		}

		private void set_progress_fraction (double pos) {

			if (this.duration == 0) return;

			if (pos == 0) {
				//var percent
				this.indicator.set_fraction (0);
			} else {
				var val = pos / duration;
				this.indicator.set_fraction (val);
			}
			int persent = calculate_percentage (pos, duration);
			this.indicator.tooltip = "%d%%\n%s / %s".printf (persent,
			                                  to_hhmmss (pos),
			                                  to_hhmmss(this.duration) );
		}

		private int calculate_percentage (double p, double w) {

			int ret = 0;
			if (p > 0 && w > 0)
				ret = (int) GLib.Math.round (100 * p / w);
			return ret;
		}



		private string to_hhmmss (double seconds) {

			string ret = "0:00";
			int hh = 0, mm = 0, ss = 0;

			if (seconds < 0.5)
				return ret;

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

		public double get_rate () {

			return player.get_rate ();
		}

		public double get_volume () {

			return player.get_volume ();
		}

		public void set_volume (double vol) {

			player.set_volume (vol);
		}




	}
}

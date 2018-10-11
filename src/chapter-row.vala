/* chapter-row.vala
 *
 * Copyright 2018 Nick
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

	[GtkTemplate (ui = "/com/gitlab/nvlgit/Balss/chapter-row.ui")]
	public class ChapterRow : Gtk.ListBoxRow {
		[GtkChild] public Gtk.Label number_label;
		[GtkChild] private Gtk.Label time_label;
		[GtkChild] private Gtk.Label title_label;
		[GtkChild] private Gtk.Label duration_label;
		[GtkChild] public Gtk.Scale seekbar;
		[GtkChild] public Gtk.Revealer revealer;
		[GtkChild] public Gtk.Box box;
		public signal void seek_changed (double p);


		[GtkCallback]
		private void seekbar_value_changed_cb () {


			seek_changed (seekbar.get_value () ); //emit signal
		}


		public ChapterRow () {
		}


		public void set_range (double start, double end) {

			this.seekbar.value_changed.disconnect (seekbar_value_changed_cb);
			this.seekbar.set_range (start, end);
			this.seekbar.value_changed.connect (seekbar_value_changed_cb);
		}


		public void set_position (double p) {

			this.seekbar.value_changed.disconnect (seekbar_value_changed_cb);
			this.seekbar.set_value (p);
			this.seekbar.value_changed.connect (seekbar_value_changed_cb);
		}


		public string number {

			get { return number_label.get_text (); }
			set { number_label.set_text (value); }
		}


		public string title {

			get { return title_label.get_text (); }
			set { title_label.set_text (value); }
		}


		public string time {

			get { return time_label.get_text (); }
			set { time_label.set_text (value); }
		}


		public string duration {

			get { return duration_label.get_text (); }
			set { duration_label.set_text (value); }
		}

	}
}

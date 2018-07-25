/* info-display.vala
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
	[GtkTemplate (ui = "/com/gitlab/nvlgit/Balss/info-display.ui")]
	public class InfoDisplay : Gtk.Box {
		[GtkChild] private Gtk.Label title_label;
		[GtkChild] private Gtk.Label total_time_label;
		[GtkChild] private Gtk.Label artist_label;
		[GtkChild] private Gtk.Label genre_label;
		[GtkChild] private Gtk.Label chapter_title_label;
		[GtkChild] private Gtk.Label chapter_index_label;
		[GtkChild] private Gtk.Label chapter_time_label;
		[GtkChild] private Gtk.Label speed_label;

		public InfoDisplay () {
		}

		public string title {
			get { return title_label.get_text (); }
			set { title_label.set_text (value); }
		}

		public string total_time {
			get { return total_time_label.get_text (); }
			set { total_time_label.set_text (value); }
		}

		public string artist {
			get { return artist_label.get_text (); }
			set { artist_label.set_text (value); }
		}

		public string genre {
			get { return genre_label.get_text (); }
			set { genre_label.set_text (value); }
		}

		public string chapter_title {
			get { return chapter_title_label.get_text (); }
			set { chapter_title_label.set_text (value); }
		}

		public string chapter_index {
			get { return chapter_index_label.get_text (); }
			set { chapter_index_label.set_text (value); }
		}

		public string chapter_time {
			get { return chapter_time_label.get_text (); }
			set { chapter_time_label.set_text (value); }
		}

		public string speed {
			get { return speed_label.get_text (); }
			set { speed_label.set_text (value); }
		}
		
		public void clear () {

			speed = "";
			chapter_time = "";
			chapter_index = "";
			chapter_title = "";
			genre = "";
			artist ="";
			total_time = "";
			title = "";
		}

	}
}
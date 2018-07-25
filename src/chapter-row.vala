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
		[GtkChild] private Gtk.Label title_label;
		[GtkChild] private Gtk.Label duration_label;
		[GtkChild] public Gtk.Box box;

		public ChapterRow () {
		}

		public string number {
			get { return number_label.get_text (); }
			set { number_label.set_text (value); }
		}

		public string title {
			get { return title_label.get_text (); }
			set { title_label.set_text (value); }
		}

		public string duration {
			get { return duration_label.get_text (); }
			set { duration_label.set_text (value); }
		}

	}
}
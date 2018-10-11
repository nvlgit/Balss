/* chapter-list-box.vala
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

	[GtkTemplate (ui = "/com/gitlab/nvlgit/Balss/chapter-list-box.ui")]
	public class ChapterListBox : Gtk.Box {

		[GtkChild] private Gtk.ScrolledWindow scrolled_window;
		[GtkChild] private Gtk.ListBox list;
		private Gtk.SizeGroup sizegroup;
		private int last_index;
		public signal void seek_changed (double pos);


		public signal void chapter_row_activated (int index);

		construct {
			sizegroup = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
			last_index = 0;
			//this.list.set_focus_child.connect (set_focus_child_cb);

		}

		public ChapterListBox () {}


		public void set_range (double offset, double end) {

		Gtk.ListBoxRow row = this.list.get_row_at_index (last_index);
		( (Balss.ChapterRow) row).set_range (offset, end);
		}

		public void set_time (string time) {

		Gtk.ListBoxRow row = this.list.get_row_at_index (last_index);
		( (Balss.ChapterRow) row).time = time + " / ";
		}

		public void set_position (double p) {

		Gtk.ListBoxRow row = this.list.get_row_at_index (last_index);
		( (Balss.ChapterRow) row).set_position (p);
		}

		private void add_separators () {

			this.list.set_header_func (update_header_fn);

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

		public void add_row (Balss.ChapterRow row){

			this.list.add (row);
			add_separators ();
			sizegroup.add_widget (row.number_label);
			row.seek_changed.connect ( (p) => {
				seek_changed (p); // Emit signal
			});
		}

		[GtkCallback]
		private void list_box_row_activated_cb (Gtk.ListBoxRow row) {

			int i = row.get_index ();
			chapter_row_activated (i);  //emit signal 
		}

		public void mark_row_at_index (int i) {

			Gtk.ListBoxRow last_row = this.list.get_row_at_index (last_index);
			( (Balss.ChapterRow) last_row).time = "";
			( (Balss.ChapterRow) last_row).revealer.set_reveal_child (false);
			Gtk.StyleContext last_ctx = ( (Balss.ChapterRow) last_row).get_style_context ();
			last_ctx.remove_class ("balss-active-chapter-row");

			Gtk.ListBoxRow row = this.list.get_row_at_index (i);

			( (Balss.ChapterRow) row).revealer.set_reveal_child (true);
			Gtk.StyleContext ctx = ( (Balss.ChapterRow) row).get_style_context ();
			ctx.add_class ("balss-active-chapter-row");
			this.last_index = i;
			GLib.Timeout.add (150, () => { // delay while revealer revealed
			row.grab_focus ();
			return false;
			});
		}
	}
}

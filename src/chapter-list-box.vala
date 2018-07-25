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
		[GtkChild] private Gtk.ListBox list;
		Gtk.SizeGroup sizegroup;

		private int last_index;


		public signal void chapter_row_activated (int index);

		construct {
			sizegroup = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
			last_index = 0;
		}

		public ChapterListBox () {
		}

		public void add_row (Balss.ChapterRow row){

			this.list.add (row);
			sizegroup.add_widget (row.number_label);
		}

		[GtkCallback]
		private void list_box_row_activated_cb (Gtk.ListBoxRow row) {

			int i = row.get_index ();
			chapter_row_activated (i);  //emit signal 
		}

		public void select_row_at_index (int i) {


			Gtk.ListBoxRow last_row = this.list.get_row_at_index (last_index);
			Gtk.StyleContext last_ctx = ( (Balss.ChapterRow) last_row).get_style_context ();
//			last_ctx.remove_class ("mark");
			last_ctx.remove_class ("balss-active-chapter-row");

			Gtk.ListBoxRow row = this.list.get_row_at_index (i);
			Gtk.StyleContext ctx = ( (Balss.ChapterRow) row).get_style_context ();
			ctx.add_class ("balss-active-chapter-row");

			this.last_index = i;
		}

	}
}
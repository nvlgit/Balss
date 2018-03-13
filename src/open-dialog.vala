/* open-dialog.vala
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

	public class OpenDialog : Gtk.FileChooserDialog {

		public OpenDialog () {

        		//this.title = "Open File";
        		this.action = Gtk.FileChooserAction.OPEN;

			this.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
			this.add_button ("_Open", Gtk.ResponseType.ACCEPT);
        		this.set_default_response (Gtk.ResponseType.ACCEPT);

			this.local_only = true;
			this.select_multiple = false;
			this.set_modal (true);
		}

		public string get_file () {

		    string uri;

			var filter = new Gtk.FileFilter ();
			filter.set_filter_name ("m4b books");
			filter.add_pattern ("*.m4b");
			filter.add_pattern ("*.M4B");
			filter.add_pattern ("*.M4b");
			filter.add_pattern ("*.m4B");
			this.add_filter (filter);

			filter = new Gtk.FileFilter ();
			filter.set_filter_name ("All audio files");
			filter.add_mime_type ("audio/*");
			this.add_filter (filter);

			filter = new Gtk.FileFilter ();
			filter.set_filter_name ("All files");
			filter.add_pattern ("*");
			this.add_filter (filter);

			if (this.run () == Gtk.ResponseType.ACCEPT) {
				uri = this.get_uri ();
			} else {
				uri = null;
			}
			return uri;
		}


	}
}

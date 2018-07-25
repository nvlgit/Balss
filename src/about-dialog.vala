/* about-dialog.vala *
 *
 * Copyright (C) 2018 Nick *
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

	public class AppAbout : Gtk.AboutDialog {

		public AppAbout (Gtk.Window window) {

			GLib.Object (transient_for: window, use_header_bar: 1);
			this.set_destroy_with_parent (true);
			this.set_modal (true);

			logo_icon_name = APP_ID;

			this.program_name = "Balss";

			this.version = VERSION;
			this.comments = _("Simple audio book player");
			this.website = "https://github.com/nvlgit/balss";
			this.website_label = null;
			this.copyright = "Copyright © 2018 Nick";

			this.artists = null;
			this.authors = {"Nick", ""};
			this.documenters = null;
			this.translator_credits = null;

			this.license = "GNU Public Licence version 3";
			this.wrap_license = true;
		}
	}
}
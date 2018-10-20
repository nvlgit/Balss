/* chapter-indicator.vala
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

	[GtkTemplate (ui = "/com/gitlab/nvlgit/Balss/chapter-indicator.ui")]
	public class ChapterIndicator : Gtk.Box {

		[GtkChild] private Gtk.DrawingArea area;
		[GtkChild] private Gtk.EventBox event_box;
		[GtkChild] private Gtk.Frame frame;
		[GtkChild] private Gtk.Popover indicator_popover;
		[GtkChild] private Gtk.Label label;
		[GtkChild] private Gtk.Grid tooltip_grid;
		[GtkChild] private Gtk.Label tooltip_persent_label;
		[GtkChild] private Gtk.Label tooltip_time_label;
		[GtkChild] private Gtk.Button button_previous;
		[GtkChild] private Gtk.Button button_next;
		private double _value;
		public signal void button_clicked (int direction);

		construct {

			this._value = 0;
			this.area.draw.connect (draw_cb);
			this.event_box.events |= Gdk.EventMask.BUTTON_PRESS_MASK;
			this.event_box.button_press_event.connect ((event) => {
				debug ("button_press_event.connect");
				indicator_popover.popup ();
				return true;
			});
			this.frame.has_tooltip = true;
			this.frame.query_tooltip.connect ((x, y, keyboard_tooltip, tooltip) => {
				tooltip.set_custom (tooltip_grid);
				return true;
			});
		}

		public ChapterIndicator () {}

		public void clear () {

			this.button_next.sensitive = false;
			this.button_previous.sensitive = false;
			this.label.label = "";
			set_fraction (0);
		}

		public void set_info (int chapter, int count) {

			this.label.label = "%d / %d".printf (chapter, count);
			this.button_previous.sensitive = (chapter == 1) ? false : true;
			this.button_next.sensitive = (chapter == count) ? false : true;
		}

		public void set_tooltip (int persent, string pos, string dur) {

			tooltip_persent_label.label = "%d %%".printf (persent);
			tooltip_time_label.label = "%s / %s".printf (pos, dur);
		}

		public void set_fraction (double val) {

			if (val > 1)
				val = 1;
			this._value = val;

			this.area.queue_draw ();
		}

		private bool draw_cb (Gtk.Widget da, Cairo.Context cr) {

			uint w;
			uint h;
			Gdk.RGBA color;
			Gdk.RGBA selected_color;
			Gtk.StyleContext style_context;

			style_context = area.get_style_context ();
			color = style_context.get_color ( area.get_state_flags () );
			bool result = style_context.lookup_color ("theme_selected_bg_color",
			                                          out selected_color);
			if (!result)
				return false;

			double sum = color.red + color.green + color.blue;
			selected_color.alpha *= (sum < 1) ? 0.2 : 0.5;

			if (_value > 0) {
				_value = double.max (0.01, _value);
			}

			if (_value > 0.99 && _value < 1.0 ) {
				_value = 0.99;
			}

			w = area.get_allocated_width ();
			h = area.get_allocated_height ();

			Gdk.cairo_set_source_rgba (cr, selected_color);
			cr.rectangle(0, 0, w * _value, h);
			cr.fill ();

			return true;
		}
		[GtkCallback] private void button_next_clicked_cb () {
			button_clicked (1);
		}
		[GtkCallback] private void button_previous_clicked_cb () {
			button_clicked (-1);
		}
	}
}

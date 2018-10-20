/* control-button.vala
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

	[GtkTemplate (ui = "/com/gitlab/nvlgit/Balss/control-button.ui")]
	public class ControlMenuButton : Gtk.MenuButton {

		[GtkChild] private Gtk.Scale volume_scale;
		[GtkChild] private Gtk.SpinButton rate_spinbutton;
		[GtkChild] private Gtk.DrawingArea rate_area;
		[GtkChild] private Gtk.Image volume_button_image;
		[GtkChild] private Gtk.Grid tooltip_grid;
		[GtkChild] private Gtk.Label tooltip_rate_label;
		[GtkChild] private Gtk.Label tooltip_volume_label;

		public signal void volume_changed (double val);
		public signal void rate_changed (double val);

		private double _rate;
		private double _volume;

		const string[] ICONS = { "audio-volume-muted-symbolic",
		                         "audio-volume-low-symbolic",
		                         "audio-volume-medium-symbolic",
		                         "audio-volume-high-symbolic" };
		[GtkCallback]
		private void volume_scale_value_changed_cb (Gtk.Range range) {

			volume_changed (range.get_value () ); //Emit signal
		}

		[GtkCallback]
		private void rate_spinbutton_value_changed_cb () {

			rate_changed (rate_spinbutton.value); //Emit signal
		}


		construct {

			_rate = 0.5;
			_volume = 0.5;
			this.rate_area.draw.connect (draw_rate_cb);
			//this.set_tooltip_window (tooltip_window);
			this.has_tooltip = true;
			this.query_tooltip.connect ((x, y, keyboard_tooltip, tooltip) => {
				tooltip.set_custom (tooltip_grid);
				return true;
			});
		}



		public ControlMenuButton () {}



		public double rate {

			get { return this._rate; }
			set {
				 this._rate = value;
				rate_spinbutton.value_changed.disconnect (rate_spinbutton_value_changed_cb);
				rate_spinbutton.set_value (rate);
				rate_spinbutton.value_changed.connect (rate_spinbutton_value_changed_cb);
				GLib.Idle.add ( () => {
					this.rate_area.queue_draw ();
					set_tooltip ();
					return false;
				});

			}
		}



		public double volume {

			get { return this._volume; }
			set {
				 this._volume = value;
				double cur_val = this.volume_scale.get_value ();

				if (GLib.Math.fabs (cur_val - value) > 0.001) {

					volume_scale.value_changed.disconnect (volume_scale_value_changed_cb);
					volume_scale.set_value (value);
					volume_scale.value_changed.connect (volume_scale_value_changed_cb);
				}
				GLib.Idle.add ( () => {
					if (this._volume < 0.05)
						volume_button_image.icon_name = ICONS[0];
					else if (this._volume < 0.45)
						volume_button_image.icon_name = ICONS[1];
					else if (this._volume < 0.95)
						volume_button_image.icon_name = ICONS[2];
					else
						volume_button_image.icon_name = ICONS[3];
					set_tooltip ();
					return false;
				});
			}
		}



		private void set_tooltip () {

			string v = "%d %%".printf (
				   (int) GLib.Math.round (100 * this._volume) );
			string r = "%g ×".printf (this._rate);
			this.tooltip_volume_label.label = v;
			this.tooltip_rate_label.label = r;
		}



		private bool draw_rate_cb (Cairo.Context cr) {

			uint w;
			uint h;
			Gdk.RGBA color;
			Gdk.RGBA dimmed_color;
			Gtk.StyleContext style_context;

			style_context = rate_area.get_style_context ();
			color = style_context.get_color ( rate_area.get_state_flags () );
			dimmed_color = color;
			dimmed_color.alpha *= 0.5;

			if (_rate < 0.5) {
				_rate = 0.5;
			}

			if (_rate > 1.5) {
				_rate = 1.5;
			}

			w = rate_area.get_allocated_width ();
			h = rate_area.get_allocated_height ();
			// coordinates for the center
			double px = uint.min (w, h) / 16.0;
			double xc = w / 2.0;
			double yc = 11 * px;

			double angle_start = 0.95 * GLib.Math.PI;
			double angle_end =   2.05 * GLib.Math.PI;
			double angle_arrow =  (1 + (_rate * 0.5) ) * GLib.Math.PI;

			cr.set_line_width (2 * px);
			cr.set_line_cap (Cairo.LineCap.SQUARE);

			Gdk.cairo_set_source_rgba (cr, color);

			cr.arc (xc, yc, 7 * px, angle_start, angle_arrow - 0.65);
			cr.stroke ();
			int r = (int) GLib.Math.round (_rate * 100);
			Gdk.cairo_set_source_rgba (cr,
			                           (r == 100) ? color : dimmed_color);
			cr.arc (xc, yc, 7 * px, angle_arrow + 0.65 , angle_end);
			cr.stroke ();

			// speedometer arrow
			cr.arc (xc, yc, 2 * px, 0, 360);
			cr.set_line_width (0);
			Gdk.cairo_set_source_rgba (cr, color);
			cr.fill ();
			// triangle
			double x1 = xc + (11 * px * GLib.Math.cos (angle_arrow) );
			double y1 = yc + (11 * px * GLib.Math.sin (angle_arrow) );
			double x2 = xc + ( 2 * px * GLib.Math.cos (angle_arrow - (GLib.Math.PI / 2.0) ) );
			double y2 = yc + ( 2 * px * GLib.Math.sin (angle_arrow - (GLib.Math.PI / 2.0) ) );
			double x3 = xc + ( 2 * px * GLib.Math.cos (angle_arrow + (GLib.Math.PI / 2.0) ) );
			double y3 = yc + ( 2 * px * GLib.Math.sin (angle_arrow + (GLib.Math.PI / 2.0) ) );
			cr.move_to (x1, y1);
			cr.line_to (x2, y2);
			cr.line_to (x3, y3);
			cr.close_path ();
			cr.fill ();

			return true;
		}
	}
}

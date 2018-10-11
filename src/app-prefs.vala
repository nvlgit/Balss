/* app-prefs.vala *
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


	public class Prefs : GLib.Object{

		private GLib.Settings settings;

		private bool   _dark_theme;
		private bool   _play_last;
		private string _last_uri;
		private double _last_position;
		private double _playback_rate;
		private bool   _show_notifications;
		private int    _window_width;
		private int    _window_height;


		public Prefs () {

			settings = new GLib.Settings ("com.gitlab.nvlgit.Balss");

			_dark_theme = settings.get_boolean ("dark-theme");
			_play_last = settings.get_boolean ("play-last");
			_last_uri = settings.get_string ("last-uri");
			_last_position = settings.get_double ("last-position");
			_playback_rate = settings.get_double ("playback-rate");
			_show_notifications = settings.get_boolean ("show-notifications");
			_window_width = settings.get_int ("window-width");
			_window_height = settings.get_int ("window-height");

		}

		public bool dark_theme {

			get { return _dark_theme; }
			set {
				_dark_theme = value;
				settings.set_boolean ("dark-theme", value);
			}
		}

		public bool play_last {

			get { return _play_last; }
			set {
				_play_last = value;
				settings.set_boolean ("play-last", value);
			}
		}

		public string last_uri {

			get { return _last_uri; }
			set {
				_last_uri = value;
				settings.set_string ("last-uri", value);
			}
		}

		public double last_position {

			get { return _last_position; }
			set {
				_last_position = value;
				settings.set_double ("last-position", value);
			}
		}

		public double playback_rate {

			get { return _playback_rate; }
			set {
				_playback_rate = value;
				settings.set_double ("playback-rate", value);
			}
		}

		public bool show_notifications {

			get { return _show_notifications; }
			set {
				_show_notifications = value;
				settings.set_boolean ("show-notifications", value);
			}
		}

		public int window_width {

			get { return _window_width; }
			set {
				_window_width = value;
				settings.set_int ("window-width", value);
			}
		}

		public int window_height {

			get { return _window_height; }
			set {
				_window_height = value;
				settings.set_int ("window-height", value);
			}
		}
	}

}

/* mpv-wrapper-backend.vala
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


	public struct Chapter {

		double offset;
		double end;
		string title;
	}



	public struct Metadata {

		string title;
		string artist;
		string album;
		string album_artist;
		string composer;
		string genre;
		string date;
		string track;
		string disc;
	}



	public class Player : GLib.Object {


		private Mpv.Handle ctx;

		public signal void            volume_changed (double volume);
		public signal void              mute_changed (bool mute);
		public signal void           chapter_changed (int index);
		public signal void             speed_changed (double speed);
		public signal void          duration_changed (double duration);
		public signal void          position_updated (double position);
		public signal void             pause_changed (bool pause);
		public signal void          metadata_updated ();
		public signal void             end_of_stream ();
		public signal void                  shutdown ();

		public Metadata metadata;



		construct {

			// libmpv: The LC_NUMERIC locale category must be set to "C".
			Intl.setlocale (NUMERIC, "C");

			ctx = new Mpv.Handle ();
			set_options ();
			set_observed_properties ();
			ctx.set_wakeup_callback (wakeup_callback);
			ctx.initialize ();
			metadata = Metadata ();
			metadata = { "", "", "", "", "", "", "", "", "" };

		}



		public Player () {}



		public void load_uri (string uri) {

			string[] cmd = {"loadfile", uri };
			check ("1", ctx.command (cmd) );
		}



		public void destroy_context () {

			ctx.terminate_destroy ();
			ctx = null;
		}



		private void set_options () {

			check ("2", ctx.set_option_string ("video",                   "no") );
			check ("3", ctx.set_option_string ("audio-client-name",     APP_ID) );
			check ("4", ctx.set_option_string ("config",                  "no") );
			check ("5", ctx.set_option_string ("title",                    "-") );
			check ("6", ctx.set_option_string ("log-file",    "libmpv-log.txt") ); // for debug
		}



		private void set_observed_properties () {

			check (" 7", ctx.observe_property (0, "duration",         Mpv.Format.DOUBLE) );
			check (" 8", ctx.observe_property (0, "time-pos",         Mpv.Format.DOUBLE) );
			check (" 9", ctx.observe_property (0, "ao-volume",        Mpv.Format.DOUBLE) );
			check ("10", ctx.observe_property (0, "ao-mute",          Mpv.Format.FLAG)   );
			check ("11", ctx.observe_property (0, "pause",            Mpv.Format.FLAG)   );
			check ("12", ctx.observe_property (0, "speed",            Mpv.Format.DOUBLE) );
			check ("13", ctx.observe_property (0, "metadata",         Mpv.Format.NODE)   );
			check ("14", ctx.observe_property (0, "chapter",          Mpv.Format.INT64)  );
		}



		private void wakeup_callback () {

			GLib.Idle.add ( (GLib.SourceFunc) event_handler);
		}



		private bool event_handler () {

			if (ctx == null)
				return false;

			Mpv.Event ev = null;

			while (true) {

				ev = ctx.wait_event (0);

				if (ev.event_id == Mpv.EventID.NONE) { break; }

				if(ev.event_id == Mpv.EventID.PROPERTY_CHANGE) {

					unowned Mpv.EventProperty prop = ( (Mpv.Event<Mpv.EventProperty>) ev).data;

					if ("duration" == prop.name) {
						if (prop.format == Mpv.Format.DOUBLE) {
							double d = *(double*) ( ( (Mpv.EventProperty<double>) prop).data);
							duration_changed (d); // Emit signal
						}
					}

					if ("time-pos" == prop.name) {
						if (prop.format == Mpv.Format.DOUBLE) {
							double pos = *(double*) ( ( (Mpv.EventProperty<double>) prop).data);
							position_updated (pos); // Emit signal
						}
					}

					if ("pause" == prop.name) {
						if (prop.format == Mpv.Format.FLAG) {
							int i = *(int*) ( ( (Mpv.EventProperty<int>) prop).data);
							bool p = (i == 0) ? false : true;
							pause_changed (p); // Emit signal
						}
					}

					if ("ao-volume" == prop.name) {
						if (prop.format == Mpv.Format.DOUBLE) {
							double vol = *(double*) ( ( (Mpv.EventProperty<double>) prop).data);
							volume_changed (vol); // Emit signal
						}
					}

					if ("ao-mute" == prop.name) {
						if (prop.format == Mpv.Format.FLAG) {
							int i = *(int*) ( ( (Mpv.EventProperty<int>) prop).data);
							bool m = (i == 0) ? false : true;
							mute_changed (m); // Emit signal
						}
					}

					if ("metadata" == prop.name) {
						this.get_metadata ();
						metadata_updated (); // Emit signal
					}

					if ("chapter" == prop.name) {
						if (prop.format == Mpv.Format.INT64) {
							int index = (int) *(int64*) ( ( (Mpv.EventProperty<int64>) prop).data);
							chapter_changed (index); // Emit signal
						}
					}

					if ("speed" == prop.name) {
						if (prop.format == Mpv.Format.DOUBLE) {
							double s = *(double*) ( ( (Mpv.EventProperty<double>) prop).data);
							speed_changed (s); // Emit signal
						}
					}
				}

				if(ev.event_id == Mpv.EventID.END_FILE) {
					Mpv.EventEndFile eef = *(Mpv.EventEndFile*) ( (Mpv.Event<Mpv.EventEndFile>) ev).data;
					if (eef.reason == Mpv.EndFileReason.EOF) {
						end_of_stream (); // Emit signal
					}
					if (eef.reason == Mpv.EndFileReason.ERROR) {
						debug ("Playback was terminated abnormally.  ERROR ID %d",
						        eef.error );
					}
					break;
				}

				if(ev.event_id == Mpv.EventID.IDLE) {
					//FIXME
					break;
				}

				if(ev.event_id == Mpv.EventID.SHUTDOWN) {
					shutdown (); // Emit signal
					break;
				}

			}
			return false;
		}



		public void set_previous_chapter () {

			string[] command = {"add", "chapter", "-1"};
			check ("15",
				ctx.command_async (Mpv.EventID.COMMAND_REPLY, command) );
		}



		public void set_next_chapter () {

			string[] command = {"add", "chapter", "1"};
			check ("16",
				ctx.command_async (Mpv.EventID.COMMAND_REPLY, command) );
		}




		public int get_chapter_count () {

			int64 i;
			check ("17",
				ctx.get_property_int64 ("chapters",
				                        Mpv.Format.INT64,
				                        out i) );

			return (int) i;
		}



		public int get_chapter () {

			int64 i;
			check ("19",
				ctx.get_property_int64 ("chapter",
				                        Mpv.Format.INT64,
				                        out i) );

			return (int) i;
		}



		public void set_chapter (int index) {

			int64? i = (int64) index;
			check ("20",
				ctx.set_property_async (Mpv.EventID.NONE,
				                        "chapter",
				                        Mpv.Format.INT64,
				                        i) );
		}



		public double get_position () {

			double p;
			check ("21",
				ctx.get_property_double ("time-pos",
				                         Mpv.Format.DOUBLE,
				                         out p) );
			return (double) p;
		}



		public void set_position (double? p) {

			check ("22",
				ctx.set_property_async (Mpv.EventID.NONE,
				                        "time-pos",
				                        Mpv.Format.DOUBLE,
				                        p) );
		}



		public double get_duration () {

			double d;
			check ("23",
				ctx.get_property_double ("duration",
				                         Mpv.Format.DOUBLE,
				                         out d) );
			return (double) d;
		}



		public bool get_pause () {

			int i;
			check ("24",
				ctx.get_property_flag ("pause",
				                       Mpv.Format.FLAG,
				                       out i) );
			return (bool) (i == 0) ? false : true;
		}



		public void play () {

			set_pause (false);
		}



		public void pause () {

			set_pause (true);
		}



		private void set_pause (bool pause) {

			int? i = (pause == false) ? 0 : 1;
			check ("25",
				ctx.set_property_async (Mpv.EventID.NONE,
				                        "pause",
				                        Mpv.Format.FLAG,
				                        i) );
		}



		public double get_volume () {

			double v;
			check ("26",
				ctx.get_property_double ("ao-volume",
				                         Mpv.Format.DOUBLE,
				                         out v) );

			return (double) v;
		}



		public void set_volume (double? vol) {

			check ("27",
				ctx.set_property_async (Mpv.EventID.NONE,
				                        "ao-volume",
				                        Mpv.Format.DOUBLE,
				                        vol) );
		}



		public bool get_mute () {

			int i;
			check ("28",
				ctx.get_property_flag ("ao-mute",
				                       Mpv.Format.FLAG,
				                       out i) );
			return (bool) (i == 0) ? false : true;
		}



		public void set_mute (bool? mute) {

			int m = (mute == false) ? 0 : 1;
			check ("29",
				ctx.set_property_async (Mpv.EventID.NONE,
				                        "ao-mute",
				                        Mpv.Format.FLAG,
				                        m) );
		}



		public double get_speed () {

			double s;
			check ("30",
				ctx.get_property_flag ("speed",
				                       Mpv.Format.FLAG,
				                       out s) );
			return (double) s;
		}



		public void set_speed (double? speed) {

			check ("31",
				ctx.set_property_async (Mpv.EventID.NONE,
				                        "speed",
				                        Mpv.Format.DOUBLE,
				                        speed) );
		}



		private void get_metadata () {

			Mpv.Node node;
			string key = "";

			check ("32",
				ctx.get_property_node ("metadata", Mpv.Format.NODE, out node) );

			if (node.format == Mpv.Format.NODE_MAP) {
				for (int i = 0; i < node.u_list.num; i++) {
					if (node.u_list.values[i].format == Mpv.Format.STRING) {

						key = node.u_list.keys[i];

						if ("title" == key) {
							metadata.title = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("artist" == key) {
							metadata.artist = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("album" == key) {
							metadata.album = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("album_artist" == key) {
							metadata.album_artist = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("composer" == key) {
							metadata.composer = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("genre" == key) {
							metadata.genre = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("date" == key) {
							metadata.date = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("track" == key) {
							metadata.track = (string) node.u_list.values[i].u_string ?? "";
						}
						if ("disc" == key) {
							metadata.disc = (string) node.u_list.values[i].u_string ?? "";
						}
					}
				}
			}
			check ("33", ctx.set_option_string ("title", metadata.title) );
		}



		public GLib.List<Chapter?>? get_chapter_list () {

			Mpv.Node node;
			string title = "";
			string t = "";
			double offset = 0;
			double o = 0;
			int count = 0;
			bool ready = false;
			var list = new GLib.List<Chapter?> ();
			check ("34",
				ctx.get_property_node ("chapter-list", Mpv.Format.NODE, out node) );

			if(node.format == Mpv.Format.NODE_ARRAY) {
				count = node.u_list.num;
				for (int i = 0; i < count; i++) {
					if (node.u_list.values[i].format == Mpv.Format.NODE_MAP) {
						for (int n = 0; n < node.u_list.values[i].u_list.num; n++) {
							if ("title" == node.u_list.values[i].u_list.keys[n]) {
								if (node.u_list.values[i].u_list.values[n].format == Mpv.Format.STRING) {
									t = (string) node.u_list.values[i].u_list.values[n].u_string;
								}
							} else if ("time" == node.u_list.values[i].u_list.keys[n]) {
								if (node.u_list.values[i].u_list.values[n].format == Mpv.Format.DOUBLE) {
									o = (double) node.u_list.values[i].u_list.values[n].u_double;
								}
							}
						}
						if (ready) {

							Chapter chapter = Chapter ();
							chapter.title = title.strip () ;
							chapter.offset = offset;
							chapter.end = o;
							list.append (chapter);
						} else {

							ready = true;
						}

						title = t;
						offset = o;

						if (count - 1 == i) {

							Chapter chapter = Chapter ();
							chapter.title = t;
							chapter.offset = o;
							chapter.end = get_duration ();
							list.append (chapter);
						}
					}
				}
			}
			return list;
		}



		private void check (string id, Mpv.Error er) {

			if (er != Mpv.Error.SUCCESS)
				debug ("ERROR CODE: %d, id: %s", er, id );
		}

	}
}
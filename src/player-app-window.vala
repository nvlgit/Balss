/* player-app-window.vala
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

using VLC;

namespace Balss {

	[GtkTemplate (ui = "/com/github/nvlgit/Balss/player-app-window.ui")]
	public class PlayerAppWindow : Gtk.ApplicationWindow {

		/*************************************************/

        struct Chapter {

            int64 offset;
            int64 duration;
            string name;
        }

		/*************************************************/

        enum Column {

	        POINTER,
	        NUMBER,
	        NAME,
	        DURATION,
        }

		/*************************************************/

	    private Instance inst;
	    //private Media md;
	    private MediaPlayer mp;
	    private bool audiobook;
	    private string basename;
	    private int win_w;
	    private int win_h;

	    private GLib.Settings settings;

		/*************************************************/

		[GtkChild] private Gtk.Button button_play;
		[GtkChild] private Gtk.Button button_previous;
		[GtkChild] private Gtk.Button button_next;
		[GtkChild] private Gtk.Image pause_image;
		[GtkChild] private Gtk.Image play_image;
		[GtkChild] private Gtk.VolumeButton volume_button;
		[GtkChild] internal Gtk.ProgressBar progress;
		[GtkChild] private Gtk.ListStore list_store;
        [GtkChild] private Gtk.TreeView tree_view;
        [GtkChild] private Gtk.Scale seek_bar;
        /*******  for audiobook  *******/
        [GtkChild] private Gtk.Box info_book_box;
        [GtkChild] private Gtk.Label i_chapter_label;
        [GtkChild] private Gtk.Label total_chapters_label;
        [GtkChild] private Gtk.Label chapter_name_label;
        [GtkChild] private Gtk.Label chapter_time_label;
        [GtkChild] private Gtk.Label chapter_duration_label;
        [GtkChild] private Gtk.Label title_time_label;
        [GtkChild] private Gtk.Label title_duration_label;
        [GtkChild] private Gtk.Label title_label;
        [GtkChild] private Gtk.Label artist_label;
        [GtkChild] private Gtk.Label genre_label;
        [GtkChild] private Gtk.ScrolledWindow chapter_window;
        [GtkChild] private Gtk.Switch chapter_list_switch_button;
        [GtkChild] private Gtk.Image view_list_image;
        [GtkChild] private Gtk.SpinButton playback_rate_spin_button;
        [GtkChild] private Gtk.Label rate_label;
        /*******  for other *******/
        [GtkChild] private Gtk.Box info_other_box;
        [GtkChild] private Gtk.Label disk_other_label;
        [GtkChild] private Gtk.Label disk_total_other_label;
        [GtkChild] private Gtk.Label title_other_label;
        [GtkChild] private Gtk.Label time_other_label;
        [GtkChild] private Gtk.Label duration_other_label;
        [GtkChild] private Gtk.Label track_other_label;
        [GtkChild] private Gtk.Label track_total_other_label;
        [GtkChild] private Gtk.Label album_other_label;
        [GtkChild] private Gtk.Label artist_other_label;
        [GtkChild] private Gtk.Label genre_other_label;
        [GtkChild] private Gtk.Label year_other_label;
        [GtkChild] private Gtk.Label rate_other_label;

		/*************************************************/

		[GtkCallback]
        private bool playback_rate_spin_button_output_cb (Gtk.SpinButton spin){

            var adj = spin.get_adjustment ();
            float val =  (float) adj.get_value ();
            string txt = "%.2f×".printf (val);

                GLib.Idle.add ( () => {

                    ( (Gtk.Entry) spin).set_text (txt);
                    return false;
                });
            return true;
        }

		/*************************************************/

		[GtkCallback]
        private void playback_rate_spin_button_value_changed_cb (){

            float val =  (float) playback_rate_spin_button.get_value ();
            mp.set_rate (val);

            string rate = "%g×".printf (val);

                GLib.Idle.add ( () => {

                    rate_label.set_text (rate);
                    rate_other_label.set_text (rate);
                    return false;
                });

        }

		/*************************************************/

		[GtkCallback]
        private void chapter_list_switch_button_active_notify_cb () {

            if (chapter_list_switch_button.active) {

                GLib.Idle.add ( () => {

                    chapter_window_visible (true);
                    return false;
                });

            } else {

                GLib.Idle.add ( () => {

                    chapter_window_visible (false);
                    return false;
                });
            }
        }

		/*************************************************/

		[GtkCallback]
        private void play_button_clicked_cd () {

            if (mp.state == State.PLAYING)
                mp.pause ();
            else
                mp.play ();
        }

		/*************************************************/

		[GtkCallback]
        private void button_previous_clicked_cb () {


		    //mp.previous_chapter (); //not working properly

            /* workaround */
            if (mp.chapter > 0) {
                var c = get_chapter_info (mp.chapter - 1);
                mp.time = c.offset;
            } else {
		        mp.time = 1;
		    }

        }

		/*************************************************/

		[GtkCallback]
        private void button_next_clicked_cb () {

            mp.next_chapter ();
        }

		/*************************************************/

   		[GtkCallback]
   		private void volume_button_value_changed_cb (double val) {

            var v = (int) GLib.Math.round ( (double) 100 * val);

            if (v < 0)
                v = 0;
            if (v > 100)
                v = 100;

		    mp.volume = v;
		}

		/*************************************************/

		[GtkCallback]
        private void seek_bar_value_changed_cb () {

		    mp.time = (int64) seek_bar.get_value ();

        }

		/*************************************************/

		[GtkCallback]
        private void row_activated_cb(Gtk.TreeView view, Gtk.TreePath path,
                        Gtk.TreeViewColumn col) {

            var i = (int) path.get_indices()[0];
            stdout.printf ("\nrow: %d\n\n", i);

                if (i > 0) {

                    var c = get_chapter_info (i);
                    mp.time = c.offset;

                } else {

		            mp.time = 1;

		        }
        }

		/*************************************************/

        /*                 mp callbacks                  */

		/*************************************************/

		private void mp_playing_cb (Event event) {

		    state_changed_cb (true);
		}

		/*************************************************/

		private void mp_paused_cb (Event event) {

		    state_changed_cb (false);

		}

		/*************************************************/

		private void mp_stopped_cb (Event event) {

		    state_changed_cb (false);

		}

		/*************************************************/

		private void state_changed_cb (bool playing) {

		    if (playing == true) {

                GLib.Idle.add ( () => {

		            play_image.set_visible (false);
		            pause_image.set_visible (true);
		            return false;
		        });

		    } else {

                GLib.Idle.add ( () => {
    		        pause_image.set_visible(false);
    		        play_image.set_visible (true);
    		        return false;
    		    });
		    }
		}

		/*************************************************/
        // FIXME not used:
		private void md_state_changed_cb (Event event) {


            if (event.type == EventType.MEDIA_STATE_CHANGED) {
                State s = (State) event.new_state;
                if (s == State.PLAYING)
        		    state_changed_cb (true);
        		else
        		    state_changed_cb (false);
	        }
		}

		/*************************************************/

		private void mp_position_changed_cb (Event event) {

            double pos = (double) event.new_position;

            GLib.Idle.add ( () => {
                progress.set_fraction (pos);
                return false;
            });
		}

		/*************************************************/

		private void mp_eos_cb  (Event event) {

            stdout.printf ("End of stream\n");
			mp.stop ();
			mp.media.event_manager.detach (EventType.MEDIA_PARSED_CHANGED,
			                         mp_media_parsed_changed_cb);
			detach_mp_events ();
            this.close (); //FIXME

		}

		/*************************************************/

		private void mp_time_changed_cb (Event event) {

            int64 t = (int64) event.new_time;

            string time = ms_to_hhmmss (t);

            if (audiobook) {

                Chapter? c = get_chapter_info (mp.chapter);
                string chapter_time = ms_to_hhmmss (t - c.offset);

                GLib.Idle.add ( () => {

                    seek_bar.value_changed.disconnect (seek_bar_value_changed_cb);
                    seek_bar.set_value (t);
                    seek_bar.value_changed.connect (seek_bar_value_changed_cb);

                    title_time_label.set_text (time);
                    chapter_time_label.set_text (chapter_time);

                    return false;
                });

            } else {

                GLib.Idle.add ( () => {

                    seek_bar.value_changed.disconnect (seek_bar_value_changed_cb);
                    seek_bar.set_value (t);
                    seek_bar.value_changed.connect (seek_bar_value_changed_cb);

                    time_other_label.set_text (time);

                    return false;
                });

            }
		}

		/*************************************************/

		private void mp_chapter_changed_cb (Event event) {

            int i = event.new_chapter;

            GLib.Idle.add ( () => {

                update_chapter_ui_info (i);

                return false;
            });
		}

		/*************************************************/

		private void mp_media_changed_cb () {


			mp.media.event_manager.attach (EventType.MEDIA_PARSED_CHANGED,
			                         mp_media_parsed_changed_cb);


		}

		private void mp_media_parsed_changed_cb () {

            GLib.Idle.add ( () => {

                if (audiobook)
		            update_meta_to_book_info_ui ();
		        else
		            update_meta_to_other_info_ui ();

                return false;
            });
		}

		/*************************************************/

		private void mp_length_changed_cb (Event event) {

		    int64 length = event.new_length;
		    int count = mp.get_chapter_count ();
            string duration = ms_to_hhmmss (length);

            if (count > 0)
                audiobook = true;
            else
                audiobook = false;


            if (audiobook) {

                string total_chapters = count.to_string ();

                GLib.Idle.add ( () => {

                    title_duration_label.set_text (duration);
                    total_chapters_label.set_text (total_chapters);
                    fill_list_store ();
                    update_chapter_ui_info (0);
                    chapter_window_visible (true);
                    update_meta_to_book_info_ui ();
                    show_hide_ui_elements ();

                    return false;
                });

            } else {

                GLib.Idle.add ( () => {

                    update_meta_to_other_info_ui ();
                    seek_bar.set_range (0, length);
                    duration_other_label.set_text (duration);
                    chapter_window_visible (false);
                    show_hide_ui_elements ();

                    return false;
                });
            }
        }

		/*************************************************/

		private void mp_volume_changed_cb (Event event) {

			double cur_val = volume_button.get_value ();
			double new_val = (double) event.volume;

			if (GLib.Math.fabs (cur_val - new_val) > 0.001) {

                GLib.Idle.add ( () => {

    				volume_button.value_changed.disconnect (volume_button_value_changed_cb);
				    volume_button.set_value (new_val);
    				volume_button.value_changed.connect (volume_button_value_changed_cb);

				    return false;
				});
			}
		}

		/*************************************************/

        construct {

            string[]? args = {
                         /*( GLib.Environment.get_prgname () ),*/
                         "--vout", "none",
                         "--novideo",
                         "--no-xlib",
                         "--no-sout-mp4-faststart",
                         "--sout-mux-caching=4096"/*,
                         "-vvv"*/
            };
            audiobook = false;
			inst = new Instance (args);
			inst.set_user_agent (APP_ID + " " + APP_VERISON , "");
			inst.set_app_id (APP_ID, APP_VERISON, APP_ICON);
			mp = new MediaPlayer (inst);
			mp.role = MediaPlayerRole.MUSIC;
			//mp.set_rate (1.0f);
			win_w = 600;
			win_h = 600;

            attach_mp_events ();
        }

		/*************************************************/

		public PlayerAppWindow (Gtk.Application app) {
			GLib.Object (application: app);


		}

		/*************************************************/

		private void attach_mp_events () {

			mp.event_manager.attach (EventType.MEDIA_PLAYER_PLAYING,
			                         mp_playing_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_PAUSED,
			                         mp_paused_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_STOPPED,
			                         mp_stopped_cb);


			mp.event_manager.attach (EventType.MEDIA_PLAYER_MEDIA_CHANGED,
			                         mp_media_changed_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_LENGTH_CHANGED,
			                         mp_length_changed_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_POSITION_CHANGED,
			                         mp_position_changed_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_TIME_CHANGED,
			                         mp_time_changed_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_END_REACHED,
			                         mp_eos_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_CHAPTER_CHANGED,
			                         mp_chapter_changed_cb);
			mp.event_manager.attach (EventType.MEDIA_PLAYER_AUDIO_VOLUME,
			                         mp_volume_changed_cb);

		}

		/*************************************************/

		private void detach_mp_events () {

			mp.event_manager.detach (EventType.MEDIA_PLAYER_PLAYING,
			                         mp_playing_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_PAUSED,
			                         mp_paused_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_STOPPED,
			                         mp_stopped_cb);


			mp.event_manager.detach (EventType.MEDIA_PLAYER_MEDIA_CHANGED,
			                         mp_media_changed_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_LENGTH_CHANGED,
			                         mp_length_changed_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_POSITION_CHANGED,
			                         mp_position_changed_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_TIME_CHANGED,
			                         mp_time_changed_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_END_REACHED,
			                         mp_eos_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_CHAPTER_CHANGED,
			                         mp_chapter_changed_cb);
			mp.event_manager.detach (EventType.MEDIA_PLAYER_AUDIO_VOLUME,
			                         mp_volume_changed_cb);

		}

		/*************************************************/

		public void open (GLib.File file) {

		    basename = file.get_basename ();
		    mp_set_uri (file.get_uri () );

		}

		/*************************************************/

		public void mp_set_uri (string uri) {

				mp.stop ();
				mp.media = new Media.location (inst, uri);
				mp.play ();
		}

		/*************************************************/

        private void update_meta_to_book_info_ui () {

            string? title = mp.media.get_meta (MetaType.TITLE);
            string? artist = mp.media.get_meta (MetaType.ARTIST);
            string? genre = mp.media.get_meta (MetaType.GENRE);

                if (title != null)
                    title_label.set_text (title);
                else
                    title_label.set_text ("");

                if (artist != null)
                    artist_label.set_text (artist);
                else
                    artist_label.set_text ("");

                if (genre != null)
                    genre_label.set_text (genre);
                else
                    genre_label.set_text ("");

        }

		/*************************************************/

        private void update_meta_to_other_info_ui () {

            string? title = mp.media.get_meta (MetaType.TITLE);
            string? artist = mp.media.get_meta (MetaType.ARTIST);
            string? album = mp.media.get_meta (MetaType.ALBUM);
            string? genre = mp.media.get_meta (MetaType.GENRE);
            string? year = mp.media.get_meta (MetaType.DATE);
            string? track = mp.media.get_meta (MetaType.TRACK_NUMBER);
            string? track_total = mp.media.get_meta (MetaType.TRACK_TOTAL);
            string? disk = mp.media.get_meta (MetaType.DISC_NUMBER);
            string? disk_total = mp.media.get_meta (MetaType.DISC_TOTAL);

                if (title != null)
                    title_other_label.set_text (title);
                else
                    title_other_label.set_text ("");

                if (artist != null)
                    artist_other_label.set_text (artist);
                else
                    artist_other_label.set_text ("");

                if (album != null)
                    album_other_label.set_text (album);
                else
                    album_other_label.set_text ("");

                if (year != null)
                    year_other_label.set_text (year);
                else
                    year_other_label.set_text ("");

                if (genre != null)
                    genre_other_label.set_text (genre);
                else
                    genre_other_label.set_text ("");

                if (track != null)
                    track_other_label.set_text (track);
                else
                    track_other_label.set_text ("--");

                if (track_total != null)
                    track_total_other_label.set_text (track_total);
                else
                    track_total_other_label.set_text ("--");

                if (disk != null)
                    disk_other_label.set_text (disk);
                else
                    disk_other_label.set_text ("--");

                if (disk_total != null)
                    disk_total_other_label.set_text (disk_total);
                else
                    disk_total_other_label.set_text ("--");

        }

		/*************************************************/

        private void show_hide_ui_elements () {

                    button_previous.set_sensitive (audiobook);
                    button_next.set_sensitive (audiobook);
                    progress.set_sensitive (audiobook);
                    chapter_window.set_visible (audiobook);
                    info_book_box.set_visible (audiobook);
                    info_other_box.set_visible (!audiobook);
                    chapter_list_switch_button.set_sensitive (audiobook);
                    view_list_image.set_sensitive (audiobook);

        }

		/*************************************************/

        private void chapter_window_visible (bool visible) {

            int w, h;

            if (!visible) {

                this.get_size (out w, out h);
                win_w = w;
                win_h = h;

                chapter_window.set_visible (false);
                this.resize (w, 1);

            } else {

                this.get_size (out w, out h);
                chapter_window.set_visible (true);
                this.resize (w, win_h);
            }

        }

		/*************************************************/

		private void fill_list_store () {

            Gtk.TreeIter iter;

            Chapter? c;

            list_store.clear ();

            int count = mp.get_chapter_count ();

            if (count > 0) {

                for (int i = 0; i < count; i++) {

                    c = get_chapter_info (i);
                    list_store.append (out iter);
	                list_store.set (iter,
	           		                Column.POINTER,   (i == mp.chapter) ? "►" : "",
			                        Column.NUMBER,    (i + 1),
			                        Column.NAME,      c.name,
			                        Column.DURATION,  ms_to_hhmmss (c.duration) );
                }

            }
		}

		/*************************************************/

		private void tree_view_mark_curent_chapter () {

	        Gtk.TreePath path;
	        Gtk.TreeIter iter;

	        Gtk.TreeModel model = tree_view.get_model ();
	        int count = mp.get_chapter_count ();

	        for (int i = 0; i < count; i++) {

         		path = new Gtk.TreePath.from_indices (i);
         		model.get_iter (out iter, path);
		        list_store.set (iter,
		                        Column.POINTER,   (i == mp.chapter) ? "►" : "");
                if (i == mp.chapter)
                    tree_view.set_cursor (path, null, false);
		    }
    	}


		/*************************************************/

		private Chapter? get_chapter_info (int i) {

            ChapterDescription[] pp = null;
            Chapter? c = Chapter ();

            int count = mp.get_full_chapter_descriptions (-1, out pp);

            if (count > i) {
                c.offset =   (int64) pp[i].i_time_offset;
                c.duration = (int64) pp[i].i_duration;
                c.name =    (string) pp[i].psz_name;

                return c;

            } else {

                return null;
            }
        }

		/*************************************************/

	    public string ms_to_hhmmss (int64 msecs) {

		    string ret = "00:00:00";
		    int hh = 0, mm = 0, ss = 0;

		    int64 secs = (int64) GLib.Math.llround ( ( (double) msecs) / 1000);

			hh = (int) secs / (60 * 60);
			mm = (int) secs / 60  - (hh * 60);
			ss = (int) secs % 60;

            if (hh > 0)
		        ret = "%d:%02d:%02d".printf (hh, mm, ss);
		    else
		        ret = "%d:%02d".printf (mm, ss);

		    return ret;
	    }

		/*************************************************/

        private void update_chapter_ui_info (int i) {

            Chapter? c = get_chapter_info (i);


                seek_bar.set_range (c.offset, c.offset + c.duration);
                i_chapter_label.set_text ( (i + 1).to_string () );
                chapter_name_label.set_text (c.name);
                chapter_duration_label.set_text (ms_to_hhmmss (c.duration) );
                tree_view_mark_curent_chapter ();


        }

		/*************************************************/

	}
}

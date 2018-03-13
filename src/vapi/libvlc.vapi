[CCode (cheader_filename = "vlc/vlc.h")]
namespace VLC {

    [CCode (cname = "libvlc_instance_t", ref_function = "libvlc_retain", unref_function = "libvlc_release",
     free_function = "libvlc_free", cprefix = "libvlc_", cheader_filename = "vlc/libvlc.h")]
    public class Instance {

		public static int64 clock();

		[CCode (cname = "libvlc_new")]
		public static Instance ([CCode (array_length_pos = 0.1)] string[]? args = null);
		[CCode (cname = "libvlc_add_intf")]
		public int add_interface (string name);
		//public void set_exit_handler (void (*cb) (void *), void *opaque);
		public void set_user_agent (string name, string http);
		public void set_app_id (string id, string version, string icon);
		public string get_version ();
		public string get_compiler ();
		public string get_changeset ();
    }

    //[CCode (cname = "libvlc_callback_t")]
    public delegate void LibvlcCallback (Event event);

    [CCode (cname = "struct libvlc_event_manager_t", cprefix = "libvlc_event_", cheader_filename = "vlc/libvlc.h")]
    public class EventManager {

		public int attach (EventType type, LibvlcCallback cb);
		public void detach (EventType type, LibvlcCallback cb);
		public static string type_name (EventType type);
    }
   /**
    * A LibVLC event
    */
    [CCode (cname = "struct libvlc_event_t", cheader_filename = "vlc/libvlc_events.h")]
    public struct Event {

		public EventType type;

		[CCode (cname = "p_obj")]
		void* emitter;  //Object emitting the event
		/* media descriptor */
		[CCode (cname = "u.media_meta_changed.meta_type")]
		public MetaType meta_changed;
		[CCode (cname = "u.media_subitem_added.new_child")]
		public Media media_subitem_added;
		[CCode (cname = "u.media_duration_changed.new_duration")]
		public int64 duration_changed;
		[CCode (cname = "u.media_parsed_changed.new_status")]
		public int new_status;
		[CCode (cname = "u.media_freed.md")]
		public Media media_freed;
		[CCode (cname = "u.media_state_changed.new_state")]
		public State new_state;
		[CCode (cname = "u.media_subitemtree_added.item")]
		public Media media_subitemtree_added;
		/* media instance */
		[CCode (cname = "u.media_player_buffering.new_cache")]
		public float new_cache;
		[CCode (cname = "u.media_player_chapter_changed.new_chapter")]
		public int new_chapter;
		[CCode (cname = "u.media_player_position_changed.new_position")]
		public float new_position;
		[CCode (cname = "u.media_player_time_changed.new_time")]
		public int64 new_time;
		[CCode (cname = "u.media_player_title_changed.new_title")]
		public int new_title;
		[CCode (cname = "u.media_player_seekable_changed.new_seekable")]
		public int new_seekable;
		[CCode (cname = "u.media_player_pausable_changed.new_pausable")]
		public int new_pausable;
		[CCode (cname = "u.media_player_scrambled_changed.new_scrambled")]
		public int new_scrambled;
		[CCode (cname = "u.media_player_vout.new_count")]
		public  int new_vout_count;
		/* Length changed */
		[CCode (cname = "u.media_player_length_changed.new_length")]
		public int64 new_length;
		/* Extra MediaPlayer */
		[CCode (cname = "u.media_player_media_changed.new_media")]
		public Media new_media;
		[CCode (cname = "u.media_player_audio_volume.volume")]
		public float volume;
    }


    [CCode (cname = "enum libvlc_event_e", cprefix = "libvlc_", cheader_filename = "vlc/libvlc_events.h")]
    public enum EventType {
		[CCode (cname = "libvlc_MediaMetaChanged")]
		MEDIA_META_CHANGED,
		[CCode (cname = "libvlc_MediaSubItemAdded")]
		MEDIA_SUB_ITEM_ADDED,
		[CCode (cname = "libvlc_MediaDurationChanged")]
		MEDIA_DURATION_CHANGED,
		[CCode (cname = "libvlc_MediaParsedChanged")]
		MEDIA_PARSED_CHANGED,
		[CCode (cname = "libvlc_MediaFreed")]
		MEDIA_FREED,
		[CCode (cname = "libvlc_MediaStateChanged")]
		MEDIA_STATE_CHANGED,
		[CCode (cname = "libvlc_MediaSubItemTreeAdded")]
		MEDIA_SUB_ITEM_TREE_ADDED,


		[CCode (cname = "libvlc_MediaPlayerMediaChanged")]
		MEDIA_PLAYER_MEDIA_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerNothingSpecial")]
		MEDIA_PLAYER_NOTHING_SPECIAL,
		[CCode (cname = "libvlc_MediaPlayerOpening")]
		MEDIA_PLAYER_OPENING,
		[CCode (cname = "libvlc_MediaPlayerBuffering")]
		MEDIA_PLAYER_BUFFERING,
		[CCode (cname = "libvlc_MediaPlayerPlaying")]
		MEDIA_PLAYER_PLAYING,
		[CCode (cname = "libvlc_MediaPlayerPaused")]
		MEDIA_PLAYER_PAUSED,
		[CCode (cname = "libvlc_MediaPlayerStopped")]
		MEDIA_PLAYER_STOPPED,
		[CCode (cname = "libvlc_MediaPlayerForward")]
		MEDIA_PLAYER_FORWARD,
		[CCode (cname = "libvlc_MediaPlayerBackward")]
		MEDIA_PLAYER_BACKWARD,
		[CCode (cname = "libvlc_MediaPlayerEndReached")]
		MEDIA_PLAYER_END_REACHED,
		[CCode (cname = "libvlc_MediaPlayerEncounteredError")]
		MEDIA_PLAYER_ENCOUNTERED_ERROR,
		[CCode (cname = "libvlc_MediaPlayerTimeChanged")]
		MEDIA_PLAYER_TIME_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerPositionChanged")]
		MEDIA_PLAYER_POSITION_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerSeekableChanged")]
		MEDIA_PLAYER_SEEKABLE_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerPausableChanged")]
		MEDIA_PLAYER_PAUSABLE_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerTitleChanged")]
		MEDIA_PLAYER_TITLE_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerSnapshotTaken")]
		MEDIA_PLAYER_SNAPSHOT_TAKEN,
		[CCode (cname = "libvlc_MediaPlayerLengthChanged")]
		MEDIA_PLAYER_LENGTH_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerVout")]
		MEDIA_PLAYER_VOUT,
		[CCode (cname = "libvlc_MediaPlayerScrambledChanged")]
		MEDIA_PLAYER_SCRAMBLED_CHANGED,
		[CCode (cname = "libvlc_MediaPlayerESAdded")]
		MEDIA_PLAYER_ES_ADDED,
		[CCode (cname = "libvlc_MediaPlayerESDeleted")]
		MEDIA_PLAYER_ES_DELETED,
		[CCode (cname = "libvlc_MediaPlayerESSelected")]
		MEDIA_PLAYER_ES_SELECTED,
		[CCode (cname = "libvlc_MediaPlayerCorked")]
		MEDIA_PLAYER_CORKED,
		[CCode (cname = "libvlc_MediaPlayerUncorked")]
		MEDIA_PLAYER_UNCORKED,
		[CCode (cname = "libvlc_MediaPlayerMuted")]
		MEDIA_PLAYER_MUTED,
		[CCode (cname = "libvlc_MediaPlayerUnmuted")]
		MEDIA_PLAYER_UNMUTED,
		[CCode (cname = "libvlc_MediaPlayerAudioVolume")]
		MEDIA_PLAYER_AUDIO_VOLUME,
		[CCode (cname = "libvlc_MediaPlayerAudioDevice")]
		MEDIA_PLAYER_AUDIO_DEVICE,
		[CCode (cname = "libvlc_MediaPlayerChapterChanged")]
		MEDIA_PLAYER_CHAPTER_CHANGED,

		[CCode (cname = "libvlc_MediaListItemAdded")]
		MEDIA_LIST_ITEM_ADDED,
		[CCode (cname = "libvlc_MediaListWillAddItem")]
		MEDIA_LIST_WILL_ADD_ITEM,
		[CCode (cname = "libvlc_MediaListItemDeleted")]
		MEDIA_LIST_ITEM_DELETED,
		[CCode (cname = "libvlc_MediaListWillDeleteItem")]
		MEDIA_LIST_WILL_DELETE_ITEM,
		[CCode (cname = "libvlc_MediaListEndReached")]
		MEDIA_LIST_END_REACHED,

		[CCode (cname = "libvlc_MediaListViewItemAdded")]
		MEDIA_LIST_VIEW_ITEM_ADDED,
		[CCode (cname = "libvlc_MediaListViewWillAddItem")]
		MEDIA_LIST_VIEW_WILL_ADD_ITEM,
		[CCode (cname = "libvlc_MediaListViewItemDeleted")]
		MEDIA_LIST_VIEW_ITEM_DELETED,
		[CCode (cname = "libvlc_MediaListViewWillDeleteItem")]
		MEDIA_LIST_VIEW_WILL_DELETE_ITEM,

		[CCode (cname = "libvlc_MediaListPlayerPlayed")]
		MEDIA_LIST_PLAYER_PLAYED,
		[CCode (cname = "libvlc_MediaListPlayerNextItemSet")]
		MEDIA_LIST_PLAYER_NEXT_ITEM_SET,
		[CCode (cname = "libvlc_MediaListPlayerStopped")]
		MEDIA_LIST_PLAYER_STOPPED,

		[Version (deprecated = true, deprecated_since = "3.0.0")]
		[CCode (cname = "libvlc_MediaDiscovererStarted")]
		MEDIA_DISCOVERER_STARTED,
		[Version (deprecated = true, deprecated_since = "3.0.0")]
		[CCode (cname = "libvlc_MediaDiscovererEnded")]
		MEDIA_DISCOVERER_ENDED,

		[CCode (cname = "libvlc_RendererDiscovererItemAdded")]
		RENDERER_DISCOVERER_ITED_ADDED,
		[CCode (cname = "libvlc_RendererDiscovererItemDeleted")]
		RENDERER_DISCOVERER_ITED_DELETED,

		[CCode (cname = "libvlc_VlmMediaAdded")]
		VLM_MEDIA_ADDED,
		[CCode (cname = "libvlc_VlmMediaRemoved")]
		VLM_MEDIA_REMOVED,
		[CCode (cname = "libvlc_VlmMediaChanged")]
		VLM_MEDIA_CHANGED,
		[CCode (cname = "libvlc_VlmMediaInstanceStarted")]
		VLM_MEDIA_INSTANCE_STARTED,
		[CCode (cname = "libvlc_VlmMediaInstanceStopped")]
		VLM_MEDIA_INSTANCE_STOPPED,
		[CCode (cname = "libvlc_VlmMediaInstanceStatusInit")]
		VLM_MEDIA_INSTANCE_STATUS_INIT,
		[CCode (cname = "libvlc_VlmMediaInstanceStatusOpening")]
		VLM_MEDIA_INSTANCE_STATUS_OPENING,
		[CCode (cname = "libvlc_VlmMediaInstanceStatusPlaying")]
		VLM_MEDIA_INSTANCE_STATUS_PLAYING,
		[CCode (cname = "libvlc_VlmMediaInstanceStatusPause")]
		VLM_MEDIA_INSTANCE_STATUS_PAUSE,
		[CCode (cname = "libvlc_VlmMediaInstanceStatusEnd")]
		VLM_MEDIA_INSTANCE_STATUS_END,
		[CCode (cname = "libvlc_VlmMediaInstanceStatusError")]
		VLM_MEDIA_INSTANCE_STATUS_ERROR
    }


    [CCode (cname = "enum libvlc_state_t",cprefix = "libvlc_",  cheader_filename = "vlc/libvlc_media.h")]
    public enum State {

		[CCode (cname = "libvlc_NothingSpecial")]
		NOTHING_SPECIAL,
		[CCode (cname = "libvlc_Opening")]
		OPENING,
		[CCode (cname = "libvlc_Buffering")]
		BUFFERING,
		[CCode (cname = "libvlc_Playing")]
		PLAYING,
		[CCode (cname = "libvlc_Paused")]
		PAUSED,
		[CCode (cname = "libvlc_Stopped")]
		STOPPED,
		[CCode (cname = "libvlc_Ended")]
		ENDED,
		[CCode (cname = "libvlc_Error")]
		ERROR
    }

    [CCode (cname = "libvlc_meta_t", cheader_filename = "vlc/libvlc_media.h")]
    public enum MetaType {

		[CCode (cname = "libvlc_meta_Title")]
		TITLE,
		[CCode (cname = "libvlc_meta_Artist")]
		ARTIST,
		[CCode (cname = "libvlc_meta_Genre")]
		GENRE,
		[CCode (cname = "libvlc_meta_Copyright")]
		COPYRIGHT,
		[CCode (cname = "libvlc_meta_Album")]
		ALBUM,
		[CCode (cname = "libvlc_meta_TrackNumber")]
		TRACK_NUMBER,
		[CCode (cname = "libvlc_meta_Description")]
		DESCRIPTION,
		[CCode (cname = "libvlc_meta_Rating")]
		RATING,
		[CCode (cname = "libvlc_meta_Date")]
		DATE,
		[CCode (cname = "libvlc_meta_Setting")]
		SETTING,
		[CCode (cname = "libvlc_meta_URL")]
		URL,
		[CCode (cname = "libvlc_meta_Language")]
		LANGUAGE,
		[CCode (cname = "libvlc_meta_NowPlaying")]
		NOW_PLAYING,
		[CCode (cname = "libvlc_meta_Publisher")]
		PUBLISHER,
		[CCode (cname = "libvlc_meta_EncodedBy")]
		ENCODED_BY,
		[CCode (cname = "libvlc_meta_ArtworkURL")]
		ARTWORK_URL,
		[CCode (cname = "libvlc_meta_TrackID")]
		TRACK_ID,
		[CCode (cname = "libvlc_meta_TrackTotal")]
		TRACK_TOTAL,
		[CCode (cname = "libvlc_meta_Director")]
		DERECTOR,
		[CCode (cname = "libvlc_meta_Season")]
		SEASON,
		[CCode (cname = "libvlc_meta_Episode")]
		EPISODE,
		[CCode (cname = "libvlc_meta_ShowName")]
		SHOW_NAME,
		[CCode (cname = "libvlc_meta_Actors")]
		ACTORS,
		[CCode (cname = "libvlc_meta_AlbumArtist")]
		ALBUM_ARTIST,
		[CCode (cname = "libvlc_meta_DiscNumber")]
		DISC_NUMBER,
		[CCode (cname = "libvlc_meta_DiscTotal")]
		DISC_TOTAL
    }

    [CCode (cname = "struct libvlc_media_t",ref_function = "libvlc_media_retain",
     unref_function = "libvlc_media_release", cprefix = "libvlc_media_", cheader_filename = "vlc/libvlc_media.h")]
    public class Media {

		public EventManager event_manager {
			[CCode (cname = "libvlc_media_event_manager")]
			get;
		}
		[CCode(cname = "libvlc_media_new_location")]
		public Media.location (Instance i, string location);
		[CCode(cname = "libvlc_media_new_path")]
		public Media.path (Instance i, string path);
		public void add_option (string psz_options);
		public void add_option_flag (string psz_options, uint i_flags);
		public string get_mrl ();
		public Media duplicate ();
		public string get_meta (MetaType type);
		public void set_meta (MetaType type, string psz_value);
		public bool save_meta ();
		public State get_state ();
		public bool get_stats (MediaStats p_stats);
		public int64 get_duration ();
		public void parse_with_options (MediaParseFlag parse_flag, int timeout);
		public void parse_stop ();
		public MediaParsedStatus get_parsed_status ();
		public void set_user_data (void *user_data);
		public void *get_user_data ();
		public void *user_data {get; set;}
		public string meta {get; set;}
    }

    [CCode (cname = "libvlc_media_player_t",
    ref_function = "libvlc_media_player_retain",
    unref_function = "libvlc_media_player_release",
    cprefix = "libvlc_media_player_")]
    public class MediaPlayer {

		public EventManager event_manager {
			[CCode (cname = "libvlc_media_player_event_manager")]
			get;
		}
		[CCode(cname = "libvlc_media_player_new")]
		public MediaPlayer (Instance i);
		[CCode(cname = "libvlc_media_player_new_from_media")]
		public MediaPlayer.from_media (Media media);
		public void set_media (Media media);
		public Media get_media ();
		public bool is_playing ();
		public int play ();
		public void set_pause (int do_pause);
		public void pause ();
		public void stop ();
		public int64 get_length (); // Get the current movie length (in ms).
		public int64 get_time (); // Get the current movie time (in ms).
		public void set_time (int64 time); // Set the movie time (in ms).
		public float get_position (); // Get movie position as percentage between 0.0 and 1.0.
		public void set_position (float pos); //Set movie position as percentage between 0.0 and 1.0.
		public void set_chapter (int chapter);
		public int get_chapter ();
		public int get_chapter_count ();
		public int get_chapter_count_for_title ();
		public int get_full_chapter_descriptions (int i_chapters_of_title,
                                                          [CCode (array_length = false)]
                                                          out ChapterDescription[] pp_chapters);
		public void previous_chapter (); // Set previous chapter (if applicable)
		public void next_chapter (); // Set next chapter (if applicable)
		public bool will_play ();  //Is the player able to play
		public int get_title ();
		public void set_title (int title);
		public int get_title_count ();
		public float get_rate ();
		public void set_rate (float rate);
		public State get_state ();
		public float get_fps ();
		public uint has_vout ();
		public bool is_seekable ();
		public bool can_pause ();
		public void next_frame ();
		[CCode (cname = "libvlc_audio_get_volume")]
		public int get_volume ();
		[CCode (cname = "libvlc_audio_set_volume")]
		public int set_volume (int volume);
		[CCode (cname = "libvlc_audio_get_mute")]
		public int get_mute ();
		[CCode (cname = "libvlc_audio_set_mute")]
		public void set_mute ();
		[CCode (cname = "libvlc_audio_toggle_mute")]
		public void toggle_mute ();

		public int title {get; set;}
		public int chapter {get; set;}
		public float position {get; set;}
		public int64 time {get; set;}
		public Media media {get; set;}
		public State state {
			[CCode (cname = "libvlc_media_player_get_state")]
			get;  //current state of the media player (playing, paused, ...)
		}
		public int volume {
			[CCode (cname = "libvlc_audio_get_volume")]
			get;
			[CCode (cname = "libvlc_audio_set_volume")]
			set;
		}
		public MediaPlayerRole role {
			[CCode (cname = "libvlc_media_player_get_role")]
			get;
			[CCode (cname = "libvlc_media_player_set_role")]
			set;
		}
		public int set_role (MediaPlayerRole role);

    }

    [CCode(cname = "struct libvlc_chapter_description_t", ref_function = "",
     unref_function = "libvlc_chapter_descriptions_release", cheader_filename = "vlc/libvlc_media_player.h")]
    public class ChapterDescription {

		public int64 i_time_offset; /**< time-offset of the chapter in milliseconds */
		public int64 i_duration; /**< duration of the chapter in milliseconds */
		public string psz_name; /**< chapter name */
    }

   // [CCode (cname = "libvlc_chapter_descriptions_release")]
    //[Compact]
    //public void chapter_descriptions_release ([CCode (array_length = false)] ChapterDescription[] description, uint i_count);


    [CCode(cname = "struct libvlc_track_description_t", ref_function = "",
     unref_function = "libvlc_track_description_list_release",
     cheader_filename = "vlc/libvlc_media_player.h")]
    public class TrackDescription {

		public int i_id;
		public string psz_name;
		public TrackDescription p_next;
    }

    [CCode (cname = "enum libvlc_media_player_role", cheader_filename = "vlc/libvlc_media_player.h")]
    public enum MediaPlayerRole {

		[CCode (cname = "libvlc_role_None")]
		NONE,
		[CCode (cname = "libvlc_role_Music")]
		MUSIC,
		[CCode (cname = "libvlc_role_Video")]
		VIDEO,
		[CCode (cname = "libvlc_role_Communication")]
		COMMUNICATION,
		[CCode (cname = "libvlc_role_Game")]
		GAME,
		[CCode (cname = "libvlc_role_Notification")]
		NOTIFICATION,
		[CCode (cname = "libvlc_role_Animation")]
		ANIMATION,
		[CCode (cname = "libvlc_role_Production")]
		PRODUCTION,
		[CCode (cname = "libvlc_role_Accessibility")]
		ACCESSIBILITY,
		[CCode (cname = "libvlc_role_Test")]
		TEST
    }

    [CCode (cname = "enum libvlc_media_parse_flag_t", cheader_filename = "vlc/libvlc_media.h")]
    public enum MediaParseFlag {

		[CCode (cname = "libvlc_media_parse_local")]
		PARSE_LOCAL,
		[CCode (cname = "libvlc_media_parse_network")]
		PARSE_NETWORK,
		[CCode (cname = "libvlc_media_fetch_local")]
		FETCH_LOCAL,
		[CCode (cname = "libvlc_media_fetch_network")]
		FETCH_NETWORK,
		[CCode (cname = "libvlc_media_do_interact")]
		DO_INTERACT
    }

    [CCode (cname = "enum libvlc_media_parsed_status_t", cheader_filename = "vlc/libvlc_media.h")]
    public enum MediaParsedStatus {

		[CCode (cname = "libvlc_media_parsed_status_skipped")]
		SKIPPED,
		[CCode (cname = "libvlc_media_parsed_status_failed")]
		FAILED,
		[CCode (cname = "libvlc_media_parsed_status_timeout")]
		TIMEOUT,
		[CCode (cname = "libvlc_media_parsed_status_done")]
		DONE
    }

    [CCode (cname = "struct libvlc_media_stats_t", cheader_filename = "vlc/libvlc_media.h")]
    public struct MediaStats {

	        /* Input */
		public int         i_read_bytes;
		public float       f_input_bitrate;

		/* Demux */
		public int         i_demux_read_bytes;
		public float       f_demux_bitrate;
		public int         i_demux_corrupted;
		public int         i_demux_discontinuity;

		/* Decoders */
		public int         i_decoded_video;
		public int         i_decoded_audio;

		/* Video Output */
		public int         i_displayed_pictures;
		public int         i_lost_pictures;

		/* Audio output */
		public int         i_played_abuffers;
		public int         i_lost_abuffers;

		/* Stream output */
		public int         i_sent_packets;
		public int         i_sent_bytes;
		public float f_send_bitrate;
    }


}

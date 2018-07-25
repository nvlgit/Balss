[CCode (cheader_filename = "mpv/client.h")]
namespace Mpv {

	[CCode (cname = "enum mpv_error", cprefix = "MPV_ERROR_")]
	public enum Error {

		SUCCESS,              // No error happened
		EVENT_QUEUE_FULL,     // The event ringbuffer is full. This means the client is choked, and can't receive any events
		NOMEM,                // Memory allocation failed
		UNINITIALIZED,        // The mpv core wasn't configured and initialized yet.
		INVALID_PARAMETER,    // Generic catch-all error if a parameter is set to an invalid or unsupported value.
		OPTION_NOT_FOUND,     // Trying to set an option that doesn't exist.
		OPTION_FORMAT,        // Trying to set an option using an unsupported MPV_FORMAT.
		OPTION_ERROR,         // Setting the option failed. Typically this happens if the provided option value could not be parsed.
		PROPERTY_NOT_FOUND,   // The accessed property doesn't exist.
		PROPERTY_FORMAT,      // Trying to set or get a property using an unsupported MPV_FORMAT.
		PROPERTY_UNAVAILABLE, // The property exists, but is not available.
		PROPERTY_ERROR,       // Error setting or getting a property.
		COMMAND,              // General error when running a command with mpv_command and similar. 
		LOADING_FAILED,       // Generic error on loading (usually used with mpv_event_end_file.error)
		AO_INIT_FAILED,       // Initializing the audio output failed
		VO_INIT_FAILED,       // Initializing the video output failed
		NOTHING_TO_PLAY,      // There was no audio or video data to play
		UNKNOWN_FORMAT,       // When trying to load the file, the file format could not be determined, or the file was too broken to open it.
		UNSUPPORTED,          // Generic error for signaling that certain system requirements are not fulfilled.
		NOT_IMPLEMENTED,      // The API function which was called is a stub only
		GENERIC               // Unspecified error
	}

	[CCode (cname = "enum mpv_format", has_type_id = false, cprefix = "MPV_FORMAT_")]
	public enum Format {

		NONE,
		STRING,
		OSD_STRING,
		FLAG,
		INT64,
		DOUBLE,
		NODE,
		NODE_ARRAY,
		NODE_MAP,
		BYTE_ARRAY
	}

	[CCode (cname = "enum mpv_event_id", has_type_id = false, cprefix = "MPV_EVENT_")]
	public enum EventID {

		NONE,
		SHUTDOWN,
		LOG_MESSAGE,
		GET_PROPERTY_REPLY,
		SET_PROPERTY_REPLY,
		COMMAND_REPLY,
		START_FILE,
		END_FILE,
		FILE_LOADED,
		IDLE,
		TICK,
		CLIENT_MESSAGE,
		VIDEO_RECONFIG,
		AUDIO_RECONFIG,
		SEEK,
		PLAYBACK_RESTART,
		PROPERTY_CHANGE,
		QUEUE_OVERFLOW,
		HOOK,
		//depricated
		TRACKS_CHANGED,
		TRACK_SWITCHED,
		PAUSE,
		UNPAUSE,
		SCRIPT_INPUT_DISPATCH,
		METADATA_UPDATE,
		CHAPTER_CHANGE,
	}

	[CCode (cname = "enum mpv_end_file_reason", has_type_id = false, cprefix = "MPV_END_FILE_REASON_")]
	public enum EndFileReason {

		EOF,
		STOP,
		QUIT,
		ERROR,
		REDIRECT,
	}

	[CCode (cname = "enum mpv_log_level", has_type_id = false, cprefix = "MPV_LOG_LEVEL_")]
	public enum LogLevel {

		NONE,    /// "no"    - disable absolutely all messages
		FATAL,   /// "fatal" - critical/aborting errors
		ERROR,   /// "error" - simple errors
		WARN,    /// "warn"  - possible problems
		INFO,    /// "info"  - informational message
		V    ,   /// "v"     - noisy informational message
		DEBUG,   /// "debug" - very noisy technical information
		TRACE    /// "trace" - extremely noisy
	}

	[Compact]
	[CCode (cname = "struct mpv_event_property", unref_function ="", free_function ="", copy_function = "")]
	public class EventProperty<T> {

		public string name;
		public Mpv.Format format;
		public unowned T data;
	}

	[CCode (cname = "struct mpv_event_log_message")]
	public struct EventLogMessage {

		public string prefix;
		public string level;
		public string text;
		public Mpv.LogLevel log_level;
	}

	[Compact]
	[CCode (cname = "struct mpv_event", unref_function ="", free_function ="", copy_function = "")]
	public class Event<T> {

		public Mpv.EventID event_id;
		public int error;
		public uint64 reply_userdata;
		public unowned T data;
	}

	[CCode (cname = "struct mpv_event_end_file")]
	public struct EventEndFile {

		public Mpv.EndFileReason reason;
		public Mpv.Error error;
	}

	[CCode (cname = "struct mpv_event_client_message")]
	public struct EventClientMessage {

		public int num_args;
		public string[] args;
	}

	[CCode (cname = "struct mpv_event_hook")]
	public struct EventHook {

		public string name;
		public uint64 id;
	}

	[Compact]
	[CCode (cname = "struct mpv_node_list", destroy_function = "", unref_function = "", free_function = "", copy_function = "")]
	public class NodeList {

		public int num;                // Number of entries. Negative values are not allowed.
		[CCode (array_length = false)]
		public weak Mpv.Node[] values; // Mpv.Format.NODE_ARRAY: values[N] refers to value of the Nth item
		                               // Mpv.Format.NODE_MAP: values[N] refers to value of the Nth key/value pair
		[CCode (array_length = false)]
		public string[] keys;          // Mpv.Format.NODE_MAP: keys[N] refers to key of the Nth key/value pair.
	}

	[Compact]
	[CCode (cname = "struct mpv_byte_array", destroy_function = "")]
	public class ByteArray {
		[CCode (array_length_cname = "size", array_length_type = "size_t")]
		public uint8[] data;
	}

	[Compact]
	[CCode (cname = "struct mpv_node", destroy_function = "", free_function = "mpv_free_node_contents")]
	public struct Node {

		[CCode (cname = "u.string")]
		public string u_string;
		[CCode (cname = "u.flag")]
		public int u_flag;
		[CCode (cname = "u.int64")]
		public int64 u_int64;
		[CCode (cname = "u.double_")]
		public double u_double;
		[CCode (cname = "u.list")]
		public weak Mpv.NodeList u_list;
		[CCode (cname = "u.ba")]
		public Mpv.ByteArray u_ba;
		public Mpv.Format format;
		//[CCode (cname = "mpv_free_node_contents")]
		//public void free_node_contents ();

	}

	[Compact]
	[CCode (cname = "mpv_handle", has_type_id = false, ref_function = "", cprefix = "mpv_", unref_function ="", free_function = "mpv_free")]
	public class Handle {

		[CCode (cname = "mpv_create")]
		public Handle ();

		public string client_name {
			[CCode (cname = "mpv_client_name")] get;
		}
		public Mpv.Error initialize ();
		public void terminate_destroy ();
		public string load_config_file (string filename);
		public int64 get_time_us();
		public Mpv.Error set_option (string name, Mpv.Format format);
		public Mpv.Error set_option_string (string name, string data);
		public Mpv.Error command ([CCode (array_length = false)] string[]? args = null);
		public Mpv.Error command_node (Node args, Node result);
		public Mpv.Error command_string (string args);
		public Mpv.Error command_async (uint64 reply_userdata, [CCode (array_length = false)] string[]? args = null);
		public Mpv.Error command_node_async (uint64 reply_userdata, Mpv.Node args);
		[CCode (simple_generics = true, has_target = false)]
		public Mpv.Error set_property<T> (string name, Mpv.Format format, T data);
		public Mpv.Error set_property_string (string name, string data);
		[CCode (simple_generics = true, has_target = false)]
		public Mpv.Error set_property_async<T> (uint64 reply_userdata, string name, Mpv.Format format, T data);

		[CCode (cname = "mpv_get_property", simple_generics = true, has_target = false)]
		public Mpv.Error get_property_double (string name, Mpv.Format format, out double data);

		[CCode (cname = "mpv_get_property", simple_generics = true, has_target = false)]
		public Mpv.Error get_property_flag (string name, Mpv.Format format, out int data);

		[CCode (cname = "mpv_get_property", simple_generics = true, has_target = false)]
		public Mpv.Error get_property_int64 (string name, Mpv.Format format, out int64 data);

		[CCode (cname = "mpv_get_property", simple_generics = true, has_target = false)]
		public Mpv.Error get_property_node (string name, Mpv.Format format, out Mpv.Node data); //FIXME

		public string get_property_string (string name);
		public string get_property_osd_string (string name);
		[CCode (simple_generics = true, has_target = false)]
		public Mpv.Error get_property_async<T> (uint64 reply_userdata, string name, Mpv.Format format, T data);
		public Mpv.Error observe_property (uint64 reply_userdata, string name, Mpv.Format format);
		public Mpv.Error unobserve_property (uint64 reply_userdata);
		public Mpv.Error request_event (EventID event, bool enable);
		public Mpv.Error request_log_messages (string min_level);
		public Event? wait_event (double timeout);
		public void wakeup ();
		public void wait_async_requests ();
		public Mpv.Error hook_add (uint64 reply_userdata, string name, int priority);
		public Mpv.Error hook_continue (uint64 id);
		//[CCode (cname = "cb", has_target = true, simple_generics = true)]
		//public delegate void CB (void *d);
		//[CCode (cname = "mpv_set_wakeup_callback", simple_generics = true, has_target =true)]
		public void set_wakeup_callback (CallBack callback);
	}
	[CCode (cname = "cb", simple_generics = true, has_target = true)]
	public delegate void CallBack ();

	[CCode (cname = "mpv_free_node_contents")]
	public void free_node_contents (Node node);
	[CCode (cname = "mpv_event_name")]
	public string event_name (EventID event_id);


}

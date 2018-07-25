/* main.vala
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

[CCode(cname="VERSION")]         extern const string VERSION;
[CCode(cname="APP_ID")]          extern const string APP_ID;
[CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
[CCode(cname="LOCALEDIR")]       extern const string LOCALEDIR;


public static int main (string[] args) {

	Intl.setlocale (LocaleCategory.ALL, "");
	Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
	Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
	Intl.textdomain (GETTEXT_PACKAGE);

	var app = new Balss.App ();
	return app.run (args);
}
/*
using MPV;

public static int main (string[] args) {

	var mpv = new Handle ();
	mpv.set_option_string("input-default-bindings", "yes");
	mpv.initialize ();
	string[] cmd = {"loadfile", args[1]};
	mpv.command (cmd);
	stdout.printf ("Client name: %s\n", mpv.client_name);

	// get updates when these properties change
	mpv.observe_property(0, "playback-time", MPV.Format.DOUBLE);
	mpv.observe_property(0, "ao-volume", MPV.Format.DOUBLE);
	mpv.observe_property(0, "sid", MPV.Format.INT64);
	mpv.observe_property(0, "aid", MPV.Format.INT64);
	mpv.observe_property(0, "sub-visibility", MPV.Format.FLAG);
	mpv.observe_property(0, "ao-mute", MPV.Format.FLAG);
	mpv.observe_property(0, "core-idle", MPV.Format.FLAG);
	mpv.observe_property(0, "paused-for-cache", MPV.Format.FLAG);

	while (true) {
		Event event = mpv.wait_event(10000);

		stdout.printf("event: %d\n", event.event_id );
		if (event.event_id == EventID.SHUTDOWN)
			break;
	}

	mpv.terminate_destroy ();
	return 0;
} */
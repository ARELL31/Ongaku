namespace Ongaku {
    public class PreferencesWindow : Adw.PreferencesWindow {
        private Settings settings;
        public PreferencesWindow(Gtk.Window parent) {
            Object(modal: true, transient_for: parent, title: "Preferences");
            settings = new Settings();
            setup_ui();
        }
        private void setup_ui() {
            var general_page = new Adw.PreferencesPage();
            general_page.set_title("General");
            general_page.set_icon_name("preferences-system-symbolic");
            add(general_page);
            var download_group = new Adw.PreferencesGroup();
            download_group.set_title("Download Settings");
            download_group.set_description("Configure download behavior and formats");
            general_page.add(download_group);
            create_content_type_row(download_group);
            create_audio_format_row(download_group);
            create_video_format_row(download_group);
            create_video_quality_row(download_group);
            var quality_group = new Adw.PreferencesGroup();
            quality_group.set_title("Quality Settings");
            quality_group.set_description("Set preferred quality and resolution");
            general_page.add(quality_group);
            create_audio_quality_row(quality_group);
            create_max_resolution_row(quality_group);
            var spotify_group = new Adw.PreferencesGroup();
            spotify_group.set_title("Spotify Settings");
            spotify_group.set_description("SpotDL-specific configuration");
            general_page.add(spotify_group);
            create_spotify_bitrate_row(spotify_group);
            create_spotify_format_row(spotify_group);
            create_spotify_output_template_row(spotify_group);
            create_spotify_playlist_numbering_row(spotify_group);
            create_spotify_lyrics_row(spotify_group);
            create_spotify_metadata_row(spotify_group);
            var behavior_group = new Adw.PreferencesGroup();
            behavior_group.set_title("Behavior");
            behavior_group.set_description("Application behavior settings");
            general_page.add(behavior_group);
            create_clear_url_row(behavior_group);
            create_embed_thumbnail_row(behavior_group);

            var auth_page = create_authentication_page();
            add(auth_page);
        }

        private Adw.PreferencesPage create_authentication_page() {
            var page = new Adw.PreferencesPage();
            page.set_title("Authentication");
            page.set_icon_name("dialog-password-symbolic");

            var cookies_group = new Adw.PreferencesGroup();
            cookies_group.set_title("YouTube Authentication");
            cookies_group.set_description("Configure cookies for YouTube and YouTube Music downloads");

            var cookies_row = new Adw.ActionRow();
            cookies_row.set_title("Cookies File Path");
            cookies_row.set_subtitle("Custom location for your cookies.txt file");

            var cookies_entry = new Gtk.Entry();
            cookies_entry.set_placeholder_text("~/.config/ongaku/cookies.txt");
            cookies_entry.set_text(settings.get_cookies_path());
            cookies_entry.set_hexpand(true);

            var browse_button = new Gtk.Button();
            browse_button.set_icon_name("folder-open-symbolic");
            browse_button.add_css_class("flat");
            browse_button.set_tooltip_text("Browse for cookies file");

            var cookies_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
            cookies_box.append(cookies_entry);
            cookies_box.append(browse_button);

            cookies_row.add_suffix(cookies_box);

            var auto_update_row = new Adw.SwitchRow();
            auto_update_row.set_title("Auto-update from browser");
            auto_update_row.set_subtitle("Extract cookies automatically from installed browsers");
            auto_update_row.set_active(settings.get_auto_update_cookies());

            cookies_entry.changed.connect(() => {
                settings.set_cookies_path(cookies_entry.get_text());
            });

            auto_update_row.notify["active"].connect(() => {
                settings.set_auto_update_cookies(auto_update_row.get_active());
            });

            browse_button.clicked.connect(() => {
                var dialog = new Gtk.FileDialog();
                dialog.set_title("Select Cookies File");
                dialog.set_modal(true);

                dialog.open.begin(this, null, (obj, res) => {
                    try {
                        var file = dialog.open.end(res);
                        if (file != null) {
                            cookies_entry.set_text(file.get_path());
                        }
                    } catch (Error e) {
                        print("Error selecting file: %s\n", e.message);
                    }
                });
            });

            cookies_group.add(cookies_row);
            cookies_group.add(auto_update_row);
            page.add(cookies_group);

            return page;
        }

        private void create_content_type_row(Adw.PreferencesGroup group) {
            var content_type_row = new Adw.ComboRow();
            content_type_row.set_title("Content Type");
            content_type_row.set_subtitle("What to download by default");
            var model = new Gtk.StringList(null);
            model.append("Audio Only");
            model.append("Video");
            model.append("Both (separate files)");
            content_type_row.set_model(model);
            content_type_row.set_selected(settings.get_content_type());
            content_type_row.notify["selected"].connect(() => {
                settings.set_content_type((int)content_type_row.get_selected());
            });
            group.add(content_type_row);
        }
        private void create_audio_format_row(Adw.PreferencesGroup group) {
            var audio_format_row = new Adw.ComboRow();
            audio_format_row.set_title("Audio Format");
            audio_format_row.set_subtitle("Preferred audio format for extraction");
            var model = new Gtk.StringList(null);
            model.append("MP3");
            model.append("AAC");
            model.append("FLAC");
            model.append("OGG");
            model.append("WAV");
            model.append("M4A");
            audio_format_row.set_model(model);
            audio_format_row.set_selected(settings.get_audio_format());
            audio_format_row.notify["selected"].connect(() => {
                settings.set_audio_format((int)audio_format_row.get_selected());
            });
            group.add(audio_format_row);
        }
        private void create_video_format_row(Adw.PreferencesGroup group) {
            var video_format_row = new Adw.ComboRow();
            video_format_row.set_title("Video Format");
            video_format_row.set_subtitle("Preferred video container format");
            var model = new Gtk.StringList(null);
            model.append("MP4");
            model.append("MKV");
            model.append("WEBM");
            model.append("AVI");
            model.append("MOV");
            video_format_row.set_model(model);
            video_format_row.set_selected(settings.get_video_format());
            video_format_row.notify["selected"].connect(() => {
                settings.set_video_format((int)video_format_row.get_selected());
            });
            group.add(video_format_row);
        }
        private void create_video_quality_row(Adw.PreferencesGroup group) {
            var quality_row = new Adw.ComboRow();
            quality_row.set_title("Video Quality");
            quality_row.set_subtitle("Maximum video resolution to download");
            var model = new Gtk.StringList(null);
            model.append("Best Available");
            model.append("4K (2160p)");
            model.append("1440p");
            model.append("1080p");
            model.append("720p");
            model.append("480p");
            model.append("360p");
            quality_row.set_model(model);
            quality_row.set_selected(settings.get_video_quality());
            quality_row.notify["selected"].connect(() => {
                settings.set_video_quality((int)quality_row.get_selected());
            });
            group.add(quality_row);
        }
        private void create_audio_quality_row(Adw.PreferencesGroup group) {
            var quality_row = new Adw.ComboRow();
            quality_row.set_title("Audio Quality");
            quality_row.set_subtitle("Audio bitrate preference");
            var model = new Gtk.StringList(null);
            model.append("Best Available");
            model.append("320 kbps");
            model.append("256 kbps");
            model.append("192 kbps");
            model.append("128 kbps");
            model.append("96 kbps");
            quality_row.set_model(model);
            quality_row.set_selected(settings.get_audio_quality());
            quality_row.notify["selected"].connect(() => {
                settings.set_audio_quality((int)quality_row.get_selected());
            });
            group.add(quality_row);
        }
        private void create_spotify_bitrate_row(Adw.PreferencesGroup group) {
            var bitrate_row = new Adw.ComboRow();
            bitrate_row.set_title("Spotify Audio Bitrate");
            bitrate_row.set_subtitle("SpotDL-specific audio bitrate");
            var model = new Gtk.StringList(null);
            model.append("320k");
            model.append("256k");
            model.append("192k");
            model.append("128k");
            model.append("96k");
            bitrate_row.set_model(model);
            bitrate_row.set_selected(settings.get_spotify_bitrate());
            bitrate_row.notify["selected"].connect(() => {
                settings.set_spotify_bitrate((int)bitrate_row.get_selected());
            });
            group.add(bitrate_row);
        }
        private void create_spotify_format_row(Adw.PreferencesGroup group) {
            var format_row = new Adw.ComboRow();
            format_row.set_title("Spotify Audio Format");
            format_row.set_subtitle("Output format for Spotify downloads");
            var model = new Gtk.StringList(null);
            model.append("MP3");
            model.append("FLAC");
            model.append("OGG");
            model.append("M4A");
            format_row.set_model(model);
            format_row.set_selected(settings.get_spotify_format());
            format_row.notify["selected"].connect(() => {
                settings.set_spotify_format((int)format_row.get_selected());
            });
            group.add(format_row);
        }
        private void create_spotify_output_template_row(Adw.PreferencesGroup group) {
            var template_row = new Adw.ComboRow();
            template_row.set_title("Filename Template");
            template_row.set_subtitle("How to name downloaded files");
            var model = new Gtk.StringList(null);
            model.append("{artist} - {title}");
            model.append("{title} - {artist}");
            model.append("{artist}/{album}/{title}");
            model.append("{album}/{artist} - {title}");
            model.append("{title}");
            template_row.set_model(model);
            template_row.set_selected(settings.get_spotify_template());
            template_row.notify["selected"].connect(() => {
                settings.set_spotify_template((int)template_row.get_selected());
            });
            group.add(template_row);
        }
        private void create_spotify_playlist_numbering_row(Adw.PreferencesGroup group) {
            var numbering_row = new Adw.SwitchRow();
            numbering_row.set_title("Playlist Track Numbers");
            numbering_row.set_subtitle("Add track numbers to playlist downloads");
            numbering_row.set_active(settings.get_spotify_playlist_numbering());
            numbering_row.notify["active"].connect(() => {
                settings.set_spotify_playlist_numbering(numbering_row.get_active());
            });
            group.add(numbering_row);
        }
        private void create_spotify_lyrics_row(Adw.PreferencesGroup group) {
            var lyrics_row = new Adw.SwitchRow();
            lyrics_row.set_title("Download Lyrics");
            lyrics_row.set_subtitle("Embed synchronized lyrics when available");
            lyrics_row.set_active(settings.get_spotify_lyrics());
            lyrics_row.notify["active"].connect(() => {
                settings.set_spotify_lyrics(lyrics_row.get_active());
            });
            group.add(lyrics_row);
        }
        private void create_spotify_metadata_row(Adw.PreferencesGroup group) {
            var metadata_row = new Adw.SwitchRow();
            metadata_row.set_title("Rich Metadata");
            metadata_row.set_subtitle("Include detailed metadata and album art");
            metadata_row.set_active(settings.get_spotify_metadata());
            metadata_row.notify["active"].connect(() => {
                settings.set_spotify_metadata(metadata_row.get_active());
            });
            group.add(metadata_row);
        }
        private void create_max_resolution_row(Adw.PreferencesGroup group) {
            var res_row = new Adw.SpinRow.with_range(144, 4320, 1);
            res_row.set_title("Custom Max Resolution");
            res_row.set_subtitle("Custom maximum height in pixels (0 = no limit)");
            res_row.set_value(settings.get_max_resolution());
            res_row.notify["value"].connect(() => {
                settings.set_max_resolution((int)res_row.get_value());
            });
            group.add(res_row);
        }
        private void create_clear_url_row(Adw.PreferencesGroup group) {
            var clear_row = new Adw.SwitchRow();
            clear_row.set_title("Clear URL After Download");
            clear_row.set_subtitle("Automatically clear the URL field after successful download");
            clear_row.set_active(settings.get_clear_url_after_download());
            clear_row.notify["active"].connect(() => {
                settings.set_clear_url_after_download(clear_row.get_active());
            });
            group.add(clear_row);
        }
        private void create_embed_thumbnail_row(Adw.PreferencesGroup group) {
            var thumbnail_row = new Adw.SwitchRow();
            thumbnail_row.set_title("Embed Thumbnails");
            thumbnail_row.set_subtitle("Embed video thumbnails as album art in audio files");
            thumbnail_row.set_active(settings.get_embed_thumbnails());
            thumbnail_row.notify["active"].connect(() => {
                settings.set_embed_thumbnails(thumbnail_row.get_active());
            });
            group.add(thumbnail_row);
        }
    }
}


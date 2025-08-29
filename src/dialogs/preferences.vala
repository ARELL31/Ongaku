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


            var behavior_group = new Adw.PreferencesGroup();
            behavior_group.set_title("Behavior");
            behavior_group.set_description("Application behavior settings");
            general_page.add(behavior_group);

            create_clear_url_row(behavior_group);
            create_embed_thumbnail_row(behavior_group);
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


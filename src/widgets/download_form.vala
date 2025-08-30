namespace Ongaku {
    public class DownloadForm : Gtk.Box {
        public signal void download_requested(string url, string directory, bool is_playlist);
        private Gtk.Entry url_entry;
        private Gtk.Entry directory_entry;
        private Gtk.Button folder_button;
        private Gtk.Button download_button;
        private Gtk.Label status_label;
        private Gtk.Label url_type_label;
        private Gtk.Label instructions;
        private Gtk.Label? directory_status_label = null;
        private string? selected_directory = null;
        private string current_platform = "youtube";

        public DownloadForm() {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 20);
            setup_ui();
            setup_signals();
        }

        private void setup_ui() {
            margin_top = 20;
            margin_bottom = 20;
            margin_start = 20;
            margin_end = 20;
            create_form_widgets();
        }

        private void create_form_widgets() {
            instructions = new Gtk.Label("Paste YouTube URL:");
            instructions.set_halign(Gtk.Align.START);
            instructions.add_css_class("title-4");
            append(instructions);

            var url_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
            url_entry = new Gtk.Entry();
            url_entry.set_placeholder_text("https://www.youtube.com/watch?v=... or playlist URLs");
            url_entry.set_hexpand(true);
            url_box.append(url_entry);

            url_type_label = new Gtk.Label("");
            url_type_label.set_halign(Gtk.Align.START);
            url_type_label.add_css_class("caption");
            url_type_label.add_css_class("dim-label");
            url_type_label.set_visible(false);
            url_box.append(url_type_label);
            append(url_box);

            create_directory_selector();

            download_button = new Gtk.Button.with_label("Download");
            download_button.add_css_class("suggested-action");
            download_button.add_css_class("pill");
            download_button.set_hexpand(true);
            append(download_button);

            status_label = new Gtk.Label("Ready to download");
            status_label.set_halign(Gtk.Align.START);
            status_label.set_wrap(true);
            append(status_label);
        }

        private void create_directory_selector() {
            var directory_section = new Gtk.Box(Gtk.Orientation.VERTICAL, 8);

            var directory_header = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            var directory_label = new Gtk.Label("💾 Save to:");
            directory_label.set_halign(Gtk.Align.START);
            directory_label.add_css_class("heading");
            directory_header.append(directory_label);

            var spacer = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            spacer.set_hexpand(true);
            directory_header.append(spacer);

            var quick_folders_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 4);

            var music_button = new Gtk.Button();
            music_button.set_icon_name("folder-music-symbolic");
            music_button.set_tooltip_text("Music folder");
            music_button.add_css_class("flat");
            music_button.clicked.connect(() => {
                set_directory(GLib.Environment.get_user_special_dir(GLib.UserDirectory.MUSIC));
            });

            var downloads_button = new Gtk.Button();
            downloads_button.set_icon_name("folder-download-symbolic");
            downloads_button.set_tooltip_text("Downloads folder");
            downloads_button.add_css_class("flat");
            downloads_button.clicked.connect(() => {
                set_directory(GLib.Environment.get_user_special_dir(GLib.UserDirectory.DOWNLOAD));
            });

            var desktop_button = new Gtk.Button();
            desktop_button.set_icon_name("user-desktop-symbolic");
            desktop_button.set_tooltip_text("Desktop");
            desktop_button.add_css_class("flat");
            desktop_button.clicked.connect(() => {
                set_directory(GLib.Environment.get_user_special_dir(GLib.UserDirectory.DESKTOP));
            });

            quick_folders_box.append(music_button);
            quick_folders_box.append(downloads_button);
            quick_folders_box.append(desktop_button);
            directory_header.append(quick_folders_box);

            directory_section.append(directory_header);

            var directory_input_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 8);

            directory_entry = new Gtk.Entry();
            directory_entry.set_text(Ongaku.FileUtils.get_default_music_directory());
            directory_entry.set_hexpand(true);
            directory_entry.set_placeholder_text("Select or type download folder path...");
            directory_entry.set_editable(true);
            directory_entry.changed.connect(on_directory_entry_changed);
            directory_input_box.append(directory_entry);

            folder_button = new Gtk.Button();
            folder_button.set_icon_name("folder-open-symbolic");
            folder_button.set_tooltip_text("Browse folders");
            folder_button.add_css_class("flat");
            directory_input_box.append(folder_button);

            var create_folder_button = new Gtk.Button();
            create_folder_button.set_icon_name("folder-new-symbolic");
            create_folder_button.set_tooltip_text("Create new folder");
            create_folder_button.add_css_class("flat");
            create_folder_button.clicked.connect(on_create_folder_clicked);
            directory_input_box.append(create_folder_button);

            directory_section.append(directory_input_box);

            directory_status_label = new Gtk.Label("");
            directory_status_label.set_halign(Gtk.Align.START);
            directory_status_label.add_css_class("caption");
            directory_status_label.add_css_class("dim-label");
            directory_status_label.set_visible(false);
            directory_section.append(directory_status_label);

            append(directory_section);
        }

        private void set_directory(string? path) {
            if (path != null && GLib.FileUtils.test(path, GLib.FileTest.IS_DIR)) {
                selected_directory = path;
                directory_entry.set_text(path);
                validate_directory(path);
            }
        }

        private void on_directory_entry_changed() {
            string path = directory_entry.get_text().strip();
            if (path.length > 0) {
                selected_directory = path;
                validate_directory(path);
            }
        }

        private void validate_directory(string path) {
            if (directory_status_label == null) return;

            if (!GLib.FileUtils.test(path, GLib.FileTest.EXISTS)) {
                directory_status_label.set_text("⚠ Directory does not exist");
                directory_status_label.add_css_class("error");
                directory_status_label.remove_css_class("success");
                directory_status_label.set_visible(true);
                return;
            }

            if (!GLib.FileUtils.test(path, GLib.FileTest.IS_DIR)) {
                directory_status_label.set_text("⚠ Path is not a directory");
                directory_status_label.add_css_class("error");
                directory_status_label.remove_css_class("success");
                directory_status_label.set_visible(true);
                return;
            }

            string display_path = get_display_path(path);
            directory_status_label.set_text("✓ " + display_path);
            directory_status_label.remove_css_class("error");
            directory_status_label.add_css_class("success");
            directory_status_label.set_visible(true);
        }

        private string get_display_path(string path) {
            string home_dir = GLib.Environment.get_home_dir();
            if (path.has_prefix(home_dir)) {
                return "~" + path.substring(home_dir.length);
            }
            return path;
        }

        private void on_create_folder_clicked() {
            var dialog = new Adw.AlertDialog("Create New Folder", "Enter the name for the new folder:");
            dialog.add_response("cancel", "Cancel");
            dialog.add_response("create", "Create");
            dialog.set_response_appearance("create", Adw.ResponseAppearance.SUGGESTED);

            var entry = new Gtk.Entry();
            entry.set_placeholder_text("Enter folder name...");
            dialog.set_extra_child(entry);

            dialog.response.connect((response_id) => {
                if (response_id == "create") {
                    string folder_name = entry.get_text().strip();
                    if (folder_name.length > 0) {
                        create_new_folder(folder_name);
                    }
                }
            });

            dialog.present(get_root() as Gtk.Window);
        }

        private void create_new_folder(string folder_name) {
            string base_path = selected_directory ?? GLib.Environment.get_home_dir();
            string new_folder_path = GLib.Path.build_filename(base_path, folder_name);

            try {
                var dir = GLib.File.new_for_path(new_folder_path);
                dir.make_directory();
                set_directory(new_folder_path);
                set_status("Created folder: " + folder_name);
            } catch (Error e) {
                set_status("Error creating folder: " + e.message);
            }
        }

        private void on_folder_button_clicked() {
            var window = get_root() as Gtk.Window;
            var dialog = new Gtk.FileDialog();
            dialog.set_title("Select Download Directory");

            if (selected_directory != null && GLib.FileUtils.test(selected_directory, GLib.FileTest.IS_DIR)) {
                try {
                    var initial_folder = GLib.File.new_for_path(selected_directory);
                    dialog.set_initial_folder(initial_folder);
                } catch (Error e) {
                    var home_folder = GLib.File.new_for_path(GLib.Environment.get_home_dir());
                    dialog.set_initial_folder(home_folder);
                }
            }

            dialog.select_folder.begin(window, null, (obj, res) => {
                try {
                    GLib.File? folder = dialog.select_folder.end(res);
                    if (folder != null) {
                        set_directory(folder.get_path());
                    }
                } catch (Error e) {
                    set_status("Error selecting folder: " + e.message);
                }
            });
        }

        public void set_platform_mode(string platform) {
            this.current_platform = platform;
            update_ui_for_platform();
        }

        public void set_placeholder_text(string text) {
            if (url_entry != null) {
                url_entry.set_placeholder_text(text);
            }
        }

        private void update_ui_for_platform() {
            switch (current_platform) {
                case "spotify":
                    instructions.set_text("Paste Spotify URL:");
                    url_entry.set_placeholder_text("https://open.spotify.com/track/... or playlist/album URLs");
                    break;
                case "youtube-music":
                    instructions.set_text("Paste YouTube Music URL:");
                    url_entry.set_placeholder_text("https://music.youtube.com/... (processed via SpotDL)");
                    break;
                default:
                    instructions.set_text("Paste YouTube URL:");
                    url_entry.set_placeholder_text("https://www.youtube.com/watch?v=... or playlist URLs");
                    break;
            }
            on_url_changed();
        }

        private void setup_signals() {
            folder_button.clicked.connect(on_folder_button_clicked);
            download_button.clicked.connect(on_download_button_clicked);
            url_entry.activate.connect(on_download_button_clicked);
            url_entry.changed.connect(on_url_changed);
        }

        private void on_url_changed() {
            string url = url_entry.get_text().strip();
            if (url.length == 0) {
                url_type_label.set_visible(false);
                download_button.set_label("Download");
                return;
            }

            switch (current_platform) {
                case "spotify":
                    handle_spotify_url(url);
                    break;
                case "youtube-music":
                    handle_youtube_music_url(url);
                    break;
                default:
                    handle_youtube_url(url);
                    break;
            }
        }

        private void handle_spotify_url(string url) {
            if (!is_valid_spotify_url(url)) {
                url_type_label.set_text("⚠ Invalid Spotify URL");
                url_type_label.set_visible(true);
                url_type_label.remove_css_class("success");
                url_type_label.remove_css_class("accent");
                url_type_label.add_css_class("error");
                download_button.set_label("Download");
                return;
            }

            if (url.contains("/playlist/")) {
                url_type_label.set_text("🎵 Spotify playlist detected");
                download_button.set_label("Download Playlist");
                url_type_label.add_css_class("accent");
            } else if (url.contains("/album/")) {
                url_type_label.set_text("💿 Spotify album detected");
                download_button.set_label("Download Album");
                url_type_label.add_css_class("accent");
            } else if (url.contains("/track/")) {
                url_type_label.set_text("🎶 Spotify track detected");
                download_button.set_label("Download Track");
                url_type_label.add_css_class("success");
            } else {
                url_type_label.set_text("🎵 Spotify content detected");
                download_button.set_label("Download");
                url_type_label.add_css_class("success");
            }
            url_type_label.remove_css_class("error");
            url_type_label.set_visible(true);
        }

        private void handle_youtube_music_url(string url) {
            if (!is_valid_youtube_music_url(url)) {
                url_type_label.set_text("⚠ Invalid YouTube Music URL");
                url_type_label.set_visible(true);
                url_type_label.remove_css_class("success");
                url_type_label.remove_css_class("accent");
                url_type_label.add_css_class("error");
                download_button.set_label("Download");
                return;
            }

            if (url.contains("playlist")) {
                url_type_label.set_text("🎵 YouTube Music playlist (via SpotDL)");
                download_button.set_label("Download Playlist");
                url_type_label.add_css_class("accent");
            } else {
                url_type_label.set_text("🎶 YouTube Music track (via SpotDL)");
                download_button.set_label("Download Track");
                url_type_label.add_css_class("success");
            }
            url_type_label.remove_css_class("error");
            url_type_label.set_visible(true);
        }

        private void handle_youtube_url(string url) {
            if (!is_valid_youtube_url(url)) {
                url_type_label.set_text("⚠ Invalid YouTube URL");
                url_type_label.set_visible(true);
                url_type_label.remove_css_class("success");
                url_type_label.remove_css_class("accent");
                url_type_label.add_css_class("error");
                download_button.set_label("Download");
                return;
            }

            bool is_playlist = detect_playlist_url(url);
            if (is_playlist) {
                url_type_label.set_text("📋 Playlist detected - will download all videos");
                download_button.set_label("Download Playlist");
                url_type_label.add_css_class("accent");
            } else {
                url_type_label.set_text("🎵 Single video detected");
                download_button.set_label("Download MP3");
                url_type_label.add_css_class("success");
            }
            url_type_label.remove_css_class("error");
            url_type_label.set_visible(true);
        }

        private bool is_valid_youtube_url(string url) {
            return url.contains("youtube.com") || url.contains("youtu.be");
        }

        private bool is_valid_spotify_url(string url) {
            return url.contains("spotify.com") || url.contains("open.spotify.com");
        }

        private bool is_valid_youtube_music_url(string url) {
            return url.contains("music.youtube.com");
        }

        private bool detect_playlist_url(string url) {
            switch (current_platform) {
                case "spotify":
                    return url.contains("/playlist/") || url.contains("/album/");
                case "youtube-music":
                    return url.contains("playlist") || url.contains("&list=");
                default:
                    return url.contains("playlist?list=") ||
                           url.contains("&list=") ||
                           (url.contains("watch?v=") && url.contains("&list="));
            }
        }

        private void on_download_button_clicked() {
            string url = url_entry.get_text().strip();
            if (url.length == 0) {
                set_status("Please enter a valid URL.");
                return;
            }

            bool is_valid = false;
            string error_message = "";

            switch (current_platform) {
                case "spotify":
                    is_valid = is_valid_spotify_url(url);
                    error_message = "Please enter a valid Spotify URL.";
                    break;
                case "youtube-music":
                    is_valid = is_valid_youtube_music_url(url);
                    error_message = "Please enter a valid YouTube Music URL.";
                    break;
                default:
                    is_valid = is_valid_youtube_url(url);
                    error_message = "Please enter a valid YouTube URL.";
                    break;
            }

            if (!is_valid) {
                set_status(error_message);
                return;
            }

            string directory = selected_directory ?? Ongaku.FileUtils.get_default_music_directory();
            bool is_playlist = detect_playlist_url(url);

            download_requested(url, directory, is_playlist);
        }

        public void set_status(string message) {
            status_label.set_text(message);
        }

        public new void set_sensitive(bool sensitive) {
            download_button.set_sensitive(sensitive);
            folder_button.set_sensitive(sensitive);
            url_entry.set_sensitive(sensitive);
        }

        public void clear_url() {
            url_entry.set_text("");
            on_url_changed();
        }

        public string get_current_platform() {
            return current_platform;
        }
    }
}


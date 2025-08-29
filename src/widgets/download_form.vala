namespace Ongaku {
    public class DownloadForm : Gtk.Box {
        public signal void download_requested(string url, string directory, bool is_playlist);

        private Gtk.Entry url_entry;
        private Gtk.Entry directory_entry;
        private Gtk.Button folder_button;
        private Gtk.Button download_button;
        private Gtk.Label status_label;
        private Gtk.Label url_type_label;
        private string? selected_directory = null;

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

            var instructions = new Gtk.Label("Paste YouTube URL:");
            instructions.set_halign(Gtk.Align.START);
            instructions.add_css_class("title-4");
            append(instructions);


            var url_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);

            url_entry = new Gtk.Entry();
            url_entry.set_placeholder_text("https://www.youtube.com/watch?v=... or https://www.youtube.com/playlist?list=...");
            url_entry.set_hexpand(true);
            url_box.append(url_entry);


            url_type_label = new Gtk.Label("");
            url_type_label.set_halign(Gtk.Align.START);
            url_type_label.add_css_class("caption");
            url_type_label.add_css_class("dim-label");
            url_type_label.set_visible(false);
            url_box.append(url_type_label);

            append(url_box);


            var directory_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
            var directory_label = new Gtk.Label("Save to:");
            directory_label.set_halign(Gtk.Align.START);
            directory_box.append(directory_label);

            directory_entry = new Gtk.Entry();
            directory_entry.set_text(Ongaku.FileUtils.get_default_music_directory());
            directory_entry.set_hexpand(true);
            directory_entry.set_editable(false);
            directory_box.append(directory_entry);

            folder_button = new Gtk.Button.with_label("Browse");
            directory_box.append(folder_button);

            append(directory_box);


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

            if (!is_valid_youtube_url(url)) {
                url_type_label.set_text("⚠ Invalid YouTube URL");
                url_type_label.set_visible(true);
                url_type_label.remove_css_class("success");
                url_type_label.add_css_class("error");
                download_button.set_label("Download");
                return;
            }

            bool is_playlist = detect_playlist_url(url);

            if (is_playlist) {
                url_type_label.set_text("Playlist detected - will download all videos");
                download_button.set_label("Download Playlist");
                url_type_label.add_css_class("accent");
            } else {
                url_type_label.set_text("Single video detected");
                download_button.set_label("Download MP3");
                url_type_label.add_css_class("success");
            }

            url_type_label.remove_css_class("error");
            url_type_label.set_visible(true);
        }

        private bool is_valid_youtube_url(string url) {
            return url.contains("youtube.com") || url.contains("youtu.be");
        }

        private bool detect_playlist_url(string url) {

            return url.contains("playlist?list=") ||
                   url.contains("&list=") ||
                   url.contains("watch?v=") && url.contains("&list=");
        }

        private void on_folder_button_clicked() {
            var window = get_root() as Gtk.Window;
            var dialog = new Gtk.FileDialog();
            dialog.set_title("Select download directory");

            if (selected_directory != null) {
                try {
                    var initial_folder = File.new_for_path(selected_directory);
                    dialog.set_initial_folder(initial_folder);
                } catch (Error e) {
                    var home_folder = File.new_for_path(Environment.get_home_dir());
                    dialog.set_initial_folder(home_folder);
                }
            }

            dialog.select_folder.begin(window, null, (obj, res) => {
                try {
                    File? folder = dialog.select_folder.end(res);
                    if (folder != null) {
                        selected_directory = folder.get_path();
                        directory_entry.set_text(selected_directory);
                    }
                } catch (Error e) {
                    print("Error selecting folder: %s\n", e.message);
                }
            });
        }

        private void on_download_button_clicked() {
            string url = url_entry.get_text().strip();

            if (url.length == 0) {
                set_status("Please enter a valid URL.");
                return;
            }

            if (!is_valid_youtube_url(url)) {
                set_status("Please enter a valid YouTube URL.");
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
    }
}


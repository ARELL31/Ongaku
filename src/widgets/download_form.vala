namespace Ongaku {
    public class DownloadForm : Gtk.Box {
        public signal void download_requested(string url, string directory, bool is_playlist);

        private Adw.ToggleGroup toggle_group;
        private Gtk.Entry url_entry;
        private Gtk.Entry directory_entry;
        private Gtk.Button folder_button;
        private Gtk.Button download_button;
        private Gtk.Label status_label;
        private Gtk.Box form_container;
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

            create_toggle_group();
            create_form_widgets();
            update_form_content();
        }

        private void create_toggle_group() {
            var toggle_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            toggle_container.set_halign(Gtk.Align.CENTER);

            toggle_group = new Adw.ToggleGroup();
            toggle_group.add_css_class("flat");
            toggle_group.add_css_class("round");
            toggle_group.set_homogeneous(true);

            var toggle_mp3 = new Adw.Toggle();
            toggle_mp3.set_label("Download MP3");
            toggle_mp3.set_icon_name("audio-x-generic-symbolic");
            toggle_mp3.set_name("mp3");
            toggle_group.add(toggle_mp3);

            var toggle_playlist = new Adw.Toggle();
            toggle_playlist.set_label("Download Playlist");
            toggle_playlist.set_icon_name("folder-music-symbolic");
            toggle_playlist.set_name("playlist");
            toggle_group.add(toggle_playlist);

            toggle_group.set_active_name("mp3");
            toggle_container.append(toggle_group);
            append(toggle_container);

            form_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 15);
            append(form_container);
        }

        private void create_form_widgets() {
            url_entry = new Gtk.Entry();
            url_entry.set_hexpand(true);

            directory_entry = new Gtk.Entry();
            directory_entry.set_text(Ongaku.FileUtils.get_default_music_directory());
            directory_entry.set_hexpand(true);
            directory_entry.set_editable(false);

            folder_button = new Gtk.Button.with_label("Browse");

            download_button = new Gtk.Button();
            download_button.add_css_class("suggested-action");
            download_button.add_css_class("pill");
            download_button.set_hexpand(true);

            status_label = new Gtk.Label("Ready to download");
            status_label.set_halign(Gtk.Align.START);
            status_label.set_wrap(true);
        }

        private void setup_signals() {
            toggle_group.notify["active-name"].connect(update_form_content);
            folder_button.clicked.connect(on_folder_button_clicked);
            download_button.clicked.connect(on_download_button_clicked);
            url_entry.activate.connect(on_download_button_clicked);
        }

        private void update_form_content() {

            while (form_container.get_first_child() != null) {
                form_container.remove(form_container.get_first_child());
            }

            string active_mode = toggle_group.get_active_name();

            if (active_mode == "mp3") {
                var instructions = new Gtk.Label("Paste YouTube URL to download as MP3:");
                instructions.set_halign(Gtk.Align.START);
                instructions.add_css_class("title-4");

                url_entry.set_placeholder_text("https://www.youtube.com/watch?v=...");
                download_button.set_label("Download MP3");

                form_container.append(instructions);
            } else {
                var instructions = new Gtk.Label("Paste YouTube playlist URL:");
                instructions.set_halign(Gtk.Align.START);
                instructions.add_css_class("title-4");

                url_entry.set_placeholder_text("https://www.youtube.com/playlist?list=...");
                download_button.set_label("Download Playlist");

                form_container.append(instructions);
            }

            form_container.append(url_entry);

            var directory_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
            var directory_label = new Gtk.Label("Save to:");
            directory_label.set_halign(Gtk.Align.START);
            directory_box.append(directory_label);
            directory_box.append(directory_entry);
            directory_box.append(folder_button);

            form_container.append(directory_box);
            form_container.append(download_button);
            form_container.append(status_label);
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
            string url = url_entry.get_text();

            if (url == null || url.strip().length == 0) {
                set_status("Please enter a valid URL.");
                return;
            }

            if (!url.contains("youtube.com") && !url.contains("youtu.be")) {
                set_status("Please enter a valid YouTube URL.");
                return;
            }

            string directory = selected_directory ?? Ongaku.FileUtils.get_default_music_directory();
            bool is_playlist = toggle_group.get_active_name() == "playlist";

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
    }
}


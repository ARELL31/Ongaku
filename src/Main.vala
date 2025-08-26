using Gtk;
using Adw;
using Posix;

int main(string[] args) {
    return new MyApp().run(args);
}

public class MyApp : Adw.Application {
    private string? selected_directory = null;
    private Gtk.ProgressBar progress_bar;
    private Gtk.Label progress_text;
    private bool is_downloading = false;

    public MyApp() {
        Object(
            application_id: "xyz.arell.ongaku",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var window = new Adw.ApplicationWindow(this) {
            title = "Ongaku",
        };

        var window_title = new Adw.WindowTitle("Ongaku", "Download Music Freely");

        var header = new Adw.HeaderBar() {
            show_end_title_buttons = true,
            title_widget = window_title
        };

        var main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

        var content_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 15);
        content_box.margin_top = 20;
        content_box.margin_bottom = 20;
        content_box.margin_start = 20;
        content_box.margin_end = 20;

        var instructions = new Gtk.Label("Paste YouTube URL to download as MP3:");
        instructions.set_halign(Gtk.Align.START);
        instructions.add_css_class("title-3");
        content_box.append(instructions);

        var url_entry = new Gtk.Entry();
        url_entry.set_placeholder_text("https://www.youtube.com/watch?v=...");
        url_entry.set_hexpand(true);
        content_box.append(url_entry);

        var directory_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        
        var directory_label = new Gtk.Label("Save to:");
        directory_label.set_halign(Gtk.Align.START);
        directory_box.append(directory_label);

        var directory_entry = new Gtk.Entry();
        directory_entry.set_text(get_default_music_directory());
        directory_entry.set_hexpand(true);
        directory_entry.set_editable(false);
        directory_box.append(directory_entry);

        var folder_button = new Gtk.Button.with_label("Browse");
        directory_box.append(folder_button);

        content_box.append(directory_box);

        var download_button = new Gtk.Button.with_label("Download MP3");
        download_button.add_css_class("suggested-action");
        download_button.add_css_class("pill");
        download_button.set_hexpand(true);
        content_box.append(download_button);

        var status_label = new Gtk.Label("Ready to download");
        status_label.set_halign(Gtk.Align.START);
        status_label.set_wrap(true);
        content_box.append(status_label);

        main_box.append(header);
        main_box.append(content_box);

        var progress_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        progress_container.add_css_class("toolbar");
        
        var progress_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 8);
        progress_box.margin_top = 12;
        progress_box.margin_bottom = 12;
        progress_box.margin_start = 20;
        progress_box.margin_end = 20;

        progress_text = new Gtk.Label("");
        progress_text.set_halign(Gtk.Align.START);
        progress_text.add_css_class("caption");
        progress_text.set_visible(false);
        progress_box.append(progress_text);

        progress_bar = new Gtk.ProgressBar();
        progress_bar.set_hexpand(true);
        progress_bar.set_visible(false);
        progress_bar.set_show_text(true);
        progress_box.append(progress_bar);

        progress_container.append(progress_box);
        main_box.append(progress_container);

        folder_button.clicked.connect(() => {
            var dialog = new Gtk.FileChooserDialog(
                "Select download directory",
                window,
                Gtk.FileChooserAction.SELECT_FOLDER,
                "_Cancel", Gtk.ResponseType.CANCEL,
                "_Select", Gtk.ResponseType.ACCEPT,
                null
            );

            if (selected_directory != null) {
                try {
                    dialog.set_current_folder(File.new_for_path(selected_directory));
                } catch (Error e) {
                    try {
                        dialog.set_current_folder(File.new_for_path(Environment.get_home_dir()));
                    } catch (Error e2) {
                    }
                }
            } else {
                try {
                    dialog.set_current_folder(File.new_for_path(get_default_music_directory()));
                } catch (Error e) {
                }
            }

            dialog.response.connect((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    File? folder = dialog.get_file();
                    if (folder != null) {
                        selected_directory = folder.get_path();
                        directory_entry.set_text(selected_directory);
                    }
                }
                dialog.destroy();
            });

            dialog.present();
        });

        download_button.clicked.connect(() => {
            string url = url_entry.get_text();
            
            if (url == null || url.strip().length == 0) {
                status_label.set_text("Please enter a valid URL.");
                return;
            }

            if (!url.contains("youtube.com") && !url.contains("youtu.be")) {
                status_label.set_text("Please enter a valid YouTube URL.");
                return;
            }

            if (is_downloading) {
                return;
            }

            string download_dir = selected_directory ?? get_default_music_directory();

            start_download_ui();
            status_label.set_text("Downloading...");
            download_button.set_sensitive(false);

            download_audio.begin(url, download_dir, (obj, res) => {
                try {
                    string result = download_audio.end(res);
                    status_label.set_text(result);
                } catch (Error e) {
                    status_label.set_text("Error: " + e.message);
                }
                
                finish_download_ui();
                download_button.set_sensitive(true);
            });
        });

        url_entry.activate.connect(() => {
            download_button.clicked();
        });

        window.set_content(main_box);
        window.present();
    }

    private void start_download_ui() {
        is_downloading = true;
        progress_bar.set_visible(true);
        progress_text.set_visible(true);
        progress_text.set_text("Initializing download...");
        progress_bar.set_text("0%");
        progress_bar.set_fraction(0.0);
        
        simulate_progress();
    }

    private void finish_download_ui() {
        is_downloading = false;
        progress_bar.set_visible(false);
        progress_text.set_visible(false);
    }

    private void simulate_progress() {
        if (!is_downloading) return;

        string[] phases = {
            "Fetching video information...",
            "Extracting audio stream...",
            "Converting to MP3...",
            "Finalizing download..."
        };

        int phase = 0;
        double progress = 0.0;

        Timeout.add(300, () => {
            if (!is_downloading) return false;

            progress += 0.02;
            
            if (progress >= 1.0) {
                progress = 0.95;
            }

            if (progress >= 0.25 * (phase + 1) && phase < phases.length - 1) {
                phase++;
            }

            progress_text.set_text(phases[phase]);
            progress_bar.set_fraction(progress);
            progress_bar.set_text("%.0f%%".printf(progress * 100));

            return is_downloading;
        });
    }

    private string get_default_music_directory() {
        string home = Environment.get_home_dir();
        string music_dir = Path.build_filename(home, "Music");
        
        if (!FileUtils.test(music_dir, FileTest.IS_DIR)) {
            music_dir = Path.build_filename(home, "Música");
            
            if (!FileUtils.test(music_dir, FileTest.IS_DIR)) {
                try {
                    DirUtils.create_with_parents(music_dir, 493);
                } catch (FileError e) {
                    music_dir = home;
                }
            }
        }
        
        return music_dir;
    }

    private async string download_audio(string url, string output_dir) throws Error {
        string output_path = Path.build_filename(output_dir, "%(title)s.%(ext)s");
        
        string[] argv = {
            "yt-dlp",
            "-x",
            "--audio-format", "mp3",
            "--output", output_path,
            "--no-playlist",
            url
        };

        int exit_status = -1;

        try {
            Pid child_pid;
            int standard_input;
            int standard_output;
            int standard_error;

            Process.spawn_async_with_pipes(
                output_dir,
                argv,
                null,
                SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                null,
                out child_pid,
                out standard_input,
                out standard_output,
                out standard_error
            );

            close(standard_input);

            ChildWatch.add(child_pid, (pid, status) => {
                exit_status = status;
                Process.close_pid(pid);
                download_audio.callback();
            });

            yield;

            var error_channel = new IOChannel.unix_new(standard_error);
            string error_output = "";
            string line;
            
            try {
                while (error_channel.read_line(out line, null, null) == IOStatus.NORMAL) {
                    error_output += line;
                }
            } catch (Error e) {
            }
            
            error_channel.shutdown(false);
            close(standard_output);
            close(standard_error);

            if (exit_status != 0) {
                throw new IOError.FAILED("yt-dlp failed: " + error_output);
            }

            return "Download completed successfully in " + output_dir;
            
        } catch (SpawnError e) {
            if (e.code == SpawnError.NOENT) {
                throw new IOError.NOT_FOUND("yt-dlp is not installed. Install it with: sudo apt install yt-dlp");
            }
            throw new IOError.FAILED("Error running yt-dlp: " + e.message);
        }
    }
}

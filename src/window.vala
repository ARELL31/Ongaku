namespace Ongaku {
    public class MainWindow : Adw.ApplicationWindow {
        private DownloadForm download_form;
        private HistoryList history_list;
        private ProgressIndicator progress_indicator;
        private Gtk.ToggleButton youtube_button;
        private Gtk.ToggleButton spotify_button;
        private Gtk.ToggleButton youtube_music_button;
        
        public MainWindow(Gtk.Application app) {
            Object(application: app, title: "Ongaku");
            setup_ui();
            setup_signals();
            setup_actions();
        }
        
        private void setup_ui() {
            var window_title = new Adw.WindowTitle("Ongaku", "Download Music Freely");
            var header = new Adw.HeaderBar() {
                show_end_title_buttons = true,
                title_widget = window_title
            };
            
            var menu_button = new Gtk.MenuButton();
            menu_button.set_icon_name("open-menu-symbolic");
            menu_button.set_tooltip_text("Main Menu");
            var menu = create_main_menu();
            menu_button.set_menu_model(menu);
            header.pack_end(menu_button);
            var main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            main_box.append(header);
            
            var platform_selector = create_platform_selector();
            main_box.append(platform_selector);
            download_form = new DownloadForm();
            download_form.set_platform_mode("youtube");
            download_form.set_placeholder_text("Enter YouTube URL or search term...");
            main_box.append(download_form);
            
            progress_indicator = new ProgressIndicator();
            main_box.append(progress_indicator);
            
            history_list = new HistoryList();
            main_box.append(history_list);
            
            set_content(main_box);
            set_default_size(600, 650);
        }
        
        private Gtk.Widget create_platform_selector() {
            var main_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            main_container.set_margin_top(12);
            main_container.set_margin_bottom(12);
            main_container.set_margin_start(12);
            main_container.set_margin_end(12);
            var title_label = new Gtk.Label("<b>Select Platform</b>");
            title_label.set_use_markup(true);
            title_label.set_halign(Gtk.Align.START);
            main_container.append(title_label);
            var buttons_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 8);
            buttons_container.set_halign(Gtk.Align.CENTER);

            youtube_button = new Gtk.ToggleButton();
            youtube_button.set_label("YouTube");
            youtube_button.set_active(true);
            youtube_button.add_css_class("round");
            youtube_button.add_css_class("suggested-action");

            spotify_button = new Gtk.ToggleButton();
            spotify_button.set_label("Spotify");
            spotify_button.add_css_class("round");

            youtube_music_button = new Gtk.ToggleButton();
            youtube_music_button.set_label("YouTube Music");
            youtube_music_button.add_css_class("round");

            youtube_button.toggled.connect(() => {
                if (youtube_button.get_active()) {
                    spotify_button.set_active(false);
                    youtube_music_button.set_active(false);
                    youtube_button.add_css_class("suggested-action");
                    spotify_button.remove_css_class("suggested-action");
                    youtube_music_button.remove_css_class("suggested-action");
                    update_download_form_for_platform("youtube");
                } else if (!spotify_button.get_active() && !youtube_music_button.get_active()) {
                    youtube_button.set_active(true);
                }
            });

            spotify_button.toggled.connect(() => {
                if (spotify_button.get_active()) {
                    youtube_button.set_active(false);
                    youtube_music_button.set_active(false);
                    spotify_button.add_css_class("suggested-action");
                    youtube_button.remove_css_class("suggested-action");
                    youtube_music_button.remove_css_class("suggested-action");
                    update_download_form_for_platform("spotify");
                } else if (!youtube_button.get_active() && !youtube_music_button.get_active()) {
                    spotify_button.set_active(true);
                }
            });

            youtube_music_button.toggled.connect(() => {
                if (youtube_music_button.get_active()) {
                    youtube_button.set_active(false);
                    spotify_button.set_active(false);
                    youtube_music_button.add_css_class("suggested-action");
                    youtube_button.remove_css_class("suggested-action");
                    spotify_button.remove_css_class("suggested-action");
                    update_download_form_for_platform("youtube-music");
                } else if (!youtube_button.get_active() && !spotify_button.get_active()) {
                    youtube_music_button.set_active(true);
                }
            });

            buttons_container.append(youtube_button);
            buttons_container.append(spotify_button);
            buttons_container.append(youtube_music_button);
            main_container.append(buttons_container);
            return main_container;
        }

        private void update_download_form_for_platform(string platform) {
            if (platform == "youtube") {
                download_form.set_platform_mode("youtube");
                download_form.set_placeholder_text("Enter YouTube URL or search term...");
            } else if (platform == "spotify") {
                download_form.set_platform_mode("spotify");
                download_form.set_placeholder_text("Enter Spotify URL (track, album, or playlist)...");
            } else if (platform == "youtube-music") {
                download_form.set_platform_mode("youtube-music");
                download_form.set_placeholder_text("Enter YouTube Music URL...");
            }
        }

        private GLib.Menu create_main_menu() {
            var menu = new GLib.Menu();
            var file_section = new GLib.Menu();
            file_section.append("Open Download Folder", "win.open-folder");
            file_section.append("Clear History", "win.clear-history");
            menu.append_section(null, file_section);
            var app_section = new GLib.Menu();
            app_section.append("Preferences", "win.preferences");
            app_section.append("About", "win.about");
            menu.append_section(null, app_section);
            var control_section = new GLib.Menu();
            control_section.append("Quit", "app.quit");
            menu.append_section(null, control_section);
            return menu;
        }

        private void setup_actions() {
            var open_folder_action = new GLib.SimpleAction("open-folder", null);
            open_folder_action.activate.connect(on_open_folder);
            add_action(open_folder_action);
            var clear_history_action = new GLib.SimpleAction("clear-history", null);
            clear_history_action.activate.connect(on_clear_history);
            add_action(clear_history_action);
            var preferences_action = new GLib.SimpleAction("preferences", null);
            preferences_action.activate.connect(on_preferences);
            add_action(preferences_action);
            var about_action = new GLib.SimpleAction("about", null);
            about_action.activate.connect(on_about);
            add_action(about_action);
        }

        private void setup_signals() {
            download_form.download_requested.connect(on_download_requested);
        }
        
        private string get_selected_platform() {
            if (youtube_button.get_active())
                return "youtube";
            if (spotify_button.get_active())
                return "spotify";
            if (youtube_music_button.get_active())
                return "youtube-music";
            return "youtube";
        }

        private async void on_download_requested(string url, string directory, bool is_playlist) {
            try {
                string platform = get_selected_platform();
                progress_indicator.start(@"Starting $(platform) download...");
                download_form.set_sensitive(false);
                
                var downloader = new Downloader();
                string result = yield downloader.download(url, directory, is_playlist);
                
                download_form.set_status(result);
                history_list.refresh();
            } catch (Error e) {
                download_form.set_status("Error: " + e.message);
            } finally {
                progress_indicator.finish();
                download_form.set_sensitive(true);
            }
        }

        private void on_open_folder() {
            string music_dir = Ongaku.FileUtils.get_default_music_directory();
            try {
                Process.spawn_command_line_async("xdg-open \"" + music_dir + "\"");
            } catch (SpawnError e) {
                print("Error opening folder: %s\n", e.message);
            }
        }

        private void on_clear_history() {
            var dialog = new Adw.AlertDialog("Clear History", "Are you sure you want to clear the download history?");
            dialog.add_response("cancel", "Cancel");
            dialog.add_response("clear", "Clear History Only");
            dialog.add_response("delete", "Delete All Files");
            dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE);
            dialog.set_default_response("cancel");
            dialog.set_close_response("cancel");
            dialog.response.connect((response) => {
                if (response == "clear") {
                    history_list.clear_history();
                } else if (response == "delete") {
                    history_list.delete_all_files();
                }
            });
            dialog.present(this);
        }

        private void on_preferences() {
            var preferences_window = new PreferencesWindow(this);
            preferences_window.present();
        }

        private void on_about() {
            var about_dialog = new Adw.AboutDialog();
            about_dialog.set_application_name("Ongaku");
            about_dialog.set_version(Config.VERSION);
            about_dialog.set_developer_name("Arell");
            about_dialog.set_copyright("© 2025 Yollosoft");
            about_dialog.set_license_type(Gtk.License.GPL_3_0);
            about_dialog.set_website("https://github.com/ARELL31/ongaku");
            about_dialog.set_issue_url("https://github.com/ARELL31/ongaku/issues");
            about_dialog.set_application_icon("ongaku");
            string[] developers = { "Arell <ferarellano654@gmail.com>" };
            about_dialog.set_developers(developers);
            about_dialog.present(this);
        }
    }
}


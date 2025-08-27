namespace Ongaku {
    public class MainWindow : Adw.ApplicationWindow {
        private DownloadForm download_form;
        private HistoryList history_list;
        private ProgressIndicator progress_indicator;
        
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
            
            download_form = new DownloadForm();
            main_box.append(download_form);
            
            progress_indicator = new ProgressIndicator();
            main_box.append(progress_indicator);
            
            history_list = new HistoryList();
            main_box.append(history_list);
            
            set_content(main_box);
            set_default_size(600, 650);
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
        
        private async void on_download_requested(string url, string directory, bool is_playlist) {
            try {
                progress_indicator.start("Starting download...");
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

            var toast = new Adw.Toast("Preferences coming soon!");

            print("Preferences action triggered\n");
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


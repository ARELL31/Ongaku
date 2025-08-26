namespace Ongaku {
    public class MainWindow : Adw.ApplicationWindow {
        private DownloadForm download_form;
        private HistoryList history_list;
        private ProgressIndicator progress_indicator;
        
        public MainWindow(Gtk.Application app) {
            Object(application: app, title: "Ongaku");
            setup_ui();
            setup_signals();
        }
        
        private void setup_ui() {
            var window_title = new Adw.WindowTitle("Ongaku", "Download Music Freely");
            var header = new Adw.HeaderBar() {
                show_end_title_buttons = true,
                title_widget = window_title
            };
            
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
    }
}


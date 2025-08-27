namespace Ongaku {
    public class HistoryList : Gtk.Box {
        private Gtk.ListBox listbox;
        private string? directory_override = null;

        public HistoryList() {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 10);
            setup_ui();
        }

        private void setup_ui() {
            margin_top = 20;
            margin_bottom = 20;
            margin_start = 20;
            margin_end = 20;

            create_header();
            create_list();

            refresh();
        }

        private void create_header() {
            var header_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);

            var title_label = new Gtk.Label("Downloaded Files");
            title_label.set_halign(Gtk.Align.START);
            title_label.add_css_class("title-4");
            title_label.set_hexpand(true);
            header_box.append(title_label);

            var refresh_button = new Gtk.Button();
            refresh_button.set_icon_name("view-refresh-symbolic");
            refresh_button.set_tooltip_text("Refresh list");
            refresh_button.clicked.connect(refresh);
            header_box.append(refresh_button);

            var open_folder_button = new Gtk.Button();
            open_folder_button.set_icon_name("folder-open-symbolic");
            open_folder_button.set_tooltip_text("Open folder");
            open_folder_button.clicked.connect(open_folder);
            header_box.append(open_folder_button);

            append(header_box);
        }

        private void create_list() {
            listbox = new Gtk.ListBox();
            listbox.add_css_class("boxed-list");
            listbox.set_selection_mode(Gtk.SelectionMode.NONE);

            var scrolled = new Gtk.ScrolledWindow();
            scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scrolled.set_vexpand(true);
            scrolled.set_min_content_height(200);
            scrolled.set_child(listbox);

            append(scrolled);
        }

        public void refresh() {

            while (listbox.get_first_child() != null) {
                listbox.remove(listbox.get_first_child());
            }

            string music_dir = directory_override ?? Ongaku.FileUtils.get_default_music_directory();
            var files = Ongaku.FileUtils.get_mp3_files(music_dir);

            if (files.length == 0) {

                show_empty_state();
            } else {
                foreach (var file_info in files) {
                    var row = create_file_row(file_info);
                    listbox.append(row);
                }
            }
        }

        private void show_empty_state() {
            var empty_row = new Gtk.ListBoxRow();
            empty_row.set_selectable(false);
            empty_row.set_activatable(false);

            var empty_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
            empty_box.margin_top = 48;
            empty_box.margin_bottom = 48;
            empty_box.set_halign(Gtk.Align.CENTER);
            empty_box.set_valign(Gtk.Align.CENTER);

            var empty_icon = new Gtk.Image.from_icon_name("folder-music-symbolic");
            empty_icon.set_icon_size(Gtk.IconSize.LARGE);
            empty_icon.add_css_class("dim-label");
            empty_box.append(empty_icon);

            var empty_title = new Gtk.Label("No Downloads Yet");
            empty_title.add_css_class("title-2");
            empty_title.add_css_class("dim-label");
            empty_box.append(empty_title);

            var empty_subtitle = new Gtk.Label("Downloaded music files will appear here");
            empty_subtitle.add_css_class("caption");
            empty_subtitle.add_css_class("dim-label");
            empty_box.append(empty_subtitle);

            empty_row.set_child(empty_box);
            listbox.append(empty_row);
        }

        private Gtk.ListBoxRow create_file_row(Ongaku.FileUtils.FileInfo file_info) {
            var row_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12);
            row_box.margin_top = 12;
            row_box.margin_bottom = 12;
            row_box.margin_start = 12;
            row_box.margin_end = 12;


            var icon = new Gtk.Image.from_icon_name("audio-x-generic-symbolic");
            icon.add_css_class("dim-label");
            row_box.append(icon);


            var info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 4);
            info_box.set_hexpand(true);

            var name_label = new Gtk.Label(file_info.name);
            name_label.set_halign(Gtk.Align.START);
            name_label.set_ellipsize(Pango.EllipsizeMode.END);
            name_label.set_max_width_chars(50);
            info_box.append(name_label);

            var details_label = new Gtk.Label(@"$(file_info.size) • $(file_info.date)");
            details_label.set_halign(Gtk.Align.START);
            details_label.add_css_class("dim-label");
            details_label.add_css_class("caption");
            info_box.append(details_label);

            row_box.append(info_box);


            var buttons_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);


            var play_button = new Gtk.Button();
            play_button.set_icon_name("media-playback-start-symbolic");
            play_button.set_tooltip_text("Open file");
            play_button.set_valign(Gtk.Align.CENTER);
            play_button.add_css_class("flat");
            play_button.clicked.connect(() => open_file(file_info.path));
            buttons_box.append(play_button);


            var delete_button = new Gtk.Button();
            delete_button.set_icon_name("user-trash-symbolic");
            delete_button.set_tooltip_text("Delete file");
            delete_button.set_valign(Gtk.Align.CENTER);
            delete_button.add_css_class("flat");
            delete_button.add_css_class("destructive-action");
            delete_button.clicked.connect(() => delete_file(file_info.path, file_info.name));
            buttons_box.append(delete_button);

            row_box.append(buttons_box);

            var list_row = new Gtk.ListBoxRow();
            list_row.set_child(row_box);
            return list_row;
        }

        private void open_file(string file_path) {
            try {
                Process.spawn_command_line_async("xdg-open \"" + file_path + "\"");
            } catch (SpawnError e) {
                print("Error opening file: %s\n", e.message);
            }
        }

        private void delete_file(string file_path, string filename) {

            var dialog = new Adw.AlertDialog("Delete File", @"Are you sure you want to delete \"$filename\"?");
            dialog.add_response("cancel", "Cancel");
            dialog.add_response("delete", "Delete");
            dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE);
            dialog.set_default_response("cancel");
            dialog.set_close_response("cancel");

            dialog.response.connect((response) => {
                if (response == "delete") {
                    try {
                        var file = File.new_for_path(file_path);
                        file.delete();
                        refresh();
                    } catch (Error e) {
                        print("Error deleting file: %s\n", e.message);
                    }
                }
            });

            var window = get_root() as Gtk.Window;
            if (window != null) {
                dialog.present(window);
            }
        }

        private void open_folder() {
            string music_dir = directory_override ?? Ongaku.FileUtils.get_default_music_directory();
            try {
                Process.spawn_command_line_async("xdg-open \"" + music_dir + "\"");
            } catch (SpawnError e) {
                print("Error opening folder: %s\n", e.message);
            }
        }

        public void set_directory(string directory) {
            directory_override = directory;
            refresh();
        }


        public void clear_history() {

            while (listbox.get_first_child() != null) {
                listbox.remove(listbox.get_first_child());
            }


            show_empty_state();
        }


        public void delete_all_files() {
            string music_dir = directory_override ?? Ongaku.FileUtils.get_default_music_directory();
            var files = Ongaku.FileUtils.get_mp3_files(music_dir);

            foreach (var file_info in files) {
                try {
                    var file = File.new_for_path(file_info.path);
                    file.delete();
                } catch (Error e) {
                    print("Error deleting file %s: %s\n", file_info.name, e.message);
                }
            }

            refresh();
        }


        public int get_files_count() {
            string music_dir = directory_override ?? Ongaku.FileUtils.get_default_music_directory();
            var files = Ongaku.FileUtils.get_mp3_files(music_dir);
            return files.length;
        }
    }
}


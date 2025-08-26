using GLib;

namespace Ongaku {
    namespace FileUtils {
        public class FileInfo : Object {
            public string name { get; set; }
            public string size { get; set; }
            public string date { get; set; }
            public string path { get; set; }

            public FileInfo(string name, string size, string date, string path) {
                this.name = name;
                this.size = size;
                this.date = date;
                this.path = path;
            }
        }

        public static string get_default_music_directory() {
            string home = Environment.get_home_dir();
            string music_dir = Path.build_filename(home, "Music");

            try {
                var file = File.new_for_path(music_dir);
                if (!file.query_exists()) {
                    // Try "Música" folder
                    music_dir = Path.build_filename(home, "Música");
                    file = File.new_for_path(music_dir);

                    if (!file.query_exists()) {
                        try {
                            file.make_directory_with_parents();
                        } catch (Error e) {
                            music_dir = home;
                        }
                    }
                }
            } catch (Error e) {
                music_dir = home;
            }

            return music_dir;
        }

        public static FileInfo[] get_mp3_files(string directory) {
            FileInfo[] files = {};

            try {
                var dir_file = File.new_for_path(directory);
                var enumerator = dir_file.enumerate_children(
                    "standard::name,standard::size,time::modified",
                    FileQueryInfoFlags.NONE
                );

                GLib.FileInfo? glib_info;
                while ((glib_info = enumerator.next_file()) != null) {
                    string filename = glib_info.get_name();

                    if (filename.has_suffix(".mp3")) {
                        int64 size = (int64)glib_info.get_size();
                        string size_str = format_file_size(size);

                        // Use the new get_modification_date_time() method
                        string date_str = "";
                        var datetime = glib_info.get_modification_date_time();
                        if (datetime != null) {
                            date_str = datetime.format("%Y-%m-%d %H:%M");
                        } else {
                            date_str = "Unknown";
                        }

                        var file_info = new FileInfo(
                            filename,
                            size_str,
                            date_str,
                            Path.build_filename(directory, filename)
                        );

                        files += file_info;
                    }
                }
            } catch (Error e) {
                print("Error reading directory: %s\n", e.message);
            }

            return files;
        }

        private static string format_file_size(int64 size) {
            if (size < 1024) {
                return "%lld B".printf(size);
            } else if (size < 1024 * 1024) {
                return "%.1f KB".printf((double)size / 1024);
            } else {
                return "%.1f MB".printf((double)size / (1024 * 1024));
            }
        }
    }
}


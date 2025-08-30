using Posix;
namespace Ongaku {
    public class Downloader : Object {
        private Settings settings;
        public Downloader() {
            settings = new Settings();
        }
        public async string download(string url, string output_dir, bool is_playlist) throws Error {
            yield sleep_random();
            if (is_spotify_url(url)) {
                return yield run_spotdl(url, output_dir, is_playlist);
            } else {
                return yield run_ytdlp_with_cookies(url, output_dir, is_playlist);
            }
        }
        private bool is_spotify_url(string url) {
            return url.contains("spotify.com") || url.contains("open.spotify.com");
        }
        private async void sleep_random() {
            uint delay = 1000 + (GLib.Random.int_range(0, 4000));
            Timeout.add(delay, () => {
                sleep_random.callback();
                return false;
            });
            yield;
        }
        private async string run_spotdl(string url, string output_dir, bool is_playlist) throws Error {
            string[] argv = {"spotdl-wrapper.sh"};
            int content_type = settings.get_content_type();
            switch (content_type) {
                case Settings.ContentType.AUDIO_ONLY:
                    argv += "--format";
                    argv += settings.get_audio_format_string();
                    string audio_quality = settings.get_audio_quality_string();
                    if (audio_quality == "320k" || audio_quality.contains("320")) {
                        argv += "--bitrate";
                        argv += "320k";
                    } else if (audio_quality == "256k" || audio_quality.contains("256")) {
                        argv += "--bitrate";
                        argv += "256k";
                    } else if (audio_quality == "192k" || audio_quality.contains("192")) {
                        argv += "--bitrate";
                        argv += "192k";
                    }
                    break;
                case Settings.ContentType.VIDEO:
                case Settings.ContentType.BOTH:
                    argv += "--format";
                    argv += "mp3";
                    break;
            }
            argv += "--output";
            argv += Path.build_filename(output_dir, "{artist} - {title}.{ext}");
            argv += "--print-errors";
            argv += "--overwrite";
            argv += "skip";
            string cookie_path = get_cookie_path_with_debug();
            if (cookie_path.length > 0) {
                argv += "--cookie-file";
                argv += cookie_path;
            }
            argv += url;
            return yield execute_command(argv, output_dir, "SpotDL", get_spotify_content_description(url));
        }
        private async string run_ytdlp_with_cookies(string url, string output_dir, bool is_playlist) throws Error {
            string output_path = Path.build_filename(output_dir, "%(title)s.%(ext)s");
            string[] argv = {"yt-dlp"};
            string cookie_path = get_cookie_path_with_debug();
            if (cookie_path.length > 0) {
                argv += "--cookies";
                argv += cookie_path;
                print("Using cookies from: %s\n", cookie_path);
            } else if (settings.get_auto_update_cookies()) {
                string browser = detect_available_browser();
                if (browser != "") {
                    argv += "--cookies-from-browser";
                    argv += browser;
                    print("Using cookies from browser: %s\n", browser);
                }
            } else {
                print("No cookies configured\n");
            }
            argv += "--sleep-interval";
            argv += GLib.Random.int_range(2, 8).to_string();
            argv += "--max-sleep-interval";
            argv += GLib.Random.int_range(5, 15).to_string();
            int content_type = settings.get_content_type();
            switch (content_type) {
                case Settings.ContentType.AUDIO_ONLY:
                    argv += "-x";
                    argv += "--audio-format";
                    argv += settings.get_audio_format_string();
                    string audio_quality = settings.get_audio_quality_string();
                    if (audio_quality != "bestaudio") {
                        argv += "-f";
                        argv += audio_quality;
                    }
                    if (settings.get_embed_thumbnails()) {
                        argv += "--embed-thumbnail";
                    }
                    break;
                case Settings.ContentType.VIDEO:
                    string video_format = settings.get_video_format_string();
                    string video_quality = settings.get_video_quality_string();
                    if (video_quality != "best") {
                        argv += "-f";
                        argv += @"$(video_quality)[ext=$(video_format)]+bestaudio[ext=m4a]/$(video_quality)+bestaudio/best[ext=$(video_format)]/best";
                    } else {
                        argv += "-f";
                        argv += @"bestvideo[ext=$(video_format)]+bestaudio[ext=m4a]/bestvideo+bestaudio/best[ext=$(video_format)]/best";
                    }
                    argv += "--merge-output-format";
                    argv += video_format;
                    break;
                case Settings.ContentType.BOTH:
                    argv += "-f";
                    argv += @"$(settings.get_video_quality_string()),$(settings.get_audio_quality_string())";
                    output_path = Path.build_filename(output_dir, "%(title)s.f%(format_id)s.%(ext)s");
                    break;
            }
            argv += "--output";
            argv += output_path;
            argv += "--ignore-errors";
            argv += "--no-warnings";
            int max_res = settings.get_max_resolution();
            if (max_res > 0 && content_type != Settings.ContentType.AUDIO_ONLY) {
                argv += "-f";
                argv += @"best[height<=$(max_res)]";
            }
            if (!is_playlist) {
                argv += "--no-playlist";
            }
            argv += url;
            return yield execute_command(argv, output_dir, "yt-dlp", get_content_description());
        }
        private string get_cookie_path_with_debug() {
            string custom_path = settings.get_cookies_path();
            print("Custom cookie path from settings: '%s'\n", custom_path);

            if (custom_path.length > 0 && GLib.FileUtils.test(custom_path, GLib.FileTest.EXISTS)) {
                print("Custom cookie file exists: %s\n", custom_path);
                return custom_path;
            }

            string default_path = Path.build_filename(GLib.Environment.get_user_config_dir(), "ongaku", "cookies.txt");
            print("Default cookie path: '%s'\n", default_path);

            if (GLib.FileUtils.test(default_path, GLib.FileTest.EXISTS)) {
                print("Default cookie file exists: %s\n", default_path);
                return default_path;
            }

            print("No cookie file found\n");
            return "";
        }
        private string detect_available_browser() {
            string[] browsers = {"firefox", "chrome", "edge"};
            foreach (string browser in browsers) {
                if (is_browser_installed(browser)) {
                    return browser;
                }
            }
            return "";
        }
        private bool is_browser_installed(string browser) {
            string[] commands_to_check = {};
            switch (browser) {
                case "firefox":
                    commands_to_check = {"firefox", "firefox-esr"};
                    break;
                case "chrome":
                    commands_to_check = {"google-chrome", "google-chrome-stable", "chromium", "chromium-browser"};
                    break;
                case "edge":
                    commands_to_check = {"microsoft-edge", "microsoft-edge-stable"};
                    break;
            }
            foreach (string command in commands_to_check) {
                try {
                    string output;
                    int exit_status;
                    Process.spawn_command_line_sync(@"which $(command)", out output, null, out exit_status);
                    if (exit_status == 0 && output.strip().length > 0) {
                        return true;
                    }
                } catch (Error e) {
                    continue;
                }
            }
            return false;
        }
        private async string execute_command(string[] argv, string output_dir, string tool_name, string content_desc) throws Error {
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
                    execute_command.callback();
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
                    if (error_output.contains("Sign in to confirm you're not a bot")) {
                        throw new IOError.FAILED(@"$(tool_name) failed: YouTube requires authentication. Please configure cookies in Settings > Authentication or export cookies from your browser and save as ~/.config/ongaku/cookies.txt");
                    }
                    throw new IOError.FAILED(@"$(tool_name) failed: $(error_output)");
                }
                return @"$(tool_name) download ($(content_desc)) completed successfully in $(output_dir)";
            } catch (SpawnError e) {
                if (e.code == SpawnError.NOENT) {
                    if (tool_name.contains("SpotDL")) {
                        throw new IOError.NOT_FOUND("SpotDL wrapper is not available. Please reinstall Ongaku.");
                    } else {
                        throw new IOError.NOT_FOUND("yt-dlp is not installed. Install it with: sudo apt install yt-dlp");
                    }
                }
                throw new IOError.FAILED(@"Error running $(tool_name): $(e.message)");
            }
        }
        private string get_content_description() {
            int content_type = settings.get_content_type();
            switch (content_type) {
                case Settings.ContentType.AUDIO_ONLY:
                    return @"Audio: $(settings.get_audio_format_string().up())";
                case Settings.ContentType.VIDEO:
                    return @"Video: $(settings.get_video_format_string().up())";
                case Settings.ContentType.BOTH:
                    return "Audio + Video (separate)";
                default:
                    return "Unknown";
            }
        }
        private string get_spotify_content_description(string url) {
            if (url.contains("/track/")) {
                return "Track (Audio: MP3)";
            } else if (url.contains("/album/")) {
                return "Album (Audio: MP3)";
            } else if (url.contains("/playlist/")) {
                return "Playlist (Audio: MP3)";
            } else {
                return "Spotify Content (Audio: MP3)";
            }
        }
        public bool is_spotdl_available() {
            try {
                string output;
                Process.spawn_command_line_sync("spotdl-wrapper.sh --version", out output);
                return true;
            } catch (Error e) {
                return false;
            }
        }
        public string get_downloader_for_url(string url) {
            if (is_spotify_url(url)) {
                return is_spotdl_available() ? "SpotDL (Custom)" : "Not available (reinstall Ongaku)";
            } else {
                if (settings.has_valid_cookies()) {
                    return "yt-dlp (with custom cookies)";
                } else if (settings.get_auto_update_cookies()) {
                    string browser = detect_available_browser();
                    return browser != "" ? @"yt-dlp (with $(browser) cookies)" : "yt-dlp (no cookies)";
                } else {
                    return "yt-dlp (no authentication)";
                }
            }
        }
        public void create_cookies_directory() {
            string config_dir = Path.build_filename(GLib.Environment.get_user_config_dir(), "ongaku");
            try {
                var dir = GLib.File.new_for_path(config_dir);
                dir.make_directory_with_parents();
            } catch (Error e) {
            }
        }
    }
}


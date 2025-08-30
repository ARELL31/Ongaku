namespace Ongaku {
    public class Settings : Object {
        private GLib.Settings? gsettings;
        public enum ContentType {
            AUDIO_ONLY = 0,
            VIDEO = 1,
            BOTH = 2
        }
        public Settings() {
            try {
                gsettings = new GLib.Settings("xyz.arell.ongaku");
            } catch (Error e) {
                print("Warning: GSettings schema not found, using defaults: %s\n", e.message);
                gsettings = null;
            }
        }
        public int get_content_type() {
            if (gsettings != null) {
                return gsettings.get_int("content-type");
            }
            return ContentType.AUDIO_ONLY;
        }
        public void set_content_type(int type) {
            if (gsettings != null) {
                gsettings.set_int("content-type", type);
            }
        }
        public int get_audio_format() {
            if (gsettings != null) {
                return gsettings.get_int("audio-format");
            }
            return 0;
        }
        public void set_audio_format(int format) {
            if (gsettings != null) {
                gsettings.set_int("audio-format", format);
            }
        }
        public string get_audio_format_string() {
            string[] formats = {"mp3", "aac", "flac", "ogg", "wav", "m4a"};
            int format = get_audio_format();
            if (format < formats.length) {
                return formats[format];
            }
            return "mp3";
        }
        public int get_video_format() {
            if (gsettings != null) {
                return gsettings.get_int("video-format");
            }
            return 0;
        }
        public void set_video_format(int format) {
            if (gsettings != null) {
                gsettings.set_int("video-format", format);
            }
        }
        public string get_video_format_string() {
            string[] formats = {"mp4", "mkv", "webm", "avi", "mov"};
            int format = get_video_format();
            if (format < formats.length) {
                return formats[format];
            }
            return "mp4";
        }
        public int get_video_quality() {
            if (gsettings != null) {
                return gsettings.get_int("video-quality");
            }
            return 0;
        }
        public void set_video_quality(int quality) {
            if (gsettings != null) {
                gsettings.set_int("video-quality", quality);
            }
        }
        public string get_video_quality_string() {
            string[] qualities = {"best", "best[height<=2160]", "best[height<=1440]",
                                "best[height<=1080]", "best[height<=720]",
                                "best[height<=480]", "best[height<=360]"};
            int quality = get_video_quality();
            if (quality < qualities.length) {
                return qualities[quality];
            }
            return "best";
        }
        public int get_audio_quality() {
            if (gsettings != null) {
                return gsettings.get_int("audio-quality");
            }
            return 0;
        }
        public void set_audio_quality(int quality) {
            if (gsettings != null) {
                gsettings.set_int("audio-quality", quality);
            }
        }
        public string get_audio_quality_string() {
            string[] qualities = {"bestaudio", "bestaudio[abr<=320]", "bestaudio[abr<=256]",
                                "bestaudio[abr<=192]", "bestaudio[abr<=128]", "bestaudio[abr<=96]"};
            int quality = get_audio_quality();
            if (quality < qualities.length) {
                return qualities[quality];
            }
            return "bestaudio";
        }
        public int get_max_resolution() {
            if (gsettings != null) {
                return gsettings.get_int("max-resolution");
            }
            return 0;
        }
        public void set_max_resolution(int resolution) {
            if (gsettings != null) {
                gsettings.set_int("max-resolution", resolution);
            }
        }
        public bool get_clear_url_after_download() {
            if (gsettings != null) {
                return gsettings.get_boolean("clear-url-after-download");
            }
            return true;
        }
        public void set_clear_url_after_download(bool clear) {
            if (gsettings != null) {
                gsettings.set_boolean("clear-url-after-download", clear);
            }
        }
        public bool get_embed_thumbnails() {
            if (gsettings != null) {
                return gsettings.get_boolean("embed-thumbnails");
            }
            return true;
        }
        public void set_embed_thumbnails(bool embed) {
            if (gsettings != null) {
                gsettings.set_boolean("embed-thumbnails", embed);
            }
        }
        public int get_spotify_format() {
            if (gsettings != null) {
                try {
                    return gsettings.get_int("spotify-format");
                } catch (Error e) {
                    print("Warning: spotify-format key not found: %s\n", e.message);
                }
            }
            return 0;
        }
        public void set_spotify_format(int value) {
            if (gsettings != null) {
                try {
                    gsettings.set_int("spotify-format", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-format: %s\n", e.message);
                }
            }
        }
        public int get_spotify_bitrate() {
            if (gsettings != null) {
                try {
                    return gsettings.get_int("spotify-bitrate");
                } catch (Error e) {
                    print("Warning: spotify-bitrate key not found: %s\n", e.message);
                }
            }
            return 0;
        }
        public void set_spotify_bitrate(int value) {
            if (gsettings != null) {
                try {
                    gsettings.set_int("spotify-bitrate", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-bitrate: %s\n", e.message);
                }
            }
        }
        public string get_spotify_output_format() {
            if (gsettings != null) {
                try {
                    return gsettings.get_string("spotify-output-format");
                } catch (Error e) {
                    print("Warning: spotify-output-format key not found: %s\n", e.message);
                }
            }
            return "{artist} - {title}";
        }
        public void set_spotify_output_format(string value) {
            if (gsettings != null) {
                try {
                    gsettings.set_string("spotify-output-format", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-output-format: %s\n", e.message);
                }
            }
        }
        public int get_spotify_overwrite() {
            if (gsettings != null) {
                try {
                    return gsettings.get_int("spotify-overwrite");
                } catch (Error e) {
                    print("Warning: spotify-overwrite key not found: %s\n", e.message);
                }
            }
            return 0;
        }
        public void set_spotify_overwrite(int value) {
            if (gsettings != null) {
                try {
                    gsettings.set_int("spotify-overwrite", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-overwrite: %s\n", e.message);
                }
            }
        }
        public bool get_spotify_lyrics() {
            if (gsettings != null) {
                try {
                    return gsettings.get_boolean("spotify-lyrics");
                } catch (Error e) {
                    print("Warning: spotify-lyrics key not found: %s\n", e.message);
                }
            }
            return true;
        }
        public void set_spotify_lyrics(bool value) {
            if (gsettings != null) {
                try {
                    gsettings.set_boolean("spotify-lyrics", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-lyrics: %s\n", e.message);
                }
            }
        }
        public bool get_spotify_album_art() {
            if (gsettings != null) {
                try {
                    return gsettings.get_boolean("spotify-album-art");
                } catch (Error e) {
                    print("Warning: spotify-album-art key not found: %s\n", e.message);
                }
            }
            return true;
        }
        public void set_spotify_album_art(bool value) {
            if (gsettings != null) {
                try {
                    gsettings.set_boolean("spotify-album-art", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-album-art: %s\n", e.message);
                }
            }
        }
        public int get_spotify_search_provider() {
            if (gsettings != null) {
                try {
                    return gsettings.get_int("spotify-search-provider");
                } catch (Error e) {
                    print("Warning: spotify-search-provider key not found: %s\n", e.message);
                }
            }
            return 0;
        }
        public void set_spotify_search_provider(int value) {
            if (gsettings != null) {
                try {
                    gsettings.set_int("spotify-search-provider", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-search-provider: %s\n", e.message);
                }
            }
        }
        public int get_spotify_template() {
            if (gsettings != null) {
                try {
                    return gsettings.get_int("spotify-template");
                } catch (Error e) {
                    print("Warning: spotify-template key not found: %s\n", e.message);
                }
            }
            return 0;
        }
        public void set_spotify_template(int value) {
            if (gsettings != null) {
                try {
                    gsettings.set_int("spotify-template", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-template: %s\n", e.message);
                }
            }
        }
        public bool get_spotify_playlist_numbering() {
            if (gsettings != null) {
                try {
                    return gsettings.get_boolean("spotify-playlist-numbering");
                } catch (Error e) {
                    print("Warning: spotify-playlist-numbering key not found: %s\n", e.message);
                }
            }
            return true;
        }
        public void set_spotify_playlist_numbering(bool value) {
            if (gsettings != null) {
                try {
                    gsettings.set_boolean("spotify-playlist-numbering", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-playlist-numbering: %s\n", e.message);
                }
            }
        }
        public bool get_spotify_metadata() {
            if (gsettings != null) {
                try {
                    return gsettings.get_boolean("spotify-metadata");
                } catch (Error e) {
                    print("Warning: spotify-metadata key not found: %s\n", e.message);
                }
            }
            return true;
        }
        public void set_spotify_metadata(bool value) {
            if (gsettings != null) {
                try {
                    gsettings.set_boolean("spotify-metadata", value);
                } catch (Error e) {
                    print("Warning: Could not set spotify-metadata: %s\n", e.message);
                }
            }
        }
        public string get_cookies_path() {
            if (gsettings != null) {
                try {
                    return gsettings.get_string("cookies-path");
                } catch (Error e) {
                    print("Warning: cookies-path key not found: %s\n", e.message);
                }
            }
            return "";
        }
        public void set_cookies_path(string path) {
            if (gsettings != null) {
                try {
                    gsettings.set_string("cookies-path", path);
                } catch (Error e) {
                    print("Warning: Could not set cookies-path: %s\n", e.message);
                }
            }
        }
        public bool get_auto_update_cookies() {
            if (gsettings != null) {
                try {
                    return gsettings.get_boolean("auto-update-cookies");
                } catch (Error e) {
                    print("Warning: auto-update-cookies key not found: %s\n", e.message);
                }
            }
            return false;
        }
        public void set_auto_update_cookies(bool value) {
            if (gsettings != null) {
                try {
                    gsettings.set_boolean("auto-update-cookies", value);
                } catch (Error e) {
                    print("Warning: Could not set auto-update-cookies: %s\n", e.message);
                }
            }
        }
        public string get_effective_cookie_path() {
            string custom_path = get_cookies_path();

            if (custom_path.length > 0 && GLib.FileUtils.test(custom_path, GLib.FileTest.EXISTS)) {
                return custom_path;
            }

            string default_path = Path.build_filename(GLib.Environment.get_user_config_dir(), "ongaku", "cookies.txt");
            if (GLib.FileUtils.test(default_path, GLib.FileTest.EXISTS)) {
                return default_path;
            }

            return "";
        }
        public bool has_valid_cookies() {
            return get_effective_cookie_path().length > 0;
        }
        public string get_spotify_format_string() {
            string[] formats = {"mp3", "flac", "ogg", "m4a", "opus"};
            int index = get_spotify_format();
            return (index >= 0 && index < formats.length) ? formats[index] : "mp3";
        }
        public string get_spotify_bitrate_string() {
            string[] bitrates = {"auto", "320k", "256k", "192k", "128k"};
            int index = get_spotify_bitrate();
            return (index >= 0 && index < bitrates.length) ? bitrates[index] : "auto";
        }
        public string get_spotify_overwrite_string() {
            string[] modes = {"skip", "overwrite", "force"};
            int index = get_spotify_overwrite();
            return (index >= 0 && index < modes.length) ? modes[index] : "skip";
        }
        public string get_spotify_search_provider_string() {
            string[] providers = {"youtube", "youtube-music", "soundcloud", "bandcamp"};
            int index = get_spotify_search_provider();
            return (index >= 0 && index < providers.length) ? providers[index] : "youtube";
        }
        public string get_spotify_template_string() {
            string[] templates = {
                "{artist} - {title}",
                "{title} - {artist}",
                "{artist}/{album}/{title}",
                "{album}/{artist} - {title}",
                "{title}"
            };
            int index = get_spotify_template();
            return (index >= 0 && index < templates.length) ? templates[index] : "{artist} - {title}";
        }
    }
}


namespace Ongaku {
    public class Settings : Object {
        private GLib.Settings gsettings;


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
    }
}


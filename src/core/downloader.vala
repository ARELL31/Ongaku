using Posix;

namespace Ongaku {
    public class Downloader : Object {
        public async string download(string url, string output_dir, bool is_playlist) throws Error {
            return yield run_ytdlp(url, output_dir, is_playlist);
        }

        private async string run_ytdlp(string url, string output_dir, bool is_playlist) throws Error {
            string output_path = Path.build_filename(output_dir, "%(title)s.%(ext)s");

            string[] argv = {
                "yt-dlp",
                "-x",
                "--audio-format", "mp3",
                "--output", output_path
            };

            if (!is_playlist) {
                argv += "--no-playlist";
            }

            argv += url;

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
                    run_ytdlp.callback();
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

                string result_type = is_playlist ? "Playlist download" : "Download";
                return result_type + " completed successfully in " + output_dir;

            } catch (SpawnError e) {
                if (e.code == SpawnError.NOENT) {
                    throw new IOError.NOT_FOUND("yt-dlp is not installed. Install it with: sudo apt install yt-dlp");
                }
                throw new IOError.FAILED("Error running yt-dlp: " + e.message);
            }
        }
    }
}


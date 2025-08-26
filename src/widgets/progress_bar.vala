namespace Ongaku {
    public class ProgressIndicator : Gtk.Box {
        private Gtk.ProgressBar progress_bar;
        private Gtk.Label progress_text;
        private bool is_active = false;
        
        public ProgressIndicator() {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
            setup_ui();
        }
        
        private void setup_ui() {
            add_css_class("toolbar");
            
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
            
            append(progress_box);
        }
        
        public void start(string initial_text) {
            is_active = true;
            progress_bar.set_visible(true);
            progress_text.set_visible(true);
            progress_text.set_text(initial_text);
            progress_bar.set_text("0%");
            progress_bar.set_fraction(0.0);
            
            simulate_progress();
        }
        
        public void finish() {
            is_active = false;
            progress_bar.set_visible(false);
            progress_text.set_visible(false);
        }
        
        private void simulate_progress() {
            if (!is_active) return;
            
            string[] phases = {
                "Fetching video information...",
                "Extracting audio stream...",
                "Converting to MP3...",
                "Finalizing download..."
            };
            
            int phase = 0;
            double progress = 0.0;
            
            Timeout.add(300, () => {
                if (!is_active) return false;
                
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
                
                return is_active;
            });
        }
    }
}


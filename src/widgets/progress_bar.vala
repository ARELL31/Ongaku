namespace Ongaku {
    public class ProgressIndicator : Gtk.Box {
        private Gtk.ProgressBar progress_bar;
        private Gtk.Label progress_text;
        private uint timeout_id = 0;
        private bool is_active = false;
        
        public ProgressIndicator() {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
            setup_ui();
        }
        
        ~ProgressIndicator() {
            cleanup();
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
        
        public void start(string initial_text, string[]? custom_phases = null) {
            if (is_active) return;
            is_active = true;
            progress_bar.set_visible(true);
            progress_text.set_visible(true);
            progress_text.set_text(initial_text);
            progress_bar.set_text("0%");
            progress_bar.set_fraction(0.0);
            
            start_progress_simulation(custom_phases);
        }

        public void update_progress(double fraction, string text) {
            if (!is_active) return;

            progress_bar.set_fraction(fraction.clamp(0.0, 1.0));
            progress_bar.set_text("%.0f%%".printf(fraction * 100));
            progress_text.set_text(text);
        }
        
        public void finish() {
            if (!is_active) return;
            cleanup();
        }

        private void cleanup() {
            is_active = false;

            if (timeout_id != 0) {
                Source.remove(timeout_id);
                timeout_id = 0;
            }

            progress_bar.set_visible(false);
            progress_text.set_visible(false);
        }
        
        private void start_progress_simulation(string[]? custom_phases) {
            string[] phases;
            if (custom_phases != null) {
                phases = custom_phases;
            } else {
                phases = {
                    "Initializing...",
                    "Processing...",
                    "Finalizing..."
                };
            }
            
            int phase = 0;
            double progress = 0.0;
            
            timeout_id = Timeout.add(300, () => {
                if (!is_active) {
                    return false;
                }
                
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
                
                return true;
            });
        }

        public bool get_is_active() {
            return is_active;
        }
    }
}


namespace Ongaku {
    public class Application : Adw.Application {
        public Application() {
            Object(
                application_id: Config.APP_ID,
                flags: ApplicationFlags.FLAGS_NONE
            );
        }
        
        protected override void activate() {
            var window = new MainWindow(this);
            window.present();
        }

        protected override void startup() {
            base.startup();


            var quit_action = new GLib.SimpleAction("quit", null);
            quit_action.activate.connect(() => {
                quit();
            });
            add_action(quit_action);


            string[] quit_accels = {"<primary>q"};
            set_accels_for_action("app.quit", quit_accels);
        }
    }
}


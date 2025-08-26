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
    }
}


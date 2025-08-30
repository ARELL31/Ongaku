schemas = files('xyz.arell.ongaku.gschema.xml')
schemas_dir = get_option('datadir') / 'glib-2.0' / 'schemas'
install_data(schemas, install_dir: schemas_dir)

gnome = import('gnome')
gnome.compile_schemas(depend_files: schemas, build_by_default: true)

gnome.post_install(glib_compile_schemas: true)

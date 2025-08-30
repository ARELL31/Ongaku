project('ongaku', 'vala', 'c',
    version: '1.0.3',
    license: 'GPL-3.0-or-later'
)

dependencies = [
    dependency('gtk4'),
    dependency('libadwaita-1'),
    dependency('gio-2.0'),
]

sources = [
    'src/main.vala',
    'src/application.vala',
    'src/window.vala',
    'src/widgets/download_form.vala',
    'src/widgets/history_list.vala',
    'src/widgets/progress_bar.vala',
    'src/core/downloader.vala',
    'src/core/config.vala',
    'src/core/settings.vala',
    'src/utils/file_utils.vala',
    'src/dialogs/preferences.vala'
]

vala_args = [
    '--pkg=posix'
]

executable('ongaku', sources,
    dependencies: dependencies,
    vala_args: vala_args,
    install: true
)

# Procesar subdirectorio data (schemas)
subdir('data')

# SpotDL personalizado
install_subdir('spotdl-custom',
    install_dir: get_option('datadir') / 'ongaku'
)

# Script wrapper
configure_file(
    input: 'scripts/spotdl-wrapper.sh.in',
    output: 'spotdl-wrapper.sh',
    configuration: {'DATADIR': get_option('prefix') / get_option('datadir')},
    install: true,
    install_dir: get_option('bindir'),
    install_mode: 'rwxr-xr-x'
)

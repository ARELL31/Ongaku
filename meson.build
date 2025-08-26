project('ongaku', 'vala', 'c',
    version: '1.0.1',
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
    'src/utils/file_utils.vala'
]

vala_args = [
    '--pkg=posix'
]

executable('ongaku', sources,
    dependencies: dependencies,
    vala_args: vala_args,
    install: true
)

project('balss', ['c', 'vala'],        version: '0.0.1',
  meson_version: '>= 0.40.0',
)

i18n = import('i18n')

licenses_subdir = join_paths(get_option('datadir'), 'licenses', meson.project_name())
install_data('LICENSE',
    install_dir: licenses_subdir)

doc_subdir = join_paths(get_option('datadir'), 'doc', meson.project_name())
install_data('README.md',
install_dir: doc_subdir)

subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')

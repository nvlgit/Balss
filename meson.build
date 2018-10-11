project('Balss', ['c', 'vala'],
  version: '0.1.0',
  meson_version: '>= 0.40.0',
)

app_id = 'com.gitlab.nvlgit.' + meson.project_name()

i18n = import('i18n')

# Directory variables
bindir = get_option('bindir')
datadir = get_option('datadir')
desktopdir = join_paths(datadir, 'applications')
localedir = get_option('localedir')
po_dir = join_paths(meson.source_root(), 'po')
prefix = get_option('prefix')

doc_subdir = join_paths(datadir, 'doc', meson.project_name())
install_data('README.md',
    install_dir: doc_subdir)

licenses_subdir = join_paths(datadir, 'licenses', meson.project_name())
install_data('LICENSE',
    install_dir: licenses_subdir)


subdir('data')
subdir('src')
#subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
balss_sources = [
  'main.vala',
  'app.vala',
  'window.vala',
  'about-dialog.vala',
  'app-prefs.vala',
  'chapter-row.vala',
  'chapter-list-box.vala',
  'info-display.vala',
  'mpv-wrapper-backend.vala',
]

c_args = [
  '-DVERSION="' + meson.project_version() + '"',
  '-DAPP_ID="com.gitlab.nvlgit.Balss"',
  '-DGETTEXT_PACKAGE="com.gitlab.nvlgit.Balss"',
  '-DLOCALEDIR="' + join_paths(prefix, localedir) + '"'
]

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

balss_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('mpv', version: '>= 1.20'),
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : true)

gnome = import('gnome')

add_project_arguments(['--gresourcesdir', join_paths(meson.current_source_dir(), 'ui')],
                      language: 'vala')

add_project_arguments(['--gresourcesdir', join_paths(meson.source_root(), 'data', 'icons', 'hicolor', 'scalable', 'apps')],
                      language: 'vala')



balss_sources += gnome.compile_resources('balss-resources',
  'balss.gresource.xml',
  source_dir: join_paths(meson.current_source_dir(), 'ui'),
  c_name: 'balss'
)

executable(app_id, balss_sources,
  vala_args: '--target-glib=2.50',
  c_args: c_args,
  dependencies: [balss_deps, m_dep],
  install: true,
)
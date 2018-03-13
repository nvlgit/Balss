balss_sources = [
  'main.vala',
  'app.vala',
  'app-about-dialog.vala',
  'app-prefs-dialog.vala',
  'player-app-window.vala',
  'open-dialog.vala',
]

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

balss_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libvlc', version: '>= 3.0.0'),
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : true)

gnome = import('gnome')

add_project_arguments(['--gresourcesdir', join_paths(meson.current_source_dir(), 'ui')],
                      language: 'vala')


balss_sources += gnome.compile_resources('balss-resources',
  'balss.gresource.xml',
  source_dir: join_paths(meson.current_source_dir(), 'ui'),
  c_name: 'balss'
)

executable('balss', balss_sources,
  vala_args: '--target-glib=2.50',  dependencies: [balss_deps, m_dep],
  install: true,
)

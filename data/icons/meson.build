icon_sizes = ['scalable']

foreach s: icon_sizes
  install_data(
    join_paths('hicolor', s, 'apps', app_id + '.svg'),
               install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', s, 'apps')
  )
endforeach

install_data(
  join_paths('hicolor', 'symbolic', 'apps', app_id + '-symbolic.svg'),
             install_dir: join_paths(datadir, 'icons', 'hicolor', 'symbolic', 'apps')
)

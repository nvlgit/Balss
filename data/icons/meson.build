icon_sizes = ['16x16', '24x24', '32x32', '64x64', '128x128', 'scalable']

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
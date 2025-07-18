# It may be useful to use a prebuilt server, so that no Android SDK is required
# to build. If the 'prebuilt_server' option is set, just copy the file as is.
message('🌼 Checking prebuilt_server option...')
prebuilt_server = get_option('prebuilt_server')
message('🌼 prebuilt_server value: ' + prebuilt_server)

if prebuilt_server == ''
    message('🌼 Building scrcpy-server from source using gradle...')
    message('🌼 Build type: ' + get_option('buildtype'))
    message('🌼 Source directory: ' + meson.current_source_dir())
    custom_target('scrcpy-server',
                  # gradle is responsible for tracking source changes
                  build_by_default: true,
                  build_always_stale: true,
                  output: 'scrcpy-server',
                  command: [find_program('scripts/build-wrapper.sh'), meson.current_source_dir(), '@OUTPUT@', get_option('buildtype')],
                  console: true,
                  install: true,
                  install_dir: 'share/scrcpy')
    message('🌼 scrcpy-server build target configured successfully')
else
    message('🌼 Using prebuilt scrcpy-server from: ' + prebuilt_server)
    if not prebuilt_server.startswith('/')
        # prebuilt server path is relative to the root scrcpy directory
        prebuilt_server = '../' + prebuilt_server
        message('🌼 Adjusted prebuilt server path to: ' + prebuilt_server)
    endif
    message('🌼 Configuring prebuilt server copy target...')
    custom_target('scrcpy-server-prebuilt',
                  input: prebuilt_server,
                  output: 'scrcpy-server',
                  command: ['cp', '@INPUT@', '@OUTPUT@'],
                  install: true,
                  install_dir: 'share/scrcpy')
    message('🌼 scrcpy-server-prebuilt target configured successfully')
endif

message('🌼 Checking meson version for development environment setup...')
if meson.version().version_compare('>= 0.58.0')
       message('🌼 Meson version >= 0.58.0, setting up development environment...')
       devenv = environment()
       devenv.set('SCRCPY_SERVER_PATH', meson.current_build_dir() / 'scrcpy-server')
       meson.add_devenv(devenv)
       message('🌼 Development environment configured with SCRCPY_SERVER_PATH: ' + (meson.current_build_dir() / 'scrcpy-server'))
else
       message('🌼 Meson version < 0.58.0, skipping development environment setup')
endif

message('🌼 Server meson.build configuration completed')

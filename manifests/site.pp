require boxen::environment
require homebrew
require gcc

$nodejs_version = '4.4.3'

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.8': }
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }
  nodejs::version { '4.4.3': }

  # default ruby versions
  ruby::version { '1.8.7-p358': }
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.2': }
  ruby::version { '2.1.8': }
  ruby::version { '2.2.4': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar',
      'unrar',
      'mariadb',
      'tig',
      'jetty',
      'sbt',
      'sqlite',
      'wget',
      'nmap',
      'ffmpeg',
      'imagemagick',
      'watch',
      'maven'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  include mongodb
  include bash
  include bash::completion
  include java

  class { 'vagrant':
    version => '1.8.1',
  }

  ruby_gem { "librarian-puppet for 2.1.0":
    gem          => 'librarian-puppet',
    version      => '2.2.1',
    ruby_version => '2.1.0'
  }

  ruby_gem { "librarian-puppet for 2.1.2":
    gem          => 'librarian-puppet',
    version      => '2.2.1',
    ruby_version => '2.1.2'
  }

  ruby_gem { "puppet for 2.1.0":
    gem          => 'puppet',
    ruby_version => '2.1.0'
  }

  ruby_gem { "puppet for 2.1.2":
    gem          => 'puppet',
    ruby_version => '2.1.2'
  }

  ruby_gem { "rhc for 2.1.0":
    gem          => 'rhc',
    ruby_version => '2.1.0'
  }

  ruby_gem { "rhc for 2.1.2":
    gem          => 'rhc',
    ruby_version => '2.1.2'
  }

  ruby_gem { "json for 2.1.0":
    gem          => 'json',
    ruby_version => '2.1.0'
  }

  ruby_gem { "json for 2.1.2":
    gem          => 'json',
    ruby_version => '2.1.2'
  }

  ruby_gem { "shenzhen for 2.1.0":
    gem          => 'shenzhen',
    ruby_version => '2.1.0'
  }

  ruby_gem { "shenzhen for 2.1.2":
    gem          => 'shenzhen',
    ruby_version => '2.1.2'
  }

  class { 'nodejs::global':
    version => $::nodejs_version,
  }

  npm_module { 'bower':
    module       => 'bower',
    node_version => $::nodejs_version,
  }

  include android::sdk
  android::version { '17': }

  include openssl

}

name             'applications'
maintainer       "vhyza.eu"
maintainer_email "vhyza@vhyza.eu"
license          'MIT'
description      'Installs/Configures applications'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

depends 'elasticsearch'
depends 'redisio'
depends 'rbenv'
depends 'openssl'

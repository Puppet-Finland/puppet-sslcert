#
# == Class: sslcert::params
#
# Defines some variables based on the operating system
#
class sslcert::params {

    include ::os::params

    case $::osfamily {
        'RedHat': {
            $pki_dir = '/etc/pki/tls'
        }
        'Debian': {
            $pki_dir = '/etc/ssl'
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }

    $keydir = "${pki_dir}/private"
    $certdir = "${pki_dir}/certs"
}

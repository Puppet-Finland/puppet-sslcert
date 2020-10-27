#
# == Class: sslcert::params
#
# Defines some variables based on the operating system
#
class sslcert::params {

    case $facts['os']['family'] {
        'RedHat': {
            $pki_dir = '/etc/pki/tls'
            $group = 'root'
        }
        'Debian': {
            $pki_dir = '/etc/ssl'
            $group = 'ssl-cert'
        }
        default: {
            fail("Unsupported OS: ${facts['os']['family']}")
        }
    }

    $keydir = "${pki_dir}/private"
    $certdir = "${pki_dir}/certs"
}

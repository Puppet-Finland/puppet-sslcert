#
# == Class: sslcert::params
#
# Defines some variables based on the operating system
#
class sslcert::params {

    case $facts['os']['family'] {
        'RedHat': {
            $pki_dir = '/etc/pki/tls'
            $owner = 'root'
            $cert_group = 'root'
            $cert_mode = '0644'
            $private_key_group = 'root'
            $private_key_mode = '0600'
        }
        'Debian': {
            $pki_dir = '/etc/ssl'
            $owner = 'root'
            $cert_group = 'root'
            $cert_mode = '0644'
            $private_key_group = 'root'
            $private_key_mode = '0640'
        }
        default: {
            fail("Unsupported OS: ${facts['os']['family']}")
        }
    }

    $keydir = "${pki_dir}/private"
    $certdir = "${pki_dir}/certs"
}

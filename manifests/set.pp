#
# == Define: sslcert::set
#
# Install a set of SSL certificates
#
# == Parameters
#
# [*ensure*]
#   State of this SSL certificate set. Valid values are 'present' (default) and 
#   'absent'.
# [*title*]
#   The resource title is used as the basename of the key and certificate file. 
#   For example, if $title is set to 'www.domain.com', the target files will be 
#   'www.domain.com.crt' and 'www.domain.com.key', and the source files (on the 
#   Puppet fileserver) should be 'sslcert-www.domain.com.crt' and 
#   'sslcert-www.domain.com.key'.
# [*bundlefile*]
#   Full name of the bundle file, including the file extension. For example 
#   'ca-bundle.crt'. Defaults to undef, meaning that a bundle is not installed.
# [*embed_bundle*]
#   Whether to combine the bundle with the certificate. Valid values are true 
#   and false. This must be true for nginx and false for apache2. Defaults to 
#   false.
#
define sslcert::set
(
    Enum['present','absent'] $ensure = 'present',
    Optional[String]         $bundlefile = undef,
    Boolean                  $embed_bundle = false
)
{
    include ::sslcert::params

    $basename = $title
    $keyfile = "${basename}.key"
    $certfile = "${basename}.crt"

    File {
        ensure => $ensure,
        owner  => 'root',
        group  => $::sslcert::params::group,
    }

    Concat {
        ensure => $ensure,
        owner  => 'root',
        group  => $::sslcert::params::group,
    }

    # The key will always be installed as-is
    file { "sslcert-${keyfile}":
        name   => "${::sslcert::params::keydir}/${keyfile}",
        source => "puppet:///files/sslcert-${keyfile}",
        mode   => '0600',
    }

    # We might not need a CA bundle if the existing ones are enough, or if we're 
    # installing self-signed certificates.
    if $bundlefile {

        # Combine certificate and bundle into one for nginx
        if $embed_bundle {

            $target = "sslcert-${basename}-cert-and-bundle"

            concat { $target:
                path  => "${::sslcert::params::certdir}/${certfile}",
            }
            concat::fragment { "sslcert-${basename}-cert":
                source => "puppet:///files/sslcert-${certfile}",
                # The certificate must be placed at the head
                order  => '1',
                target => $target,
            }
            concat::fragment { "sslcert-${basename}-bundle":
                source => "puppet:///files/${bundlefile}",
                order  => '2',
                target => $target,
            }
        } else {
            file { "sslcert-${bundlefile}":
                name   => "${::sslcert::params::certdir}/${bundlefile}",
                source => "puppet:///files/${bundlefile}",
                mode   => '0644',
            }
            file { "sslcert-${certfile}":
                name   => "${::sslcert::params::certdir}/${certfile}",
                source => "puppet:///files/sslcert-${certfile}",
                mode   => '0644',
            }
        }
    }
}

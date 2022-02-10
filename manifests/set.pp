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
# [*bundlefile_content*]
#   Full content of the bundle file. If not present, the bundle is taken from
#   puppet:///files/${bundlefile}.
# [*certfile_content*]
#   Full content of the certificate. If not present, the certificate is taken from
#   puppet:///files/sslcert-${title}.crt.
# [*keyfile_content*]
#   Full content of the private key. If not present, the key is taken from
#   puppet:///files/sslcert-${title}.key.
# [*embed_bundle*]
#   Whether to combine the bundle with the certificate. Valid values are true 
#   and false. This must be true for nginx and false for apache2. Defaults to 
#   false.
#
define sslcert::set
(
    Enum['present','absent'] $ensure = 'present',
    Optional[String]         $bundlefile = undef,
    Optional[String]         $bundlefile_content = undef,
    Optional[String]         $certfile_content = undef,
    Optional[String]         $keyfile_content = undef,
    Boolean                  $embed_bundle = false
)
{
    include ::sslcert::params

    $basename = $title
    $keyfile = "${basename}.key"
    $certfile = "${basename}.crt"
    $certfile_attr = {
        'ensure' => $ensure,
        'owner'  => $::sslcert::params::owner,
        'group'  => $::sslcert::params::cert_group,
        'mode'   => $::sslcert::params::cert_mode,
    }

    # The key will always be installed as-is
    file { "sslcert-${keyfile}":
        ensure => $ensure,
        name   => "${::sslcert::params::keydir}/${keyfile}",
        owner  => $::sslcert::params::owner,
        group  => $::sslcert::params::private_key_group,
        mode   => $::sslcert::params::private_key_mode,
    }
    if $keyfile_content {
        File["sslcert-${keyfile}"] {
            content => $keyfile_content,
        }
    } else {
        File["sslcert-${keyfile}"] {
            source => "puppet:///files/sslcert-${keyfile}", # lint:ignore:puppet_url_without_modules
        }
    }

    unless $embed_bundle {
        file { "sslcert-${certfile}":
            name => "${::sslcert::params::certdir}/${certfile}",
            *    => $certfile_attr,
        }
        if $certfile_content {
            File["sslcert-${certfile}"] {
                content => $certfile_content,
            }
        } else {
            File["sslcert-${certfile}"] {
                source => "puppet:///files/sslcert-${certfile}", # lint:ignore:puppet_url_without_modules
            }
        }
    }


    # We might not need a CA bundle if the existing ones are enough, or if we're
    # installing self-signed certificates.
    if $bundlefile {

        # Combine certificate and bundle into one for nginx
        if $embed_bundle {

            $target = "sslcert-${basename}-cert-and-bundle"

            concat { $target:
                path => "${::sslcert::params::certdir}/${certfile}",
                *    => $certfile_attr,
            }
            if $certfile_content {
                concat::fragment { "sslcert-${basename}-cert":
                    content => $certfile_content,
                    # The certificate must be placed at the head
                    order   => '1',
                    target  => $target,
                }
            } else {
                concat::fragment { "sslcert-${basename}-cert":
                    source => "puppet:///files/sslcert-${certfile}", # lint:ignore:puppet_url_without_modules
                    # The certificate must be placed at the head
                    order  => '1',
                    target => $target,
                }
            }
            if $bundlefile_content {
                concat::fragment { "sslcert-${basename}-bundle":
                    content => $bundlefile_content,
                    order   => '2',
                    target  => $target,
                }
            } else {
                concat::fragment { "sslcert-${basename}-bundle":
                    source => "puppet:///files/${bundlefile}", # lint:ignore:puppet_url_without_modules
                    order  => '2',
                    target => $target,

                }
            }
        } else {
            if $bundlefile_content {
                file { "sslcert-${bundlefile}":
                    name    => "${::sslcert::params::certdir}/${bundlefile}",
                    content => $bundlefile_content,
                    *       => $certfile_attr,
                }
            } else {
                file { "sslcert-${bundlefile}":
                    name   => "${::sslcert::params::certdir}/${bundlefile}",
                    source => "puppet:///files/${bundlefile}", # lint:ignore:puppet_url_without_modules
                    *      => $certfile_attr,
                }
            }
        }
    }
}

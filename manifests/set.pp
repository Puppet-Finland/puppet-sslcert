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
#   Full name of the bundle file, including the file extension. This determines
#   the name of the bundlefile on target system. Also, if $bundlefile_content is
#   not defined, it defines the name of the bundlefile on the Puppet fileserver.
#   Example: 'ca-bundle.crt'. Defaults to undef, meaning that a bundle is not
#   installed.
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

    $bundlefile_source = $bundlefile_content ? {
      undef   => "puppet:///files/${bundlefile}", # lint:ignore:puppet_url_without_modules
      default => undef
    }

    $certfile_source = $certfile_content ? {
      undef   => "puppet:///files/sslcert-${certfile}", # lint:ignore:puppet_url_without_modules
      default => undef
    }

    $keyfile_source = $keyfile_content ? {
      undef   => "puppet:///files/sslcert-${keyfile}", # lint:ignore:puppet_url_without_modules
      default => undef
    }

    # The key will always be installed as-is
    file { "sslcert-${keyfile}":
        ensure  => $ensure,
        name    => "${::sslcert::params::keydir}/${keyfile}",
        content => $keyfile_content,
        source  => $keyfile_source,
        owner   => $::sslcert::params::owner,
        group   => $::sslcert::params::private_key_group,
        mode    => $::sslcert::params::private_key_mode,
    }

    # We might not need a CA bundle if the existing ones are enough, or if we're 
    # installing self-signed certificates.
    if $bundlefile {

        # Combine certificate and bundle into one for nginx
        if $embed_bundle {

            $target = "sslcert-${basename}-cert-and-bundle"

            concat { $target:
                ensure => $ensure,
                path   => "${::sslcert::params::certdir}/${certfile}",
                owner  => $::sslcert::params::owner,
                group  => $::sslcert::params::cert_group,
                mode   => $::sslcert::params::cert_mode,
            }
            concat::fragment { "sslcert-${basename}-cert":
                source  => $certfile_source,
                content => $certfile_content,

                # The certificate must be placed at the head
                order   => '1',
                target  => $target,
            }
            concat::fragment { "sslcert-${basename}-bundle":
                source  => $bundlefile_source,
                content => $bundlefile_content,
                order   => '2',
                target  => $target,
            }
        } else {
            file { "sslcert-${bundlefile}":
                ensure  => $ensure,
                name    => "${::sslcert::params::certdir}/${bundlefile}",
                source  => $bundlefile_source,
                content => $bundlefile_content,
                owner   => $::sslcert::params::owner,
                group   => $::sslcert::params::cert_group,
                mode    => $::sslcert::params::cert_mode,

            }
            file { "sslcert-${certfile}":
                ensure  => $ensure,
                name    => "${::sslcert::params::certdir}/${certfile}",
                source  => $certfile_source,
                content => $certfile_content,
                owner   => $::sslcert::params::owner,
                group   => $::sslcert::params::cert_group,
                mode    => $::sslcert::params::cert_mode,
            }
        }
    } else {
        file { "sslcert-${certfile}":
            ensure  => $ensure,
            name    => "${::sslcert::params::certdir}/${certfile}",
            source  => $certfile_source,
            content => $certfile_content,
            owner   => $::sslcert::params::owner,
            group   => $::sslcert::params::cert_group,
            mode    => $::sslcert::params::cert_mode,
        }
    }
}

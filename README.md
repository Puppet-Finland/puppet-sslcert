# sslcert

A Puppet module for managing one or more sets of SSL certificates. A set is
composed of a certificate and a key, and an optional CA bundle. The bundle may
be used as is (for Apache2) or combined with the certificate (for nginx).

This module can be safely used even if the webserver is _not_ managed by Puppet. 
Even in that case it can notify the defined webserver service when any of the 
files have changed.

# Module usage

The ::sslcert::set define supports two sources for the the certificate, key and
CA bundle:

* Parameters (e.g. string from hiera-eyaml)
* Puppet fileserver

These can also be mixed, so you could get your cert and CA bundle from the
Puppet fileserver, but the private key from hiera-eyaml, passing it to the
define as a string.

Using this module from another class is simple:

    include ::sslcert
    
    sslcert::set { 'www.domain.com':
        bundlefile   => 'ca-bundle.crt',
        embed_bundle => false,
    }

## Passing certs as paramaters

The relevant parameters in ::sslcert::set are:

* bundlefile: target filename for the bundle
* bundlefile_content: content of the bundle
* certfile_content: content of the certificate
* keyfile_content: content of the keyfile

If any of the content parameters are set, then Puppet does not try to fetch
that particular file from the Puppet fileserver.

## Getting certs from the Puppet fileserver

To use the Puppet fileserver approach put your certificates to the "files"
share and name them like this:

* sslcert-${basename}.crt
* sslcert-${basename}.key

Where ${basename} defaults to the title of the ::sslcert::set defined resource. 
If you want to install a CA bundle, simply copy it to the "files" directory and 
pass the filename, including the file extension, as the $bundlefile parameter of 
the ::sslcert::set resource. Next a few examples using Hiera.

## Automatic resource creation in main class

The main class does not do anything except support creating resources from a
hash. To Install a certificate, key and a separate bundle file (e.g. for apache2).

    sslcert::sets:
        www.domain.com:
            bundlefile: 'ca-bundle.crt'

The same as above, but for nginx:

    sslcert::sets:
        www.domain.com:
            bundlefile: 'ca-bundle.crt'
            embed_bundle: true

Only install a certificate and a key, omitting the bundle:

    sslcert::sets:
        internal.company.com: {}

You can of course define as many ::sslcert::set resources as you need.

Example of usage from within a node manifest:

    $sets = { 'www.domain.com' => { 'bundlefile'   => 'ca-bundle.crt',
                                    'embed_bundle' => false,
                                  }
    }
    
    class { '::sslcert':
        sets => $sets,
    }

# sslcert

A Puppet module for managing one or more sets of SSL certificates. A set is
composed of a certificate and a key, and an optional CA bundle. The bundle may
be used as is (for Apache2) or combined with the certificate (for nginx).

This module can be safely used even if the webserver is _not_ managed by Puppet. 
Even in that case it can notify the defined webserver service when any of the 
files have changed.

# Module usage

First put your certificates to the Puppet fileserver under the "files" 
directory and name them like this:

* sslcert-${basename}.crt
* sslcert-${basename}.key

Where ${basename} defaults to the title of the ::sslcert::set defined resource. 
If you want to install a CA bundle, simply copy it to the "files" directory and 
pass the filename, including the file extension, as the $bundlefile parameter of 
the ::sslcert::set resource. Next a few examples using Hiera.

You always need to include the main class, unless you create your resources 
using create_resource functions in site.pp:

    include ::sslcert

Install a certificate, key and a separate bundle file (e.g. for apache2).

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

Usage from another class, without having the ::sslcert main class as a 
middleman:

    include ::sslcert
    
    sslcert::set { 'www.domain.com':
        bundlefile   => 'ca-bundle.crt',
        embed_bundle => false,
    }

Please refer to the class documentation for details:

* [Class: sslcert](manifests/init.pp)
* [Define: sslcert::set](manifests/set.pp)

# Dependencies

See [metadata.json](metadata.json).

# Operating system support

This module has been tested on

* Fedora 23
* Ubuntu 14.04

Any *NIX-style operating system should work out of the box or with small
modifications.

For details see [params.pp](manifests/params.pp).

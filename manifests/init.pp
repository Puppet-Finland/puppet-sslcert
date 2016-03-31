#
# == Class: sslcert
#
# This is a simple wrapper class around the defines that do the actual work.
#
# == Parameters
#
# [*manage*]
#   Whether to manage SSL certificates using this class. Valid values are true 
#   (default) and false.
# [*sets*]
#   A hash of ::sslcert::set resources to realize. Each set manages a key,
#   a certificate and an optional bundle.
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class sslcert
(
    $manage = true,
    $sets = {}

) inherits sslcert::params
{

validate_bool($manage)

if $manage {
    create_resources('sslcert::set', $sets)
}
}

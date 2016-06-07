package Catmandu::Util::Package;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use Catmandu::Util::Type qw(is_invocant);
use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(use_lib require_package);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

sub use_lib {
    my (@dirs) = @_;

    use lib;
    local $@;
    lib->import(@dirs);
    Catmandu::Error->throw($@) if $@;

    1;
}

sub require_package {
    my ($pkg, $ns) = @_;

    if ($ns) {
        unless ($pkg =~ s/^\+// || $pkg =~ /^$ns/) {
            $pkg = "${ns}::$pkg";
        }
    }

    return $pkg if is_invocant($pkg);

    eval "require $pkg;1;"
        or Catmandu::NoSuchPackage->throw(
        message      => "No such package: $pkg",
        package_name => $pkg
        );

    $pkg;
}

1;

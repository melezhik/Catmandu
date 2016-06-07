package Catmandu::Util::Compare;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use Data::Compare ();
use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(is_same is_different check_same check_different);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

*is_same = \&Data::Compare::Compare;

sub is_different {
    !is_same(@_);
}

sub check_same {
    is_same(@_) || Catmandu::BadVal->throw('should be same');
    $_[0];
}

sub check_different {
    is_same(@_) && Catmandu::BadVal->throw('should be different');
    $_[0];
}

1;

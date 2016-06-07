package Catmandu::Util::String;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(as_utf8 trim capitalize);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

sub as_utf8 {
    my $str = $_[0];
    utf8::upgrade($str);
    $str;
}

sub trim {
    my $str = $_[0];
    if ($str) {
        $str =~ s/^[\h\v]+//s;
        $str =~ s/[\h\v]+$//s;
    }
    $str;
}

sub capitalize {
    my $str = $_[0];
    utf8::upgrade($str);
    ucfirst lc $str;
}

1;

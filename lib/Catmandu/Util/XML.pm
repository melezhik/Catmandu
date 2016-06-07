package Catmandu::Util::XML;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use namespace::clean;
use Exporter qw(import);

our @EXPORT_OK = qw(xml_declaration xml_escape);

my $XML_DECLARATION = qq(<?xml version="1.0" encoding="UTF-8"?>\n);

sub xml_declaration {
    $XML_DECLARATION;
}

sub xml_escape {
    my ($str) = @_;
    utf8::upgrade($str);

    $str =~ s/&/&amp;/go;
    $str =~ s/</&lt;/go;
    $str =~ s/>/&gt;/go;
    $str =~ s/"/&quot;/go;
    $str =~ s/'/&apos;/go;

    # remove control chars
    $str
        =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//go;

    $str;
}

1;

package Catmandu::Util::Hash;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use Hash::Merge::Simple ();
use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(hash_merge);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

*hash_merge = \&Hash::Merge::Simple::merge;

1;

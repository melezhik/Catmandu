package Catmandu::Util::Pod;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use Pod::Usage;
use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(pod_section);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

sub pod_section {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $section = uc(shift);

    unless (-r $class) {
        $class =~ s!::!/!g;
        $class .= '.pm';
        $class = $INC{$class} or return '';
    }

    my $text = "";
    open my $input, "<", $class or return '';
    open my $output, ">", \$text;

    Pod::Usage::pod2usage(
        -input    => $input,
        -output   => $output,
        -sections => $section,
        -exit     => "NOEXIT",
        -verbose  => 99,
        -indent   => 0,
        -utf8     => 1,
        @_
    );
    $section = ucfirst(lc($section));
    $text =~ s/$section:\n//m;
    chomp $text;

    $text;
}

1;

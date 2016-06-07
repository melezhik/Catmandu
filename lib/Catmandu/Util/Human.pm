package Catmandu::Util::Human;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(human_number human_content_type human_byte_size);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

my $HUMAN_CONTENT_TYPES = {

    # txt
    'text/plain'      => 'Text',
    'application/txt' => 'Text',

    # pdf
    'application/pdf'      => 'PDF',
    'application/x-pdf'    => 'PDF',
    'application/acrobat'  => 'PDF',
    'applications/vnd.pdf' => 'PDF',
    'text/pdf'             => 'PDF',
    'text/x-pdf'           => 'PDF',

    # doc
    'application/doc'         => 'Word',
    'application/vnd.msword'  => 'Word',
    'application/vnd.ms-word' => 'Word',
    'application/winword'     => 'Word',
    'application/word'        => 'Word',
    'application/x-msw6'      => 'Word',
    'application/x-msword'    => 'Word',

    # docx
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        => 'Word',

    # xls
    'application/vnd.ms-excel'   => 'Excel',
    'application/msexcel'        => 'Excel',
    'application/x-msexcel'      => 'Excel',
    'application/x-ms-excel'     => 'Excel',
    'application/vnd.ms-excel'   => 'Excel',
    'application/x-excel'        => 'Excel',
    'application/x-dos_ms_excel' => 'Excel',
    'application/xls'            => 'Excel',

    # xlsx
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' =>
        'Excel',

    # ppt
    'application/vnd.ms-powerpoint' => 'PowerPoint',
    'application/mspowerpoint'      => 'PowerPoint',
    'application/ms-powerpoint'     => 'PowerPoint',
    'application/mspowerpnt'        => 'PowerPoint',
    'application/vnd-mspowerpoint'  => 'PowerPoint',
    'application/powerpoint'        => 'PowerPoint',
    'application/x-powerpoint'      => 'PowerPoint',

    # pptx
    'application/vnd.openxmlformats-officedocument.presentationml.presentation'
        => 'PowerPoint',

    # csv
    'text/comma-separated-values' => 'CSV',
    'text/csv'                    => 'CSV',
    'application/csv'             => 'CSV',

    # zip
    'application/zip' => 'ZIP archive',
};

sub human_number {    # taken from Number::Format
    my $num = $_[0];

    # add leading 0's so length($num) is divisible by 3
    $num = '0' x (3 - (length($num) % 3)) . $num;

    # split $num into groups of 3 characters and insert commas
    $num = join ',', grep {$_ ne ''} split /(...)/, $num;

    # strip off leading zeroes and/or comma
    $num =~ s/^0+,?//;
    length $num ? $num : '0';
}

sub human_byte_size {
    my ($size) = @_;
    if ($size > 1000000000) {
        return sprintf("%.2f GB", $size / 1000000000);
    }
    elsif ($size > 1000000) {
        return sprintf("%.2f MB", $size / 1000000);
    }
    elsif ($size > 1000) {
        return sprintf("%.2f KB", $size / 1000);
    }
    "$size bytes";
}

sub human_content_type {
    my ($content_type, $default) = @_;
    my ($key) = $content_type =~ /^([^;]+)/;
    $HUMAN_CONTENT_TYPES->{$key} // $default // $content_type;
}

1;

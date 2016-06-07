package Catmandu::Util::IO;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use IO::File;
use IO::Handle::Util ();
use YAML::XS         ();
use Cpanel::JSON::XS ();
use File::Spec;
use Catmandu::Util::Type qw(:is);
use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK
    = qw(io read_file read_io write_file read_yaml read_json join_path
    normalize_path segmented_path)

    our %EXPORT_TAGS = (all => \@EXPORT_OK,);

sub io {
    my ($arg, %opts) = @_;
    my $binmode = $opts{binmode} || $opts{encoding} || ':encoding(UTF-8)';
    my $mode = $opts{mode} || 'r';
    my $io;

    if (is_scalar_ref($arg)) {
        $io = IO::Handle::Util::io_from_scalar_ref($arg);
        defined($io) && binmode $io, $binmode;
    }
    elsif (is_glob_ref(\$arg) || is_glob_ref($arg)) {
        $io = IO::Handle->new_from_fd($arg, $mode) // $arg;
        defined($io) && binmode $io, $binmode;
    }
    elsif (is_string($arg)) {
        $io = IO::File->new($arg, $mode);
        defined($io) && binmode $io, $binmode;
    }
    elsif (is_code_ref($arg) && $mode eq 'r') {
        $io = IO::Handle::Util::io_from_getline($arg);
    }
    elsif (is_code_ref($arg) && $mode eq 'w') {
        $io = IO::Handle::Util::io_from_write_cb($arg);
    }
    elsif (is_instance($arg, 'IO::Handle')) {
        $io = $arg;
        defined($io) && binmode $io, $binmode;
    }
    else {
        Catmandu::BadArg->throw("can't make io from argument");
    }

    $io;
}

# Deprecated use tools like File::Slurp::Tiny
sub read_file {
    my ($path) = @_;
    local $/;
    open my $fh, "<:encoding(UTF-8)", $path
        or Catmandu::Error->throw(qq(can't open "$path" for reading));
    my $str = <$fh>;
    close $fh;
    $str;
}

sub read_io {
    my ($io) = @_;
    $io->binmode("encoding(UTF-8)") if $io->can('binmode');
    my @lines = ();
    while (<$io>) {
        push @lines, $_;
    }
    $io->close();
    join "", @lines;
}

# Deprecated use tools like File::Slurp::Tiny
sub write_file {
    my ($path, $str) = @_;
    open my $fh, ">:encoding(UTF-8)", $path
        or Catmandu::Error->throw(qq(can't open "$path" for writing));
    print $fh $str;
    close $fh;
    $path;
}

sub read_yaml {

    # dies on error
    YAML::XS::LoadFile($_[0]);
}

sub read_json {
    my $text = read_file($_[0]);

    # dies on error
    Cpanel::JSON::XS->new->decode($text);
}

sub join_path {
    my $path = File::Spec->catfile(@_);
    $path =~ s!/\./!/!g;
    while ($path =~ s![^/]*/\.\./!!) { }
    $path;
}

sub normalize_path {    # taken from Dancer::FileUtils
    my ($path) = @_;
    $path =~ s!/\./!/!g;
    while ($path =~ s![^/]*/\.\./!!) { }
    File::Spec->catfile($path);
}

sub segmented_path {
    my ($id, %opts) = @_;
    my $segment_size = $opts{segment_size} || 3;
    my $base_path = $opts{base_path};
    $id =~ s/[^0-9a-zA-Z]+//g;
    my @path = unpack "(A$segment_size)*", $id;
    defined $base_path
        ? File::Spec->catdir($base_path, @path)
        : File::Spec->catdir(@path);
}

1;

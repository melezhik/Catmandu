package Catmandu::Util::Data;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use Catmandu::Util::Type qw(check_string is_ref is_array_ref is_hash_ref
    is_integer is_natural);
use Catmandu::Util::Array qw(array_exists);
use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(parse_data_path get_data set_data delete_data data_at);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

sub parse_data_path {
    my ($path) = @_;
    check_string($path);
    $path = [split /[\/\.]/, $path];
    my $key = pop @$path;
    return $path, $key;
}

sub get_data {
    my ($data, $key) = @_;
    if (is_array_ref($data)) {
        if    ($key eq '$first') {return unless @$data; $key = 0}
        elsif ($key eq '$last')  {return unless @$data; $key = @$data - 1}
        elsif ($key eq '*') {return @$data}
        if (array_exists($data, $key)) {
            return $data->[$key];
        }
        return;
    }
    if (is_hash_ref($data) && exists $data->{$key}) {
        return $data->{$key};
    }
    return;
}

sub set_data {
    my ($data, $key, @vals) = @_;
    return unless @vals;
    if (is_array_ref($data)) {
        if    ($key eq '$first') {return unless @$data; $key = 0}
        elsif ($key eq '$last')  {return unless @$data; $key = @$data - 1}
        elsif ($key eq '$prepend') {
            unshift @$data, $vals[0];
            return $vals[0];
        }
        elsif ($key eq '$append') {push @$data, $vals[0]; return $vals[0]}
        elsif ($key eq '*') {return splice @$data, 0, @$data, @vals}
        return $data->[$key] = $vals[0] if is_natural($key);
        return;
    }
    if (is_hash_ref($data)) {
        return $data->{$key} = $vals[0];
    }
    return;
}

sub delete_data {
    my ($data, $key) = @_;
    if (is_array_ref($data)) {
        if    ($key eq '$first') {return unless @$data; $key = 0}
        elsif ($key eq '$last')  {return unless @$data; $key = @$data - 1}
        elsif ($key eq '*') {return splice @$data, 0, @$data}
        if (array_exists($data, $key)) {
            return splice @$data, $key, 1;
        }
        return;
    }
    if (is_hash_ref($data) && exists $data->{$key}) {
        return delete $data->{$key};
    }

    return;
}

sub data_at {
    my ($path, $data, %opts) = @_;
    if (ref $path) {
        $path = [map {split /[\/\.]/} @$path];
    }
    else {
        $path = [split /[\/\.]/, $path];
    }
    my $create = $opts{create};
    my $_key = $opts{_key} // $opts{key};
    if (defined $opts{key} && $create && @$path) {
        push @$path, $_key;
    }
    my $key;
    while (defined(my $key = shift @$path)) {
        is_ref($data) || return;
        if (is_array_ref($data)) {
            if ($key eq '*') {
                return
                    map {data_at($path, $_, create => $create, _key => $_key)}
                    @$data;
            }
            else {
                if    ($key eq '$first') {$key = 0}
                elsif ($key eq '$last')  {$key = -1}
                elsif ($key eq '$prepend') {unshift @$data, undef; $key = 0}
                elsif ($key eq '$append') {push @$data, undef; $key = @$data}
                is_integer($key) || return;
                if ($create && @$path) {
                    $data = $data->[$key] ||= is_integer($path->[0])
                        || ord($path->[0]) == ord('$') ? [] : {};
                }
                else {
                    $data = $data->[$key];
                }
            }
        }
        elsif ($create && @$path) {
            $data = $data->{$key} ||= is_integer($path->[0])
                || ord($path->[0]) == ord('$') ? [] : {};
        }
        else {
            $data = $data->{$key};
        }
        if ($create && @$path == 1) {
            last;
        }
    }
    $data;
}

1;

package Catmandu::Util::Array;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use List::Util qw(reduce sum);
use Catmandu::Util::Type qw(is_natural is_array_ref);
use Catmandu::Util::Compare qw(is_same);
use namespace::clean;
use parent 'Exporter';

our @EXPORT_OK = qw(array_exists array_group_by array_pluck array_to_sentence
    array_sum array_includes array_any array_rest array_uniq array_split);

our %EXPORT_TAGS = (all => \@EXPORT_OK,);

sub array_exists {
    my ($arr, $i) = @_;
    is_natural($i) && $i < @$arr;
}

sub array_group_by {
    my ($arr, $key) = @_;
    reduce {
        my $k = $b->{$key};
        push @{$a->{$k} ||= []}, $b if defined $k;
        $a
    }
    {}, @$arr;
}

sub array_pluck {
    my ($arr, $key) = @_;
    my @vals = map {$_->{$key}} @$arr;
    \@vals;
}

sub array_to_sentence {
    my ($arr, $join, $join_last) = @_;
    $join      //= ', ';
    $join_last //= ' and ';
    my $size = scalar @$arr;
    $size > 2
        ? join($join_last, join($join, @$arr[0 .. $size - 2]), $arr->[-1])
        : join($join_last, @$arr);
}

sub array_sum {
    sum(0, @{$_[0]});
}

sub array_includes {
    my ($arr, $val) = @_;
    is_same($val, $_) && return 1 for @$arr;
    0;
}

sub array_any {
    my ($arr, $sub) = @_;
    $sub->($_) && return 1 for @$arr;
    0;
}

sub array_rest {
    my ($arr) = @_;
    @$arr < 2 ? [] : [@$arr[1 .. (@$arr - 1)]];
}

sub array_uniq {
    my ($arr) = @_;
    my %seen = ();
    my @vals = grep {not $seen{$_}++} @$arr;
    \@vals;
}

sub array_split {
    my ($arr) = @_;
    is_array_ref($arr) ? $arr : [split ',', $arr];
}

1;

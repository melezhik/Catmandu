package Catmandu::Util::Type;

use Catmandu::Sane;

our $VERSION = '1.0201_02';

use Scalar::Util qw(blessed);
use Ref::Util ();
use Sub::Quote qw(quote_sub);
use parent 'Exporter';

our %EXPORT_TAGS = (is => [qw()], check => [qw()],);

# also edit @Catmandu::Util::TYPES
my @TYPES = qw(able instance invocant ref
    scalar_ref array_ref hash_ref code_ref regex_ref glob_ref
    bool value string number integer natural positive);

for (@TYPES) {
    push @{$EXPORT_TAGS{is}},    "is_$_",    "is_maybe_$_";
    push @{$EXPORT_TAGS{check}}, "check_$_", "check_maybe_$_";
}

our @EXPORT_OK = map {@$_} values %EXPORT_TAGS;

$EXPORT_TAGS{all} = \@EXPORT_OK;

# avoid circular dependency
require Catmandu::Util::Array;

# the following code is taken from Data::Util::PurePerl 0.63
sub _get_stash {
    my ($inv) = @_;

    if (blessed($inv)) {
        no strict 'refs';
        return \%{ref($inv) . '::'};
    }
    elsif (!is_string($inv)) {
        return undef;
    }

    $inv =~ s/^:://;
    my $pkg = *main::;
    for my $part (split /::/, $inv) {
        return undef unless $pkg = $pkg->{$part . '::'};
    }
    return *{$pkg}{HASH};
}

sub _get_code_ref {
    my ($pkg, $name, @flags) = @_;

    is_string($pkg)  || Catmandu::BadVal->throw('should be string');
    is_string($name) || Catmandu::BadVal->throw('should be string');

    my $stash = _get_stash($pkg) or return undef;

    if (defined(my $glob = $stash->{$name})) {
        if (is_glob_ref(\$glob)) {
            return *{$glob}{CODE};
        }
        else {    # a stub or special constant
            no strict 'refs';
            return *{$pkg . '::' . $name}{CODE};
        }
    }
    return undef;
}

sub is_invocant {
    my ($inv) = @_;
    if (is_ref($inv)) {
        return !!blessed($inv);
    }
    else {
        return !!_get_stash($inv);
    }
}

*is_scalar_ref = \&Ref::Util::is_plain_scalarref;

sub is_array_ref {
    Ref::Util::is_plain_arrayref($_[0]);
}

*is_hash_ref = \&Ref::Util::is_plain_hashref;

*is_code_ref = \&Ref::Util::is_plain_coderef;

*is_regex_ref = \&Ref::Util::is_regexpref;

*is_glob_ref = \&Ref::Util::is_plain_globref;

sub is_value {
    defined($_[0]) && !is_ref($_[0]) && !is_glob_ref(\$_[0]);
}

sub is_string {
    is_value($_[0]) && length($_[0]) > 0;
}

sub is_number {
    return 0 if !defined($_[0]) || is_ref($_[0]);

    return $_[0] =~ m{
        \A \s*
                [+-]?
                (?= \d | \.\d)
                \d*
                (\.\d*)?
                (?: [Ee] (?: [+-]? \d+) )?
        \s* \z
    }xms;
}

sub is_integer {
    return 0 if !defined($_[0]) || is_ref($_[0]);

    return $_[0] =~ m{
        \A \s*
                [+-]?
                \d+
        \s* \z
    }xms;
}

# end of code taken from Data::Util

sub is_bool {
    blessed($_[0])
        && ($_[0]->isa('boolean')
        || $_[0]->isa('Types::Serialiser::Boolean')
        || $_[0]->isa('JSON::XS::Boolean')
        || $_[0]->isa('Cpanel::JSON::XS::Boolean')
        || $_[0]->isa('JSON::PP::Boolean'));
}

sub is_natural {
    is_integer($_[0]) && $_[0] >= 0;
}

sub is_positive {
    is_integer($_[0]) && $_[0] >= 1;
}

*is_ref = \&Ref::Util::is_ref;

sub is_able {
    my $obj = shift;
    is_invocant($obj) || return 0;
    $obj->can($_) || return 0 for @_;
    1;
}

sub check_able {
    my $obj = shift;
    return $obj if is_able($obj, @_);
    Catmandu::BadVal->throw(
        'should be able to ' . Catmandu::Util::Array::array_to_sentence(\@_));
}

sub check_maybe_able {
    my $obj = shift;
    return $obj if is_maybe_able($obj, @_);
    Catmandu::BadVal->throw('should be undef or able to '
            . Catmandu::Util::Array::array_to_sentence(\@_));
}

sub is_instance {
    my $obj = shift;
    blessed($obj) || return 0;
    $obj->isa($_) || return 0 for @_;
    1;
}

sub check_instance {
    my $obj = shift;
    return $obj if is_instance($obj, @_);
    Catmandu::BadVal->throw('should be instance of '
            . Catmandu::Util::Array::array_to_sentence(\@_));
}

sub check_maybe_instance {
    my $obj = shift;
    return $obj if is_maybe_instance($obj, @_);
    Catmandu::BadVal->throw('should be undef or instance of '
            . Catmandu::Util::Array::array_to_sentence(\@_));
}

for my $sym (@TYPES) {
    my $pkg      = __PACKAGE__;
    my $err_name = $sym;
    $err_name =~ s/_/ /;
    push @EXPORT_OK, "is_$sym", "is_maybe_$sym", "check_$sym",
        "check_maybe_$sym";
    push @{$EXPORT_TAGS{is}},    "is_$sym",    "is_maybe_$sym";
    push @{$EXPORT_TAGS{check}}, "check_$sym", "check_maybe_$sym";
    quote_sub("${pkg}::is_maybe_$sym",
        "!defined(\$_[0]) || ${pkg}::is_$sym(\$_[0])")
        unless _get_code_ref($pkg, "is_maybe_$sym");
    quote_sub("${pkg}::check_$sym",
        "${pkg}::is_$sym(\$_[0]) || Catmandu::BadVal->throw('should be $err_name'); \$_[0]"
    ) unless _get_code_ref($pkg, "check_$sym");
    quote_sub("${pkg}::check_maybe_$sym",
        "${pkg}::is_maybe_$sym(\$_[0]) || Catmandu::BadVal->throw('should be undef or $err_name'); \$_[0]"
    ) unless _get_code_ref($pkg, "check_maybe_$sym");
}

1;

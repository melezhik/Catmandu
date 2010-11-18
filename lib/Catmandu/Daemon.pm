package Catmandu::Daemon;

use 5.010;
use Moose::Role;

with 'MooseX::Daemonize';

requires 'run_daemon';

after start => sub {
    my $self = shift;
    $self->run_daemon if $self->is_daemon;
};

sub _usage_format {
    "usage: %c %o start|stop|restart|status";
}

sub run {
    my $self = shift;
    my $ctrl = $self->extra_argv->[0];
    given ($ctrl) {
        when ('start')   { $self->start }
        when ('stop')    { $self->stop }
        when ('restart') { $self->restart }
        when ('status')  { $self->status }
        default {
            $self->usage->die;
        }
    }
}

no Moose::Role;
__PACKAGE__;

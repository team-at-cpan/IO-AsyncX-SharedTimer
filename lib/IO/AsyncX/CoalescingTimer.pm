package IO::AsyncX::CoalescingTimer;
# ABSTRACT: 
use strict;
use warnings;

use parent qw(IO::Async::Notifier);

our $VERSION = '0.001';

=head1 NAME

IO::AsyncX::CoalescingTimer -

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use Time::HiRes ();
use curry::weak;

=head1 METHODS

=cut

sub configure {
	my ($self, %args) = @_;
	if(exists $args{resolution}) {
		$self->{resolution} = delete $args{resolution};
	}
	$self->SUPER::configure(%args);
}

sub resolution { shift->{resolution} }

sub now {
	my ($self) = @_;
	$self->{after} ||= $self->loop->delay_future(
		after => $self->resolution
	)->on_ready($self->curry::weak::expire);
	$self->{now} //= Time::HiRes::time;
}

sub expire {
	my ($self) = @_;
	delete @{$self}{qw(now after)};
}

1;

__END__

=head1 SEE ALSO

=head1 AUTHOR

Tom Molesworth <cpan@perlsite.co.uk>

=head1 LICENSE

Copyright Tom Molesworth 2014. Licensed under the same terms as Perl itself.


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

BEGIN {
	for my $m (qw(delay_future timeout_future)) {
		no strict 'refs';
		*{__PACKAGE__ . '::' . $m} = sub {
			my ($self, %args) = @_;
			my $at = exists $args{at} ? delete $args{at} : $self->now + delete $args{after}
				or die "Invalid or unspecified time";
			my $bucket = int(($at - $^T) / $self->resolution);
			my $f = $self->loop->new_future;
			($self->{bucket}{$bucket} ||= $self->loop->$m(at => $at))->on_ready($f);
			$f
		};
	}
}

1;

__END__

=head1 SEE ALSO

=head1 AUTHOR

Tom Molesworth <cpan@perlsite.co.uk>

=head1 LICENSE

Copyright Tom Molesworth 2014. Licensed under the same terms as Perl itself.


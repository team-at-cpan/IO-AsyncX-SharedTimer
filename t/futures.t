use strict;
use warnings;

use Test::More;
use Test::Fatal;

use IO::AsyncX::CoalescingTimer;

use IO::Async::Loop;

my $loop = IO::Async::Loop->new;
$loop->add(
	my $timer = new_ok('IO::AsyncX::CoalescingTimer', [
		resolution => '0.05',
	])
);

is(exception {
	$timer->delay_future(
		after => 0.5
	)->get;
}, undef, 'delay_future completes without raising an exception');

like(exception {
	$timer->timeout_future(
		after => 0.5
	)->get;
}, qr/\btimeout\b/i, 'timeout future does indeed raise a timeout');

isnt(
	$timer->delay_future(after => 0.5), 
	$timer->delay_future(after => 0.5), 
	'two delay_futures are always different'
);

my @times = map 
	$timer->delay_future(
		after => 0.5
	)->transform(
		done => sub { ''.$timer->now }
	), 1..5;

is_deeply([ Future->needs_all(@times)->get ], [ ($timer->now) x 5 ], 'times are all the same');

done_testing;


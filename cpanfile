requires 'parent', 0;
requires 'curry', 0;
requires 'Future', '>= 0.30';
requires 'IO::Async', '>= 0.64';

on 'test' => sub {
	requires 'Test::More', '>= 0.98';
	requires 'Test::Fatal', '>= 0.010';
	recommends 'Test::MemoryGrowth', 0;
};


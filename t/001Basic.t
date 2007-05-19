######################################################################
# Test suite for Device::MAS345
# by Mike Schilli <cpan@perlmeister.com>
######################################################################

use warnings;
use strict;

use Test::More qw(no_plan);
use Device::MAS345;
use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);

my $mas = Device::MAS345->new( port => "/dev/ttyS0" );

my($mode, $val, $unit) = $mas->read();

if(!$mode) {
   die "Cannot read (", $mas->error(), ")";
}

print "mode=$mode val=$val unit=$unit\n";

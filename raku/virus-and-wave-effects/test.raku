use lib '.';
use GTX;

my $config = "config/Provence-to-1900.gtx".IO.slurp;
say $config;

my %h = from-gtx( $config );
say %h;

say to-gtx( %h );


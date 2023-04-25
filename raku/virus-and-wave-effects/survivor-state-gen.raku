use lib '.';
use UWP;
use Sector;

my $description = q:to/END/;
*********************************************************
*                                                       *
*   Survivor States are pocket empires. They typically  *
*   have an irregular radius.                         	*
*                                                       *
*********************************************************
END

my Sector $sector = Sector.new;
my %visited;

sub MAIN( $sectorName ) {

    my $source = "output/$sectorName.tab";
	$sector.readFile( $source );

	#
	#  Let's put the strong worlds in a list and pick one randomly.
	#
	my @strongWorlds = $sector.find-strong-worlds;
	my $choice = (0..@strongWorlds.elems-1).pick;
	my $chosen = @strongWorlds[ $choice ];

    my $ok = so $chosen;

    unless $ok {
		die @strongWorlds.elems, " strong worlds found in $sector\n";
		exit;
	}

	#
	#  OK we've picked one at random.
	#  Let's give it a name.
	#
	my $alleg = ('A'..'Z').pick ~ ('a','e','i','o','u','y').pick
	          ~ ('A'..'Z').pick ~ ('a','e','i','o','u','y').pick;

	$chosen.set-allegiance( $alleg ); # I wonder if this is a reference or a copy?

    #
	#  Now use a combination of random walk and cellular operations
	#  to grow a pockete mpreu. 
	#
	my $col = $chosen.get-col;
	my $row = $chosen.get-row;
	my $run = (^6).pick + 1;

	for 1..$run {
		claimArea($row-1, $col, $alleg) if rand < 0.5;
		claimArea($row+1, $col, $alleg) if rand < 0.5;
		claimArea($row, $col-1, $alleg) if rand < 0.5;
		claimArea($row, $col+1, $alleg) if rand < 0.5;
	}

	$sector.dump;
}

sub claimArea( $row, $col, $alleg ) {

    return if $row < 1 || $row > 40 || $col < 1 || $col > 32;
	my $hex = sprintf( "%02d%02d", $col, $row );

	return if %visited{ $hex };
	%visited{ $hex } = 1;

	$sector.set-allegiance( $hex, $alleg );

	claimArea($row-1, $col, $alleg) if rand < 0.5;
	claimArea($row+1, $col, $alleg) if rand < 0.5;
	claimArea($row, $col-1, $alleg) if rand < 0.5;
	claimArea($row, $col+1, $alleg) if rand < 0.5;
}
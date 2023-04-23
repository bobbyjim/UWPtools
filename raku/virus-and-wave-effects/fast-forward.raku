use lib '.';
use UWP;
use Util;
use Travellermap-Config;

sub MAIN( $sector ) {

    my $source = "../../../travellermap/res/t5ss/data/$sector.tab";
	die "ERROR: sector $source not found" unless $source.IO.e;

	my $file = "config/$sector" ~ '-to-1900.toml';
	die "ERROR: config file not found for $sector" unless $file.IO.e;

	say $sector, ':';
	say "\tSource File     \t $source";

	my ($header, @lines) =$source.IO.lines;
	my @header = $header.split(/\t/);

	my $config = Travellermap-Config.new;
	my @order = $config.parse( $file );
	say $config.summary;

	my $milieu1201     = $header ~ "\n";
	my $milieuPostwave = $header ~ "\n";
	my $milieu1508     = $header ~ "\n";
	my $milieu1900     = $header ~ "\n";
	my $allThree       = "Year\t" ~ $header ~ "\n";
	my $beginningYear  = 1105;

	for @lines -> $line {
		next if $line ~~ /\?\?\?\?\?\?\?\-\?/;

		#  Build a hash from this UWP line and the Header line.
		my @field = $line.split(/\t/);
		my %fieldHash = @header Z=> @field; # Zip into a hash!

		#  Build a UWP from the hash.
    	my $uwp = UWP.new;
    	$uwp.build( %fieldHash );
        $allThree   ~= "$beginningYear\t" ~ $uwp.show-line ~ "\n";

		for @order -> $command {
			if $command eq 'wave' {
				do-wave( $config, $uwp );
				$milieuPostwave ~= $uwp.show-line ~ "\n";
				$allThree   ~= $config.get-exit-year ~ "\t" ~ $uwp.show-line ~ "\n";

				# 1508
				$uwp.wave4-do-one-recovery-epoch(-1);
				$milieu1508 ~= $uwp.show-line ~ "\n";
				$allThree   ~= "1508\t" ~ $uwp.show-line ~ "\n";
			}
			elsif $command eq 'virus' {			
				do-virus( $config, $uwp );	
				$milieu1201 ~= $uwp.show-line ~ "\n";
				$allThree   ~= "1201\t" ~ $uwp.show-line ~ "\n";
			}
			elsif $command eq 'garden' {
				$uwp.do-garden-world;
			}
		}
		
		# 1900
		$uwp.wave4-do-one-recovery-epoch(0);
		$milieu1900 ~= $uwp.show-line ~ "\n";
		$allThree   ~= "1900\t" ~ $uwp.show-line ~ "\n";

		$allThree ~= "\n";
	}

    my $exit-year = $config.get-exit-year;

	"output/$sector.1201.tab".IO.spurt: $milieu1201; 			
	"output/$sector.$exit-year.tab".IO.spurt: $milieuPostwave; 	
	"output/$sector.1508.tab".IO.spurt: $milieu1508;
	"output/$sector.1900.tab".IO.spurt: $milieu1900;	
	"output/$sector.all.txt".IO.spurt:  $allThree;

	m: say "\tRun Time         \t ", (((now - INIT now)*10).Int / 10), ' seconds';
}

sub do-virus( $config, $uwp ) {
	if $config.do-virus($uwp.get-hex, $uwp.get-allegiance) {
		$uwp.do-virus-except-recovery;
		$uwp.virus9-recovery;
	}
}

sub do-wave( $config, $uwp ) {
	if $config.in-cow( $uwp.get-hex ) { 
		# $uwp.set-allegiance( 'CoWx' );
	} else {
		$uwp.do-wave-except-recovery;
		$uwp.set-allegiance( 'Wild' );
	}
}

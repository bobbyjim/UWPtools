



sub MAIN( $milieu, $sector, $allegiance ) {

	say "Source Milieu:\t $milieu";
	say "Sector:       \t $sector";
	say "Allegiance:   \t $allegiance";

    my $sourceFile = "../../../travellermap/res/Sectors/$milieu/$sector.tab";

	say "$sourceFile not found." unless $sourceFile.IO.e;

	my ($header, @lines) =$sourceFile.IO.lines;
	my @header = $header.split(/\t/);

	if $allegiance eq '?' {
		my %allegianceIndex;
		for @lines -> $line {
			next if $line ~~ /\?\?\?\?\?\?\?\-\?/;

			#  Build a hash from this UWP line and the Header line.
			my @field = $line.split(/\t/);
			my %fieldHash = @header Z=> @field; # Zip into a hash!

			my $key = 'Allegiance';
			$key = 'Alleg' if %fieldHash.EXISTS-KEY('Alleg');

			%allegianceIndex{ %fieldHash{ $key } }++;
		}

		say "Allegiance codes present:";
		for %allegianceIndex.keys -> $key {
			say "   $key\t(", %allegianceIndex{$key}, ")";
		}
	}
}
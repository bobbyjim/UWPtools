use Util;
use UWP;

class Sector is export {

	has %!uwps-by-hex;
	has @!header;

    method readFile( $source ) {
		die "ERROR: sector $source not found" unless $source.IO.e;

		my ($header, @lines) =$source.IO.lines;
		@!header = $header.split(/\t/);

		for @lines -> $line {
			next if $line ~~ /\?\?\?\?\?\?\?\-\?/;

			#  Build a hash from this UWP line and the Header line.
			my @field = $line.split(/\t/);
			my %fieldHash = @!header Z=> @field; # Zip into a hash!

			#  Build a UWP from the hash.
    		my $uwp = UWP.new;
    		$uwp.build( %fieldHash );

			%!uwps-by-hex{ $uwp.get-hex } = $uwp;
		}
	} 

	method dump {
		say @!header.join( "\t" );
		for %!uwps-by-hex.keys.sort -> $hex {
			say %!uwps-by-hex{ $hex }.show-line;
		}
	}

	method get-uwp( $hex ) { %!uwps-by-hex{ $hex } }

	method is-wilds( $hex ) { 
		return False unless %!uwps-by-hex.EXISTS-KEY( $hex );
		my UWP $uwp = &.get-uwp( $hex );
		return $uwp.allegiance-is( 'Wild' );
	}

	method has-system( $hex ) {
		return %!uwps-by-hex.EXISTS-KEY( $hex );
	}

	method set-allegiance( $hex, $alleg ) {
		return unless %!uwps-by-hex.EXISTS-KEY( $hex );
		my UWP $uwp = &.get-uwp( $hex );
		$uwp.set-allegiance( $alleg );
	}

	method find-strong-worlds {
		my @strongWorlds = ();
		for %!uwps-by-hex.values -> $uwp {
			@strongWorlds.push($uwp) if $uwp.is-strong-world;
		}
		return @strongWorlds;
	}
}
use Config::TOML;
use Util;

class Travellermap-Config is export {

	has Str $!exit-year;
	has @!order;
	has Str $!order;

	has %!wave-preserve-area;
	has $!virus-preserve-allegiances;
	has $!virus-kill-hexes;
	has $!virus-preserve-hexes;

    method get-exit-year { return $!exit-year }

	method includes-virus { return $!order ~~ /virus/ }
	method includes-wave  { return $!order ~~ /wave/  }

	method parse( $file ) {
		my %toml = from-toml( :$file );
		$!exit-year = "unknown";
   		$!exit-year = (1199 + 41.47 * (2 + %toml<location><y>)).Int.Str
			if %toml<location>.EXISTS-KEY('y');

		@!order = %toml{ 'default-order' }.flat;
		$!order = @!order.join( ' ' );
		$!order ~= " *NO VIRUS* " unless $!order ~~ /virus/;
		$!order ~= " *NO WAVE* "  unless $!order ~~ /wave/;

		%!wave-preserve-area = ();
		if %toml.EXISTS-KEY('wave') {
		    %!wave-preserve-area = %toml<wave><preserve-area> if %toml<wave>.EXISTS-KEY('preserve-area');
		}

		$!virus-preserve-allegiances	= '';
		$!virus-preserve-hexes			= '';
		$!virus-kill-hexes				= '';
		
		if %toml.EXISTS-KEY('virus') {
			$!virus-preserve-allegiances = %toml<virus><preserve-by-allegiances> if %toml<virus>.EXISTS-KEY('preserve-by-allegiances');
			$!virus-kill-hexes = %toml<virus><kill-hexes> if %toml<virus>.EXISTS-KEY('kill-hexes');
			$!virus-preserve-hexes = %toml<virus><preserve-by-hex> if %toml<virus>.EXISTS-KEY('preserve-by-hex');
		}

		return @!order;
	}

	method summary {
		my @out;
    	push @out, "\tDefault Order    \t " ~ @!order;
		push @out, "\tWave Exit year   \t $!exit-year";
		push @out, "\tCOW location     \t " ~ %!wave-preserve-area<center> if %!wave-preserve-area;
		push @out, "\tVirus preserves  \t " ~ $!virus-preserve-allegiances if $!virus-preserve-allegiances;
		return @out.join( "\n" );
	}

	method in-cow($hex) {
		return unless %!wave-preserve-area<center>;

		my @hex = Util.hex2rowcol( $hex );
    	my $dist = Util.distance( %!wave-preserve-area<center>, @hex );
		return $dist <= %!wave-preserve-area<radius>;		
	}

	method do-virus($hex, $allegiance) {		
		my $do-virus = True;
		if $!virus-kill-hexes {
			$do-virus = False;
			$do-virus = True if $!virus-kill-hexes ~~ /$hex/ || $!virus-preserve-allegiances !~~ /$allegiance/;
		}		
		$do-virus = False if $!virus-preserve-hexes ~~ /$hex/;
		return $do-virus;
	}
}

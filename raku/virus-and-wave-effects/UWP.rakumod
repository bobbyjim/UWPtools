
#  subset UwpType of Str where * ~~ /^<[ABCDEFGHXY]>\d\d\d\d\d\d\-\w$/;

class UWP is export {

    has Str $!hex;
	has Str $!name;

	has Str $!starport;
	has Int $!siz;
	has Int $!atm;
	has Int $!hyd;
	has Int $!pop;
	has Int $!gov;
	has Int $!law;
	has Int $!tl;
	has Int $!initial-tl-roll;
	has Int $!tl-reduction is default(0);

    has Str @!specialRemarks;

	has Bool $!hasNIL;
	has Str  $!NIL;

	has Str $!scout-base;
	has Str $!navy-base;
	has Str $!zone;
	has Int $!pop-mult;
	has Int $!belts;
	has Int $!ggs;
	has Str $!allegiance;

	has Str $!stars;
	has Str $!ix;
	
	has Int $!resources;
	has Int $!base-resources;
	has Int $!labor;
	has Int $!infrastructure;
	has Int $!efficiency;

	has Str $!cx;	
	has Str $!nobility;
	has Str $!otherWorlds;
	has Str $!RU;

	my %hdh = ( 0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8,
	9=>9, A=>10, B=>11, C=>12, D=>13, E=>14, F=>15, G=>16, H=>17, J=>18,
	10=>'A', 11=>'B', 12=>'C', 13=>'D', 14=>'E', 15=>'F', 16=>'G', 17=>'H', 18=>'J',
	);

	method minflux {
		my $f1 = (^6).pick - (^6).pick;
		$f1 = -1 if $f1 < 0;
		$f1 = 1  if $f1 > 0;
		return $f1;
	}

    method get-planetary-remarks {
		my @r;
		my $str = &.show;

		push @r, 'As' if $str ~~ /^.000/;
		push @r, 'De' if $str ~~ /^..<[2..9]>0/;
		push @r, 'Fl' if $str ~~ /^..<[ABC]><[1..9A]>/;
		push @r, 'Ga' if $str ~~ /^.<[678]><[568]><[567]>/;
		push @r, 'He' if $str ~~ /^.<[3..9ABC]><[2479ABC]><[012]>/;
		push @r, 'Ic' if $str ~~ /^..<[01]><[1..9A]>/;
		push @r, 'Oc' if $str ~~ /^.<[A..F]><[3..9DEF]>A/;
		push @r, 'Va' if $str ~~ /^.<[^0]>0/;
		push @r, 'Wa' if $str ~~ /^.<[3..9]><[3..9DEF]>A/;

		return @r.join(' ');
	}

	method get-population-remarks {
		my @r;
		my $str = &.show;

        push @r, 'Cy' if $str ~~ /^....<[5..9A]>6<[0123]>/; # COLONY ADDED HERE.
		push @r, 'Di' if $str ~~ /^....000\-<[^0]>/;
		push @r, 'Ba' if $str ~~ /^....000\-0/;
		push @r, 'Lo' if $str ~~ /^....<[123]>/;
		push @r, 'Ni' if $str ~~ /^....<[456]>/;
		push @r, 'Ph' if $str ~~ /^....8/;
		push @r, 'Hi' if $!pop >= 9;

		return @r.join(' ');
	}

	method get-economic-remarks {
		my @r;
		my $str = &.show;

		push @r, 'Pa' if $str ~~ /^..<[4..9]><[4..8]><[48]>/;
		push @r, 'Ag' if $str ~~ /^..<[4..9]><[4..8]><[567]>/;
		push @r, 'Na' if $str ~~ /^..<[0123]><[0123]><[6789A..F]>/;
		push @r, 'Px' if $str ~~ /^..<[23AB]><[1..5]><[3456]>.<[6789]>/;
		push @r, 'Pi' if $str ~~ /^..<[012479]>.<[78]>/;
		push @r, 'In' if $str ~~ /^..<[012479ABC]>.<[9A..F]>/;
		push @r, 'Po' if $str ~~ /^..<[2345]><[0123]>/;
		push @r, 'Pr' if $str ~~ /^..<[68]>.<[59]>/;
		push @r, 'Ri' if $str ~~ /^..<[68]>.<[678]>/;

		return @r.join(' ');
	}

	method get-climate-remarks( Int $hz ) {
		my @r;
		my $str = &.show;

		push @r, 'Fr' if $hz > 1 && $str ~~ /^.<[2..9]>.<[1..9A]>/;
		push @r, 'Ho' if $hz < 0;
		push @r, 'Co' if $hz == 1;
		push @r, 'Tr' if $hz < 0 && $str ~~ /^.<[6789]><[4..9]><[3..7]>/;
		push @r, 'Tu' if $hz > 0 && $str ~~ /^.<[6789]><[4..9]><[3..7]>/;

		return @r.join(' ');
	}

    #
	#  If we don't already know, then respond based on the data. 
	#
    method determine-NIL {
		my $str = &.show;

		return "(XN)"   if $str ~~ /^..0<[2..9DEF]>.0..\-0$/;
		return "(EXN)"  if $str ~~ /^..<[ABC]>.0..\-0$/;    
		return "(CXN)"  if $str ~~ /^..0<[2..9DEF]>.0..\-<[^0]>$/;
		return "(CEXN)" if $str ~~ /^..<[ABC]>.0..\-<[^0]>$/;    

        return "" if $!pop < 7;

		return "(ENIL)" if $str ~~ /^..<[ABC]>/;
		return "(NIL)"  if $str ~~ /^..<[2..9DEF]>/;

		return ""; # finally
	}

    method set-NIL( Bool $b ) {
		$!hasNIL = $b;
	}
	
	method set-pm( Int $pm ) {
		$!pop-mult = $pm;
	}

	method set-zone( Str $z ) {
		$!zone = $z;
	}

    method get-bases {
		return ($!scout-base ?? $!scout-base !! ' ')
		     ~ ($!navy-base  ?? $!navy-base  !! '');
	}

    method get-tl { $!tl }
	method get-pm { $!pop-mult }
	method get-zone { $!zone }

    method is-dieback(-->Bool) {
		if ($!pop == 0)
		{
			$!pop-mult = 0;
			$!gov      = 0;
			$!law      = 0;
			$!starport = 'D' if $!starport ~~ /<[ABC]>/;
			$!starport = 'G' if $!starport ~~ /<[F]>/;
			return True;
		}
		return False;
	}

#
#   Here's the keys I'm expecting in this hash:
#
#   Sector	
#   SS	
#   Hex	
#   Name	
# 	UWP	
#	Bases	
#	Remarks	
#	Zone	
#	PBG	
#	Allegiance	
#	Stars	
#	{Ix}	
#	(Ex)	
#	[Cx]	
#	Nobility	
#	W	
#	RU
#
    method build( %uwpLine ) {
		&.parse( %uwpLine{'UWP'} );
		&.parseBases( %uwpLine{'Bases'} );
		&.parseNIL( %uwpLine{'Remarks'});
		&.parseSpecialRemarks( %uwpLine{'Remarks'});
		$!zone         = %uwpLine{'Zone'};
		&.parsePBG( %uwpLine{'PBG'});
		$!allegiance   = %uwpLine{'Allegiance'};
		$!stars        = %uwpLine{'Stars'};
		&.parseIx( %uwpLine{'{Ix}'});
	    &.parseEx( %uwpLine{'(Ex)'}, $!tl, $!belts, $!ggs ); 
	    $!cx           = %uwpLine{'[Cx]'};
	    $!nobility     = %uwpLine{'Nobility'};
	    $!otherWorlds  = %uwpLine{'W'};   
	    $!RU           = %uwpLine{'RU'};
	}

    method parseIx( $ix ) {
		$!ix = $ix;
		$!ix ~~ s:g/<[{} ]>//;
	}

	method parseEx( $ex, $tl, $belts, $ggs ) {
		#
		#  NNNsN, where s is sign + or -
		#
		my $sign;
		my $temp-ex = $ex;
		$temp-ex ~~ s:g/<[()\s]>//;
		my @temp-ex = $temp-ex.split('');
	    
		$!resources 	 = %hdh{ @temp-ex[1] };
		$!labor     	 = %hdh{ @temp-ex[2] };
		$!infrastructure = %hdh{ @temp-ex[3] };
		$!efficiency     = @temp-ex[5].Int;
		$!efficiency = -$!efficiency if @temp-ex[4] eq '-';

		$!base-resources = $!resources;
		$!base-resources = $!base-resources - $belts - $ggs if $tl < 8;
		$!base-resources = 2 if $!base-resources < 2;  # Sanity check.  2 is the lowest roll on 2D
	}

	method parse( $uwp ) {
		my ($garbage, $starport, $siz, $atm, $hyd, $pop, $gov, $law, $dash, $tl) = $uwp.split('');
		$!starport = $starport;
		$!siz = %hdh{ $siz };
		$!atm = %hdh{ $atm };
		$!hyd = %hdh{ $hyd };
		$!pop = %hdh{ $pop }; 
		$!gov = %hdh{ $gov };
		$!law = %hdh{ $law };
		$!tl  = %hdh{ $tl };

		# determine initial TL roll
		$!initial-tl-roll = $!tl;

		if ($!pop > 0)
        {
		   $!initial-tl-roll -= 6 if $!starport eq 'A';
		   $!initial-tl-roll -= 4 if $!starport eq 'B';
		   $!initial-tl-roll -= 2 if $!starport eq 'C';
		   $!initial-tl-roll -= 1 if $!starport eq 'F';
		   $!initial-tl-roll += 4 if $!starport eq 'X';

	   	   $!initial-tl-roll -= 2 if $!siz <= 1;
		   $!initial-tl-roll -= 1 if 2 <= $!siz <= 4;

	   	   $!initial-tl-roll -= 1 if $!atm <= 3;
		   $!initial-tl-roll -= 2 if $!atm >= 10;

	   	   $!initial-tl-roll -= 1 if $!hyd == 9;
		   $!initial-tl-roll -= 2 if $!hyd == 10;

	   	   $!initial-tl-roll -= 1 if $!pop < 6;
		   $!initial-tl-roll -= 2 if $!pop == 9;
		   $!initial-tl-roll -= 4 if $!pop >= 10;

	   	   $!initial-tl-roll -= 1 if $!gov == 0 || $!gov == 5;
		   $!initial-tl-roll -= 2 if $!gov == 13;
		}
	}

	method parseBases( $bases ) {
		$!scout-base = '';
		$!navy-base  = '';

		$!scout-base = 'S' if $bases ~~ /S/;
		$!scout-base = 'W' if $bases ~~ /W/;
		$!navy-base  = 'N' if $bases ~~ /N/;
		$!navy-base  = 'D' if $bases ~~ /D/;
	}

	method parsePBG( $pbg ) {
		$!pop-mult = ($pbg/100).Int;
		$!belts    = (($pbg % 100)/10).Int;
		$!ggs      = $pbg % 10;
	}

    method parseNIL( $remarks ) {
		# we're looking for something like "(Shriekers)"
		$!NIL = $1 if $remarks ~~ /\(.*?\)/;
		# that's it, we're done.
	}
	
	method parseSpecialRemarks( $remarks ) {
		# we're looking for any of:ab an cp cs cx sa lk mr re 
		@!specialRemarks = ();
		my $str = &.show;

        for 'ab', 'an', 'cp', 'cs', 'cx', 'lk', 'mr', 're', 'sa' {
			push @!specialRemarks, $_ if $remarks ~~ /$_ /;
		}				
	}

	method recalc-tl {
		return if $!pop == 0;

		$!tl = $!initial-tl-roll;
		$!tl += 6 if $!starport eq 'A';
		$!tl += 4 if $!starport eq 'B';
		$!tl += 2 if $!starport eq 'C';
		$!tl += 1 if $!starport eq 'F';
		$!tl -= 4 if $!starport eq 'X';

		$!tl += 2 if $!siz <= 1;
		$!tl += 1 if 2 <= $!siz <= 4;
		$!tl += 1 if $!atm <= 3;
		$!tl += 2 if $!atm >= 10;
		$!tl += 1 if $!hyd == 9;
		$!tl += 2 if $!hyd == 10;
		$!tl += 1 if $!pop < 6;
		$!tl += 2 if $!pop == 9;
		$!tl += 4 if $!pop >= 10;
		$!tl += 1 if $!gov == 0 || $!gov == 5;
		$!tl += 2 if $!gov == 13;
	}

	method calc-extensions-and-RU {
		#
		#  First, re-calc Importance
		#
		$!ix = 0;
		$!ix = 1 if $!.starport ~~ /<[AB]>/;
		++$!ix   if $!tl >= 10;
		++$!ix   if $!tl >= 16;  # bump for TLG+
		--$!ix   if $!.starport ~~ /<[DEX]>/;
		--$!ix   if $!.tl <= 8;
		--$!ix   if $.pop <= 6;

		my $str = $.show;

		++$!ix   if $str ~~ /Ag/;
		++$!ix   if $str ~~ /Hi/;
		++$!ix   if $str ~~ /In/;
		++$!ix   if $str ~~ /Ri/;

		my $bases = &.get-bases;
		++$!ix    if $bases ~~ /(NS|W|CK)/;

		#
		#  Second, re-calculate RU
		#
		$!resources = $!base-resources;
		$!resources += $!belts + $!ggs if $!tl >= 8;

		$!labor = $!pop - 1;
		$!labor = 0 if $!pop == 0;

		$!infrastructure = $!ix;                           # pop 123
		$!infrastructure += ((^6).pick+1) if $!pop >= 4;  # pop 456 = +1D
		$!infrastructure += ((^6).pick+1) if $!pop >= 7;  # pop 7+  = +2D total
		$!infrastructure = 0 if $!pop == 0;
		$!infrastructure = 0 if $!infrastructure < 0;

		$!efficiency = (^6).pick - (^6).pick;
		$!efficiency = 1 if $!efficiency == 0;	           # convenience

		&.calc-RU;
	}

	method calc-RU {
		$!RU  = $!resources;			# R
		$!RU *= $!labor || 1;			# L
		$!RU *= $!infrastructure || 1;	# I 
		$!RU *= $!efficiency;
	}
	
	method calc-nobility {

	}

    method adjust-pop( Int $amount ) {
		$!pop += $amount;
		$!pop = 0 if $!pop < 0;
		$!pop = 15 if $!pop > 15;
	}

	method adjust-pm( Int $amount ) {
		return if $!pop == 0;

		$!pop-mult += $amount;
		if ($!pop-mult <= 0) {
			$!pop-mult += 9;
			&.adjust-pop(-1);
			&.is-dieback();
		} elsif ($!pop-mult > 9) {
			$!pop-mult -= 9;
			&.adjust-pop(1);
		}
	}

	method adjust-tl( Int $amount ) {
		return if $!pop == 0;

		$!tl += $amount;
		$!tl = 0 if $!tl < 0;
	}

    method halve-pm {
		return if $!pop == 0;

		$!pop-mult = $!pop-mult div 2;
		if ($!pop-mult == 0) 
		{
			$!pop-mult = 5;
			$!pop--;
			&.is-dieback;
		}
	}

    method reduce-starport-by-one {
		&.destroy-starport if $!starport eq 'E';
		$!starport = 'E' if $!starport eq 'D';
		$!starport = 'D' if $!starport eq 'C';
		$!starport = 'C' if $!starport eq 'B';
		$!starport = 'B' if $!starport eq 'A';
	}

	method destroy-starport {
		$!starport = 'X';
		$!scout-base = '';
		$!navy-base = '';
	}

    method randomize-transient-population {
		return if $!pop == 0;
        $!pop = (^3).pick + 1;
		$!pop-mult = (^9).pick + 1;
	}

    method reroll-gov {
		return if $!pop == 0;
		$!gov = $!pop - 7 + (^6).pick + 1 + (^6).pick + 1;
		$!gov = 0 if $!gov < 0;
	}

	method reroll-law( $dm ) {
		return if $!pop == 0;
		$!law = $!gov - 7 + (^6).pick + 1 + (^6).pick + 1 + $dm;
		$!law = 0 if $!law < 0;
	}

	method reroll-gov-and-law {
		&.reroll-gov;
		&.reroll-law(0);
	}

	method show {
		my $out = $!starport;
		$out ~= %hdh{ $!siz };
		$out ~= %hdh{ $!atm };
		$out ~= %hdh{ $!hyd };
		$out ~= %hdh{ $!pop };
		$out ~= %hdh{ $!gov };
		$out ~= %hdh{ $!law };
		$out ~= '-';
	 	$out ~= %hdh{ $!tl };
		return $out;
	}

    method show-Ix {
		return "{$!ix}";
	}

	method show-Ex {
		my $out = %hdh{ $!resources };
		$out ~= %hdh{ $!labor };
		$out ~= %hdh{ $!infrastructure };
		$out ~= '-' if $!efficiency < 0;
		$out ~= '+' if $!efficiency >= 0;
		$out ~= %hdh{ $!efficiency.abs };
		return "($out)";
	}

    method virus0-init {
		$!zone = '';
	}

    method virus1a-kill-inhospitable-worlds(-->Bool) {
		$!pop = 0 if $!atm ~~ /<[0123ABC]>/;
		return &.is-dieback;
	}

    method virus1b-cap-population {
		return if $!pop == 0;

		my $max = 10;
		$max = 8 if $!siz ~~ /<[1234]>/;
		$max = 9 if $!siz ~~ /<[567]>/;
		$max--   if $!atm ~~ /<[579]>/;
		$max-=2  if $!atm ~~ /<[4]>/;
		$max-=3  if $!atm ~~ /<[DEF]>/;
		$max--   if $!hyd ~~ /<[12A]>/;
		$max-=2  if $!hyd ~~ /<[0]>/;

		$!pop = (^10).pick if $!pop > $max;
		&.reroll-gov-and-law unless &.is-dieback;
	}

	method virus23-damage-tl {
	   return if $!pop == 0;

	   if $!tl < 9 {
	      $!tl-reduction = ((^6).pick - 2);	# 1D-3
		  $!tl-reduction = 0 if $!tl-reduction < 0;
	   } elsif $!tl < 11 {
          $!tl-reduction = ((^6).pick + 1);	# 1D
	   } elsif $!tl < 14 {
	      $!tl-reduction = ((^6).pick + 1) + ((^6).pick + 1); # 2D
	   } else {
	      $!tl-reduction = ((^6).pick + 1) + ((^6).pick + 1) + ((^6).pick + 1); # 3D
	   }
	   &.adjust-tl(-$!tl-reduction);
	   &.adjust-pm( ceiling(-$!tl-reduction/4) );
	   return $!tl;	
	}

	method virus4-low-pop {
		return if $!pop > 5 || $!pop == 0;
		&.adjust-tl(-1);
		&.halve-pm;
	}

	method virus56-starport-and-bases {
	   if ($!pop == 0)
	   {
		  &.destroy-starport;
		  return;
	   }

       my $r = (^6).pick + 1;

	   if ($r < $!tl-reduction) {
		  &.destroy-starport;
		  return;
	   }
	   
	   if $r <= $!tl-reduction {
		  &.reduce-starport-by-one;
   
          my $d10 = (^10).pick + 1;

          $!navy-base  = '' if $!navy-base eq 'D' && $d10 < 10;
		  $!navy-base  = '' if $!navy-base eq 'N' && $d10 < 9;

          $!scout-base = '' if $!scout-base eq 'W' && $d10 < 10;
		  $!scout-base = '' if $!scout-base eq 'S' && $d10 < 8;

		  return;
	   }

       #
	   # $r == $!tl-reduction.  Hit it twice and kill the bases.
       #
       &.reduce-starport-by-one;
       &.reduce-starport-by-one;
	   $!scout-base = '';
	   $!navy-base  = '';
	}

	method virus78-balkanized-ted {
		return if $!pop == 0;

		my $balkanization-number = $!siz + $!pop - $!tl;
		my $roll = (^6).pick + 1 + (^6).pick + 1;
		if $roll <= $balkanization-number {
			$!zone = 'B'; # balkanized
		}

		if ($!pop >= 5) && ((^10).pick + 1) < $!tl-reduction {
		   $!gov = 6; # TED
		   &.reroll-law(4);
		} else {
		   &.reroll-gov-and-law;
		}
	}

	method virus9-recovery {
		return if $!pop == 0;

		#
		#  PUNT until we fully accept the consequences of TNE's 
		#  aggressive recovery rates.
		#
		&.randomize-transient-population if 1 <= $!pop <= 3;
		&.adjust-pm(1) if $!pop >= 4;
	}

    method wave0-init {
		$!zone = '';
	}

	method wave1-check-ni {
		return unless 4 <= $!pop <= 6;

		my $bad-flux = (^6).pick - (^6).pick;
		&.adjust-pop( $bad-flux ) if $bad-flux < 0;
	}

	method wave2-check-lo {
		return unless $!pop < 4;
		$!pop = 0;
		&.is-dieback;
	}

	method wave3-check-he {
		return unless (3 <= $!siz <= 12) 
		           && ($!atm == 2 | 4 | 7 | 9 | 10 | 11 | 12) 
				   && (1 <= $!hyd <= 10);

		my $bad-flux = (^6).pick - (^6).pick;
		&.adjust-pop( $bad-flux ) if $bad-flux < 0;
		$!pop = 0 if $!pop <= 6;
		&.is-dieback;
	}

	method wave4-do-one-recovery-epoch {
		&.adjust-pm( &.minflux() );
		&.adjust-tl( &.minflux() );
		&.reroll-gov-and-law;
	}		

	method do-virus-except-recovery {
	   &.virus0-init;
	   if ! &.virus1a-kill-inhospitable-worlds {
		   &.virus1b-cap-population;
	   }
	   &.virus23-damage-tl;
	   &.virus4-low-pop;
	   &.virus56-starport-and-bases;
	   &.virus78-balkanized-ted;
	}

	method do-wave-except-recovery {
		&.wave0-init;
		&.wave1-check-ni;
		&.wave2-check-lo;
		&.wave3-check-he;
		
		if ! &.is-dieback {
			&.halve-pm;
			my $tlReduction = 2;
			&.adjust-tl( -$tlReduction );
		}
	}
}

use lib '.';
#use GTX;

grammar GTXGrammar {
	token  TOP		{ <context>+ }
	rule   context	{ <word> \{ <pair>+ \} }
	rule   pair		{ <key=.word> <value=.word> }
	token  word		{ \w+ }
}

class GTXActions {
	method TOP     ($/)	{ make $<context>>>.made.hash 	    }
	method context ($/)	{ make $<word>.made => $<pair>>>.made.hash  }
	method pair    ($/)	{ make $<key>.made => $<value>.made   }
	method word	   ($/) { make ~$/ }
}

my $test1 =q:to/END1/;
location { 	
	X 	-1 	
	Y	-1 
}
END1

my $test2 =q:to/END2/;
virus {
	preserveAllegiances		ImDd Rr Wild HuNa VaNr
	killHexes				1910 1911 1910 0101 0109
}
END2

my $match = GTXGrammar.parse( 'Foo { bar baz }  Mumble { ack grault }', actions => GTXActions );
#my $match = GTXGrammar.parse( $test1, actions => GTXActions );

#say $match;
#say $match.made;
my %h = $match.made;
say %h;

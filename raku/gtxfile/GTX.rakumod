=begin pod

=head1 GTX 

C<GTX> is a simplistic config file format. It supports a hash of strings and hashes.

=head1 Synopsis

	use GTX;
	my $gtx = from-gtx($myGtxText);

=end pod

unit module GTX;

use GTX::Actions;
use GTX::Grammar;

class X::GTX::Invalid is Exception {
    has $.source;
    method message { "Input ($.source.chars() characters) is not a valid string" }
}

###########################################################
#
#  Deserialize
#
###########################################################
sub from-gtx($text) is export {
	my $out = GTX::Grammar.parse($text, :actions(GTX::Actions.new));
	unless $out {
		X::GTX::Invalid.new(source => $text).throw;
	}
	return $out.made;
}

###########################################################
#
#  Serialize
#
###########################################################
proto to-gtx($) is export {*}

multi to-gtx(Real:D  $d) { $d.Str }
multi to-gtx(Str:D  $d)  { $d }

multi to-gtx(Positional:D $d) {
    return  '[ '
            ~ $d.flatmap(&to-gtx).join(', ')
            ~ ' ]';
}

multi to-gtx(Associative:D  $d) {
    return '{ '
            ~ $d.flatmap({ to-gtx(.key) ~ ': ' ~ to-gtx(.value) }).join(', ')
            ~ ' }';
}

multi to-gtx(Mu:U $) { 'null' }

multi to-gtx(Mu:D $s) {
    die "Can't serialize an object of type " ~ $s.WHAT.perl
}

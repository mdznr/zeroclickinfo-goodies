package DDG::Goodie::ColorConverter;
# ABSTRACT: Convert colors to different types.

use DDG::Goodie;

use strict;
use warnings;
use feature qw/switch/;
use List::Util qw[min max];
use Math::Round;

triggers start => 'convert';

zci is_cached => 1;

primary_example_queries 'convert #ff0000 to rgb';
secondary_example_queries 'convert #00ff00 to UIColor';
description 'Convert colors in hex to rgb, hsl or to UIColor';
name 'ColorConverter';
code_url 'https://github.com/mdznr/zeroclickinfo-goodies';
category 'computing_tools';
topics 'programming';

handle remainder => sub
{
	my @arguments = split ' ', $_[0];
	
	my $numArgs = @arguments;
	
	# Excpected arguments: #XXXXXX to {rgb, hsl, uicolor}
	if ( $numArgs != 3 ) {
		return;
	}	
	
	my $fromColor = lc shift @arguments;
	
	my $to = lc shift @arguments;
	if ( !($to eq "to") && !($to eq "in") && !($to eq "as") ) {
		return;
	}
	
	my $toColorType = lc shift @arguments;
	
	#warning: determine from color type
	
	# this assumes input as hex
	given ( $toColorType ) {
		when ("rgb") { return convertHEXToRGB($fromColor); }
		when ("hsl") { return convertHEXToHSL($fromColor); }
		when ("uicolor") { return convertHEXToUIColor($fromColor); }
		default { return; }
	}
	
	return;
};

1;

# Conversion subroutines:

sub convertHEXToRGB
{
	my $fromColor = shift;
	my $r = hex substr($fromColor,1,2);
	my $g = hex substr($fromColor,3,2);
	my $b = hex substr($fromColor,5,2);
	return "rgb($r, $g, $b)";
}

sub convertHEXToHSL
{
	# Algorithm modified from
	# http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
	my $fromColor = shift;
	my $r = hex substr($fromColor,1,2);
	my $g = hex substr($fromColor,3,2);
	my $b = hex substr($fromColor,5,2);

	$r /= 255;
	$g /= 255;
	$b /= 255;

	my $max = max($r, $g, $b);
	my $min = min($r, $g, $b);
	my $h, my $s, my $l = ($max + $min) / 2;

	if ( $max == $min ) {
		$h = $s = 0; # achromatic
	} else {
		my $d = $max - $min;
		$s = $l > 0.5 ? $d / (2 - $max - $min) : $d / ($max + $min);
		given ( $max ) {
			when ($r) { $h = ($g - $b) / $d + ($g < $b ? 6 : 0); }
			when ($g) { $h = ($b - $r) / $d + 2; }
			when ($b) { $h = ($r - $g) / $d + 4; }
		}
		$h /= 6;
	}

	$h = round($h * 360);
	$s = round($s * 100);
	$l = round($l * 100);

	return "hsl($h, $s%, $l%)";
}

sub convertHEXToUIColor
{
	my $fromColor = shift;

	# Special cases
	# Assumes #fromColor is given HEX (with #) in lowercase
	given ( $fromColor ) {
		when ( "#000000" ) { return "[UIColor blackColor]"; }
		when ( "#555555" ) { return "[UIColor darkGrayColor]"; }
		when ( "#aaaaaa" ) { return "[UIColor lightGrayColor]"; }
		when ( "#808080" ) { return "[UIColor grayColor]"; }
		when ( "#ffffff" ) { return "[UIColor whiteColor]"; }
		when ( "#0000ff" ) { return "[UIColor blueColor]"; }
		when ( "#00ff00" ) { return "[UIColor greenColor]"; }
		when ( "#00ffff" ) { return "[UIColor cyanColor]"; }
		when ( "#ff0000" ) { return "[UIColor redColor]"; }
		when ( "#ff00ff" ) { return "[UIColor magentaColor]"; }
		when ( "#ffff00" ) { return "[UIColor yellowColor]"; }
		when ( "#ff8000" ) { return "[UIColor orangeColor]"; }
		when ( "#800080" ) { return "[UIColor purpleColor]"; }
		when ( "#996633" ) { return "[UIColor brownColor]"; }
	}

	my $r = hex substr($fromColor,1,2);
	my $g = hex substr($fromColor,3,2);
	my $b = hex substr($fromColor,5,2);

	if ( $r == $g && $g == $b ) {
		# greyscale colors (all rgb values are equal)
		return "[UIColor colorWithWhite:$r/255.0f alpha:1.0f]";
	}

	return "[UIColor colorWithRed:$r/255.0f green:$g/255.0f blue:$b/255.0f alpha:1.0f]";
}


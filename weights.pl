#!/usr/bin/perl
#weights.pl

use strict;
use warnings;

my @weights = (0, 0, 0, 0, 0);
my $position = 0;
my $range = 100;

my $workingdir = $ARGV[0];
my $season = $ARGV[2];

my @values;
my $current = 100;
while ($current >= 0){
	push @values,$current;
	$current = $current - 5;
}

output_weights(\@weights,$position,\@values);

#argument 1 = array of weights
#argument 2 = current position
#argument 3 = array with range of values
#e.g. output_weights(array,0,100)
sub output_weights{
	#read arguments
	my @input = @{$_[0]};
	my $position = $_[1];
	my @range = @{$_[2]};

	#my $depth = scalar @input;
	my $depth = 5;

	if ($position != $depth) {
		$position = $position + 1;
		foreach my $val (@range){
			$input[$position-1] = $val;
			output_weights(\@input,$position,\@range);
		}		
	} else {
		my $total = 0;
		foreach my $i (@input) {
			$total = $total + $i;
		}
		#output array to file if sum = 100
		if ($total == 100){
			my $filename = $workingdir . $season . '/weights2.dat';
			open(my $fh, ">>", $filename) or die "Could not open file '$filename' $!";
			for (@input) {
				print $fh $_ . ",";
				}
			print $fh "\n";
			close $fh;
		}
	}

}

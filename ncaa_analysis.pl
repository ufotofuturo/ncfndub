#!/usr/bin/perl
#ncaa_analysis.pl
#perl ncaa.pl "/Users/location/ncfndub/" 1617 

my $workingdir = $ARGV[0];
my $season = $ARGV[1];
my $analysis_depth = $ARGV[2];


my $filename = $workingdir . $season . "/predictions.txt";
open handle, $filename or die $1;

my $current_line = 1;

my @temp;
my $highest = 0;
my $overallavg = 0;
my $outputfilename = $workingdir . $season . '/analysis_compressed.txt';

open(my $fh, ">>", $outputfilename) or die "Could not open file '$filename' $!";

while (<handle>){
	if ($current_line < $analysis_depth){
		@temp = split /:/, $_;
		if (int($temp[6]) == 100) {
			print $fh $current_line;
			print $fh "100" . "\n";
		}
	} else {
		die;
	}

	$current_line = $current_line + 1;
}


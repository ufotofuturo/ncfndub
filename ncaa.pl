#!/usr/bin/perl
#ncaa.pl

use strict;
#use warnings;

my $total = 0;
foreach (@ARGV){
	print "Element: |$_|\n";
}

#open schedule- this is a file containing the first 32 matchups
#in a format like this:
#1:Villanova:Mt St Marys
#2:Wisconsin:VA Tech
#3:Virginia:NC-Wilmgton
# ...etc....
open FH, '/Users/dabritson/ncfndub/1617/schedule.dat' or die $!;
my @bracket;

#read the schedule into an array
my @temp;
while (<FH>){
	@temp = split /:/, $_;
	push @bracket, $temp[1];
	push @bracket, $temp[2];
}
close FH;

#assign ratings for each team
my %ratings = create_ratings();

#leave commented unless you want to see all assigned ratings
#my @allteams = keys %ratings;
#for my $allteam (@allteams) {
#	print $allteam . ":" . $ratings{$allteam} . "\n";
#
#}

#go through the bracket and simulate each game
my @roundof32;
my @sweet16;
my @elite8;
my @final4;
my @championship;
my @winner;

my @roundof32 = play_round(\@bracket,\%ratings);
my @sweet16 = play_round(\@roundof32,\%ratings);
my @elite8 = play_round(\@sweet16,\%ratings);
my @final4 = play_round(\@elite8,\%ratings);
my @championship = play_round(\@final4,\%ratings);
my @winner = play_round(\@championship,\%ratings);

#return the result of a round
#this will work when 'ratings' is a hash of team names / ratings
#and 'teams' is an array of team names with an even number of results
#play_round(teams,ratings)
sub play_round {
	# body...	my @input = @{$_[0]};
	my @teams= @{$_[0]};
	my %ratings = %{$_[1]};
	my $numberofgames = scalar @teams;
	my @result;
	my $nextround = 0;
	my $team1;
	my $team2;

	while ($nextround < $numberofgames){
		$team1 = @teams[$nextround];
		$team2 = @teams[$nextround+1];
		print "Game: " . $team1 . " vs. " . $team2 . " ";
		print "Winner: " ;
		if ($ratings{$team1} < $ratings{$team2}){
			print $team1 . "\n";
			push @result, $team1;
		} else {
			print $team2 . "\n";
			push @result, $team2;
		}
		$nextround = $nextround + 2;
	}
	return @result;
}

#create an overall ranking of every team from the provided file using the provided weights
sub create_ratings{
	open teams, '/Users/dabritson/ncfndub/1617/teams.dat' or die $!;
	my @teamlist;
	my %ratings;
	my $increment = 1;
	#read the teams into an array
	while (<teams>){
		push @teamlist,$_;
	}
	close teams;
	#build five hashes with the rankings for each team
	my %rpi;
	my %defense;
	my %offense;
	my %floor;
	my %margin;
	stat_reader(\@teamlist);
	#assign rankings and store them into a hash
	foreach my $team (@teamlist){
		$ratings{$team} = $increment;
		$increment++;
	}
	return %ratings;
}

#read stats and return a hash with team names / rankings
sub stat_reader {
	my @teams= @{$_[0]};
	my %result;

	%result = grab_rankings(\%result,'/Users/dabritson/ncfndub/1617/rpi.dat');
	%result = grab_rankings(\%result,'/Users/dabritson/ncfndub/1617/defensiveefficiency.dat');
	%result = grab_rankings(\%result,'/Users/dabritson/ncfndub/1617/offensiveefficiency.dat');
	%result = grab_rankings(\%result,'/Users/dabritson/ncfndub/1617/floorpercentage.dat');
	%result = grab_rankings(\%result,'/Users/dabritson/ncfndub/1617/scoringmargins.dat');

	#uncomment to view resulting hash values
	#my @iter = keys %result;
	#foreach my $team (@iter){
	#	print "TEAM NAME: " . $team . " Hash Value: " . $result{$team} . "\n"; 
	#}

	die;
}

sub grab_rankings {
	my %result= %{$_[0]};
	my $file = $_[1];

	open handle, $file or die $!;
	my @temp;
	while (<handle>){
		@temp = split /,/, $_;	
		$result{$temp[1]} = $result{$temp[1]} . $temp[0] . ":";
	}
	close handle;
	return %result;
}

#assess the output of a game given the teams, ratings, and weights

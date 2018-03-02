#!/usr/bin/perl
#ncaa.pl

use strict;
#use warnings;

my $workingdir = $ARGV[0];
my $season = $ARGV[1];

#open schedule- this is a file containing the first 32 matchups
#in a format like this:
#1:Villanova:Mt St Marys
#2:Wisconsin:VA Tech
#3:Virginia:NC-Wilmgton
# ...etc....
my $schedulelocation = $workingdir . $season . "/schedule.dat";
open FH, $schedulelocation or die $!;
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
my $weights = "100,0,0,0,0,";

my @roundof32;
my @sweet16;
my @elite8;
my @final4;
my @championship;
my @winner;

my @roundof32 = play_round(\@bracket,\%ratings,$weights);
my @sweet16 = play_round(\@roundof32,\%ratings,$weights);
my @elite8 = play_round(\@sweet16,\%ratings,$weights);
my @final4 = play_round(\@elite8,\%ratings,$weights);
my @championship = play_round(\@final4,\%ratings,$weights);
my @winner = play_round(\@championship,\%ratings,$weights);

#return the result of a round
#this will work when 'ratings' is a hash of team names / ratings
#and 'teams' is an array of team names with an even number of results
#play_round(teams,ratings)
sub play_round {
	# body...	my @input = @{$_[0]};
	my @teams= @{$_[0]};
	my %ratings = %{$_[1]};
	my $weights = $_[2];
	my $numberofgames = scalar @teams;
	my @result;
	my $nextround = 0;
	my $team1;
	my $team2;
	my $winner;

	while ($nextround < $numberofgames){
		$team1 = @teams[$nextround];
		$team2 = @teams[$nextround+1];
		my $winner = play_game($team1,$team2,\%ratings,$weights);

		die;

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

#create an overall ranking of every team from the provided file
sub create_ratings{
	my $teamfilelocation = $workingdir . $season . "/teams.dat";
	open teams, $teamfilelocation or die $!;
	my @teamlist;
	my %ratings;
	my $increment = 1;
	#read the teams into an array
	while (<teams>){
		push @teamlist,$_;
	}
	close teams;
	#build five hashes with the rankings for each team
	my %ratings = stat_reader(\@teamlist);

	return %ratings;
}

#read stats and return a hash with team names / rankings
sub stat_reader {
	my @teams= @{$_[0]};
	my %result;

	%result = grab_rankings(\%result,$workingdir . $season . '/rpi.dat');
	%result = grab_rankings(\%result,$workingdir . $season . '/defensiveefficiency.dat');
	%result = grab_rankings(\%result,$workingdir . $season . '/offensiveefficiency.dat');
	%result = grab_rankings(\%result,$workingdir . $season . '/floorpercentage.dat');
	%result = grab_rankings(\%result,$workingdir . $season . '/scoringmargins.dat');

	#uncomment to view resulting hash values
	#my @iter = keys %result;
	#foreach my $team (@iter){
	#	print "TEAM NAME: " . $team . " Hash Value: " . $result{$team} . "\n"; 
	#}

	return %result;
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
#play_game(Arizona,Tennesee,\%ratings,$weights)
sub play_game {
	my $team1 = $_[0];
	my $team2 = $_[1];
	my %ratings = %{$_[2]};
	my $weights = $_[3];
	my $team1strength;
	my $team2strength;
	my $totalteams = scalar(keys %ratings);

	print "Game: " . $team1 . " vs. " . $team2 . "\n";
	print $team1 . " Ratings: " . $ratings{$team1} . "\n";
	print $team2 . " Ratings: " . $ratings{$team2} . "\n";
	print "Weights: " . $weights . "\n";

	my @team1adjusted;
	my @team2adjusted;




	print "Winner: " . $team1;
	return $team1;
}
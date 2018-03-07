#!/usr/bin/perl
#ncaa.pl
#example run : 
# perl ncaa.pl "/Users/location/ncfndub/" 1617 1
use strict;
#use warnings;

my $workingdir = $ARGV[0];
my $season = $ARGV[1];

#defines location in the weights file to start doing sims
#will help if sim is interrupted.
my $startingline = $ARGV[2];

#fuzz multiplier defines how many times to run each weight
#fuzz factor is a range within which the results of the game will use dice rolls

my $fuzzfactor = .03;
my $fuzzmultiplier = 2;

my $debug = 0;

#read the season's actual outcome into an array
my @actual_outcome = actual_outcome();
#debug - show full outcome
if ($debug == 1){
	my $gamenumber = 1;
	foreach my $game (@actual_outcome){
		print "Game " . $gamenumber . " winner: " . $game . "\n";
		$gamenumber = $gamenumber + 1;
	}
} 

#split the season's actual outcome into discrete arrays
my @roundof32_actual;
my @sweet16_actual;
my @elite8_actual;
my @final4_actual;
my @championship_actual;
my @winner_actual;

my $currentgame = 0;
while ($currentgame < 32){
	chomp($actual_outcome[$currentgame]);
	push @roundof32_actual, $actual_outcome[$currentgame];
	$currentgame = $currentgame+1;
}
while ($currentgame < 48){
	chomp($actual_outcome[$currentgame]);
	push @sweet16_actual, $actual_outcome[$currentgame];
	$currentgame = $currentgame+1;
}
while ($currentgame < 56){
	chomp($actual_outcome[$currentgame]);
	push @elite8_actual, $actual_outcome[$currentgame];
	$currentgame = $currentgame+1;
}
while ($currentgame < 60){
	chomp($actual_outcome[$currentgame]);
	push @final4_actual, $actual_outcome[$currentgame];
	$currentgame = $currentgame+1;
}
while ($currentgame < 62){
	chomp($actual_outcome[$currentgame]);
	push @championship_actual, $actual_outcome[$currentgame];
	$currentgame = $currentgame+1;
}
while ($currentgame < 63){
	chomp($actual_outcome[$currentgame]);
	push @winner_actual, $actual_outcome[$currentgame];
	$currentgame = $currentgame+1;
}

if ($debug == 1) {
	my $val;
	print "Round of 32: " , "\n";
	foreach $val (@roundof32_actual){
		print $val;
	}
	print "Sweet 16: " , "\n";
	foreach $val (@sweet16_actual){
		print $val;
	}
	print "Elite 8: " , "\n";
	foreach $val (@elite8_actual){
		print $val;
	}
	print "Final 4: " , "\n";
	foreach $val (@final4_actual){
		print $val;
	}
	print "Championship Game: " , "\n";
	foreach $val (@championship_actual){
		print $val;
	}
	print "Winner: " , "\n";
	foreach $val (@winner_actual){
		print $val;
	}
}

#open schedule- this is a file containing the first 32 matchups
#in a format like this:
#1:Villanova:Mt St Marys:
#2:Wisconsin:VA Tech:
#3:Virginia:NC-Wilmgton:
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

if ($debug == 1) {
	my @allteams = keys %ratings;
	for my $allteam (@allteams) {
		print $allteam . ":" . $ratings{$allteam} . "\n";
	}
}


#go through the bracket and simulate each game
#my @allsims;
#push @allsims, "20,20,20,20,20,";
#push @allsims, "100,0,0,0,0,";
#push @allsims, "0,0,100,0,0,";

my $progress = 1;
my $looper;
my $weightfile = $workingdir . $season . "/weights.dat";
open FILE, $weightfile or die $!;

while(<FILE>) {
	$looper = 0;
	if ($progress >= $startingline) {
		while ($looper < $fuzzmultiplier){
			my @roundof32;
			my @sweet16;
			my @elite8;
			my @final4;
			my @championship;
			my @winner;
			chomp $_;
			my $weights = $_;
			#debug - output bracketed weighted team ratings here
			my %bracket_ratings = tourney_weights($weights,\%ratings,\@bracket);

			my @roundof32 = play_round(\@bracket,\%bracket_ratings,$fuzzfactor);
			my @sweet16 = play_round(\@roundof32,\%bracket_ratings,$fuzzfactor);
			my @elite8 = play_round(\@sweet16,\%bracket_ratings,$fuzzfactor);
			my @final4 = play_round(\@elite8,\%bracket_ratings,$fuzzfactor);
			my @championship = play_round(\@final4,\%bracket_ratings,$fuzzfactor);
			my @winner = play_round(\@championship,\%bracket_ratings,$fuzzfactor);

			#compare this prediction to the actual result
			my $overallaccuracy = 0;
			my $roundof32accuracy = 0;
			my $sweet16accuracy = 0;
			my $elite8accuracy = 0;
			my $final4accuracy = 0;
			my $championshipaccuracy = 0;
			my $winneraccuracy = 0;


			my $comparing = 0;
			my $val;

			foreach $val (@roundof32){
				if ($val eq $roundof32_actual[$comparing]) {
					$overallaccuracy = $overallaccuracy + 1;
					$roundof32accuracy = $roundof32accuracy + 1;
				}
				$comparing = $comparing + 1;
			}
			$roundof32accuracy = ((int($roundof32accuracy) / 32)*100);

			$comparing = 0;
			foreach $val (@sweet16){
				if ($val eq $sweet16_actual[$comparing]) {
					$overallaccuracy = $overallaccuracy + 1;
					$sweet16accuracy = $sweet16accuracy + 1;
				}
				$comparing = $comparing + 1;
			}
			$sweet16accuracy = ((int($sweet16accuracy) / 16)*100);

			$comparing = 0;
			foreach $val (@elite8){
				if ($val eq $elite8_actual[$comparing]) {
					$overallaccuracy = $overallaccuracy + 1;
					$elite8accuracy = $elite8accuracy + 1;
				}
				$comparing = $comparing + 1;
			}
			$elite8accuracy = ((int($elite8accuracy) / 8)*100);

			$comparing = 0;
			foreach $val (@final4){
				if ($val eq $final4_actual[$comparing]) {
					$overallaccuracy = $overallaccuracy + 1;
					$final4accuracy = $final4accuracy + 1;
				}
				$comparing = $comparing + 1;
			}
			$final4accuracy = ((int($final4accuracy) / 4)*100);

			$comparing = 0;
			foreach $val (@championship){
				if ($val eq $championship_actual[$comparing]) {
					$overallaccuracy = $overallaccuracy + 1;
					$championshipaccuracy = $championshipaccuracy + 1;
				}
				$comparing = $comparing + 1;
			}
			$championshipaccuracy = ((int($championshipaccuracy) / 2)*100);


			$comparing = 0;
			foreach $val (@winner){
				if ($val eq $winner_actual[$comparing]) {
					$overallaccuracy = $overallaccuracy + 1;
					$winneraccuracy = $winneraccuracy + 1;
				}
				$comparing = $comparing + 1;
			}
			$winneraccuracy = ((int($winneraccuracy) / 1)*100);


			#print "Overall Accuracy: " . $overallaccuracy . "%\n";
			#print "Winner Accuracy: " . $winneraccuracy . "%\n";
			#print "Championship Accuracy: " . $championshipaccuracy . "%\n";
			#print "Final 4 Accuracy: " . $final4accuracy . "%\n";
			#print "Elite 8 Accuracy: " . $elite8accuracy . "%\n";
			#print "Sweet 16 Accuracy: " . $sweet16accuracy . "%\n";
			#print "Round of 32 Accuracy: " . $roundof32accuracy . "%\n";

			my $outputfilelocation = $workingdir . $season . '/predictions.txt';
			open (my $outhandle, '>>', $outputfilelocation) or die "Could not open file '$$outputfilelocation' $!";
			print $outhandle $weights . ":" . $roundof32accuracy . ":" . $sweet16accuracy . ":" . $elite8accuracy . ":" . $final4accuracy . ":" . $championshipaccuracy . ":" . $winneraccuracy . ":" . $overallaccuracy . "\n"; 
			close $outhandle;
			$looper = $looper + 1;
		}
	} else {
		$progress = $progress + 1;
	}
}

#return the result of a round
#this will work when 'ratings' is a hash of team names / ratings
#and 'teams' is an array of team names with an even number of results
#play_round(teams,ratings,fuzz)
sub play_round {
	# body...	my @input = @{$_[0]};
	my @teams = @{$_[0]};
	my %ratings = %{$_[1]};
	my $fuzz = $_[2];
	my $numberofgames = scalar @teams;
	my @result;
	my $nextround = 0;
	my $team1;
	my $team2;
	my $winner;

	while ($nextround < $numberofgames){
		$team1 = @teams[$nextround];
		$team2 = @teams[$nextround+1];
		my $winner = play_game($team1,$team2,\%ratings,$fuzz);
		push @result, $winner;
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

	#there should be as many files here as there are weights per line in weights.dat
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
	my $fuzz = $_[3];

	#print $team1 . " versus " . $team2 . "\n";
	#print $team1 . " rating : " . $ratings{$team1} . "\n";
	#print $team2 . " rating : " . $ratings{$team2} . "\n";

	#account for fuzziness here
	#if absolute value of difference between team ratings
	#is lower than the fuzz factor, just roll a dice instead of 
	#checking ratings

	if (abs($ratings{$team1} - $ratings{$team2}) < $fuzz){
		if ($ratings{$team1} > $ratings{$team2}){
			#print "Winner: " . $team1 . "\n";
			return $team1;
		} else {
			#print "Winner: " . $team2 . "\n";
			return $team2;
		}
	} else {
		if ($ratings{$team1} > $ratings{$team2}){
			#print "Winner: " . $team1 . "\n";
			return $team1;
		} else {
			#print "Winner: " . $team2 . "\n";
			return $team2;
		}
	}


	
}

#returns a hash of the weighted team ratings for the tournament being played
#tourney_weights (@weights,%ratings,@teams)
sub tourney_weights {
	my $weights = $_[0];
	my %ratings = %{$_[1]};
	my @teams = @{$_[2]};

	my $teamstrength;
	my $totalteams = scalar(keys %ratings);
	my @teamrankadjusted;
	my $currentweight;
	my $rank;
	my %results;
	my @rawteam;
	my @weightsarray = split /,/, $weights;


	foreach my $team (@teams){
		$currentweight = 0;
		$teamstrength = 0;
		@teamrankadjusted = ();
		#print "Team: " . $team . ":";
		@rawteam = split /:/, $ratings{$team};

		foreach my $column (@weightsarray){
			#pull team's rank for current stat compared to rest of field
			$rank = $rawteam[$currentweight];

			#adjust this rank to a percentage - 1st place = 100%
			$rank = (($totalteams + 1) - $rank)/$totalteams;

			#make adjustments with weight to find adjusted percent strength of each metric
			push @teamrankadjusted, ($rank * (@weightsarray[$currentweight] / 100));

			$currentweight = $currentweight + 1;
		}
		#combine percentage strengths to find final strength for each time
		foreach my $finalval1 (@teamrankadjusted){
			$teamstrength = $teamstrength + $finalval1;
		}
		#print $teamstrength . "\n";
		$results{$team} = $teamstrength;
	}
	return %results;

}

#reads the season's actual outcome to an array
sub actual_outcome {
	my $outcomelocation = $workingdir . $season . "/result.dat";
	open FH, $outcomelocation or die $!;

	#read the outcome into an array
	my @outcome;
	while (<FH>){
		@temp = split /:/, $_;
		push @outcome, $temp[3];
	}
	close FH;
	return @outcome;
}
use warnings;
use strict;

use Time::Local;

package LogBot;
use base qw ( Bot::BasicBot );

my $logging = 1; #bool to toggle logging
#log by default

sub said {
	my ($self, $message) = @_;
	my $filename = "log" . $message->{channel} . ".txt";
	if($logging){
		open(LOGFILE, '>>' . $filename);
		if($message->{address} =~ m/\S+/ && $message->{address} !~ m/msg/){
			print LOGFILE "<$message->{who}>$message->{address}: $message->{body} \n";
		}
		else{ print LOGFILE "<$message->{who}>$message->{body} \n"};
		close (LOGFILE);
	}
	if(lc($message->{body}) =~ m/.*stop *logging.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){ #make sure it is to loggerbot 
			#call is_channel_operator on underlying IRC state object
			#only ops can shut down loggerbot
			$logging = 0;
			return "powering down sensors";
		}
		return "only channel operators can do this";
	}
	if(lc($message->{body}) =~ m/.*start *logging.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){ 
			$logging = 1;
			return "powering up sensors";
		}
		return "only channel operators can do this";
	}
	if(lc($message->{body}) =~ m/.*shut *down.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){
			$self->shutdown($self->quit_message());
		}
		return "only channel operators can do this";
	}
	if(lc($message->{body}) =~ m/are you logging.*/ && $message->{address}){
		if($logging){ return "I am logging chat."; }
		else{ return "I am not logging chat."; }
	}
	return undef; #if nothing else happens, don't speak
}

sub help(){
	return "This bot logs chat. To send the bot commands, address it with loggerbot: command. To start logging, use command
	\"start logging\". To stop logging, use command \"stop logging\". To shut down the bot, use the command \"shut down\".
	Only channel operators can start, stop, or shut down the bot. To check if the bot is logging, use \"are you logging\".";
}

LogBot->new(

    server => "irc.foonetic.net",
    port   => "6697",
    ssl => 1,
    channels => ["#sudoers"],

    nick      => "loggerbot",
    username => "loggerbot",
    quit_message => "shutting down"


  )->run();
use warnings;
use strict;

use Crypt::CBC;
use File::Slurp;
use File::Path qw(make_path remove_tree);
use POSIX qw(strftime);

package LogBot;
use base qw ( Bot::BasicBot );

my $config = {
	cryptokey => "a" x 32,
	nickpass => "password",
	nick => "loggerbot",
	server => 'irc.foonetic.net',
	port => 6697,
	ssl => 1,
	username => "loggerbot",
	quit_message => "shutting down",
	channels => "#test #anothertest"
};

my $state = {
	logging => 1,
	encrypting => 0
};

#open and read config file
open(my $configfile, '<', "logbot.properties") or die "Can't open config file: $!";
while (my $line = readline($configfile)) {
	#$line =~ s/#.*//; #ignore comments
	#I have realized that since channels have a # in them that this is a bad idea.
	chomp($line); #remove newline
	if($line =~ /cryptokey=.*/){
		$line =~ s/cryptokey=//;
		$config->{cryptokey} = $line;
	}
	if($line =~ /nickpass=.*/){
		$line =~ s/nickpass=//;
		$config->{nickpass} = $line;
	}
	if($line =~ /nick=.*/){
		$line =~ s/nick=//;
		$config->{nick} = $line;
	}
	if($line =~ /server=.*/){
		$line =~ s/server=//;
		$config->{server} = $line;
	}
	if($line =~ /port=.*/){
		$line =~ s/port=//;
		$config->{port} = $line;
	}
	if($line =~ /ssl=.*/){
		$line =~ s/ssl=//;
		$config->{ssl} = $line;
	}
	if($line =~ /username=.*/){
		$line =~ s/username=//;
		$config->{username} = $line;
	}
	if($line =~ /quit_message=.*/){
		$line =~ s/quit_message=//;
		$config->{quit_message} = $line;
	}
	if($line =~ /channels=.*/){
		$line =~ s/channels=//;
		$config->{channels} = $line;
	}
}
close($configfile);

open(my $statefile, '<', 'logbotstate.properties') or warn "Can't open state file: $!";
while(my $line = readline($statefile)){
	chomp($line);
	if($line =~ /logging=.*/){
		$line =~ s/logging=//;
		$state->{logging} = $line;
	}
	if($line =~ /encrypting=.*/){
		$line =~ s/encrypting=//;
		$state->{encrypting} = $line;
	}
}
close($statefile);

my $cipher = Crypt::CBC->new( -key    => $config->{cryptokey},
                             -cipher => 'Crypt::OpenSSL::AES'
                            );
my $logging = 1; #bool to toggle logging
#log by default

if(! -d "logs") { mkdir "logs" };

chdir "logs";

sub savestate{
	chdir "..";
	open(STATEFILE, '>', 'logbotstate.properties');
	print STATEFILE "logging=", $state->{logging}, "\n";
	print STATEFILE "encrypting=", $state->{encrypting};
	chdir "logs";
	#no trailing newline so parser doesn't mess up
}

sub encryptlogs{
	my $self = shift;
	my @files = <*>;
	foreach my $file (@files) {
		if($file =~ /log.+\.txt/){
			my $contents = File::Slurp::read_file($file, binmode => ':utf8');
			$file =~ s/\.txt/\.crypt/;
			open(CRYPTLOG, '>>' . $file);
			print CRYPTLOG $cipher->encrypt($contents);	
			close(CRYPTLOG);
		}
	}
}
sub decryptlogs{
	my $self = shift;
	my @files = <*>;
	foreach my $file (@files) {
		if($file =~ /log.+\.crypt/){
			my $contents = File::Slurp::read_file($file, binmode => ':raw');
			$file =~ s/\.crypt/_decrypted\.txt/;
			open(DECRYPTLOG, '>>' . $file);
			print DECRYPTLOG $cipher->decrypt($contents);
			close(DECRYPTLOG);
		}
	}
}

sub wipelogs {
	my $self = shift;
	chdir "..";
	File::Path::remove_tree("logs");
	mkdir "logs";
	chdir "logs";
}

sub said {
	my ($self, $message) = @_;
	my $filename = "log" . $message->{channel} . ".txt";
	if($state->{logging}){
		open(LOGFILE, '>>' . $filename);
		my $timestamp = localtime();
		if($message->{address} =~ m/\S+/ && $message->{address} !~ m/msg/){
			print LOGFILE "<$message->{who} $timestamp>$message->{address}: $message->{body} \n";
		}
		else{ print LOGFILE "<$message->{who} $timestamp>$message->{body} \n"};
		close (LOGFILE);
		if($state->{encrypting}){ encryptlogs($self) };
	}
	if(lc($message->{body}) =~ m/.*stop *logging.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){ #make sure it is to loggerbot 
			#call is_channel_operator on underlying IRC state object
			#only ops can shut down loggerbot
			$state->{logging} = 0;
			return "logging stopped.";
		}
		elsif(!$self->pocoirc->is_channel_operator($message->{channel})){
			 return "only channel operators can do this";
		}
	}
	if(lc($message->{body}) =~ m/.*start *logging.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){ 
			$state->{logging} = 1;
			return "logging resumed.";
		}
		elsif(!$self->pocoirc->is_channel_operator($message->{channel})){
			 return "only channel operators can do this";
		}
	}
	if(lc($message->{body}) =~ m/.*shut *down.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){
			if($state->{encrypting}){
				unlink <log*.txt>;
			}
			savestate();
			$self->shutdown($self->quit_message());
		}
		elsif(!$self->pocoirc->is_channel_operator($message->{channel})){
			 return "only channel operators can do this";
		}
	}
	if(lc($message->{body}) =~ m/are you logging.*/ && $message->{address}){
		if($state->{logging}){ return "I am logging chat."; }
		else{ return "I am not logging chat."; }
	}
	if(lc($message->{body}) =~ m/are you encrypting.*/ && $message->{address}){
		if($state->{encrypting}){ return "I am encrypting logs."; }
		else{ return "I am not encrypting logs."; }
	}
	if(lc($message->{body}) =~ m/.*start *encrypting.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){
			$state->{encrypting} = 1;
			return "encrypting logs.";
		}
		elsif(!$self->pocoirc->is_channel_operator($message->{channel})){
			 return "only channel operators can do this";
		}
	}
	if(lc($message->{body}) =~ m/.*stop *encrypting.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){
			unlink <log*.crypt>;
			$state->{encrypting} = 0;
			return "decrypting logs.";
		}
		elsif(!$self->pocoirc->is_channel_operator($message->{channel})){
			 return "only channel operators can do this";
		}
	}
	if(lc($message->{body}) =~ m/.*(erase|delete) *logs.*/){
		if($self->pocoirc->is_channel_operator($message->{channel}, $message->{who}) && $message->{address}){
			$self->wipelogs($self);
			return "erasing logs.";
		}
		elsif(!$self->pocoirc->is_channel_operator($message->{channel})){
			 return "only channel operators can do this";
		}
	}
	return undef; #if nothing else happens, don't speak
}

sub help(){
	return "This bot logs chat. Operator only commands: start/stop logging, shut down, encrypt/decrypt logs, and erase logs. Anyone can check if the bot is logging with \"are you logging\".";
}

sub tick{
	my $self = shift;
	if($state->{encrypting}){
		encryptlogs($self);
	}
	return 10;
}

sub connected{
	my $self = shift;
	$self -> say(who => "NickServ", channel => "msg", body => "identify $config->{nickpass}");
}

LogBot->new(

    server => $config->{server},
    port   => $config->{port},
    ssl => $config->{ssl},
    channels => [split(' ', $config->{channels})],

    nick      => $config->{nick},
    username => $config->{username},
    quit_message => $config->{quit_message}


  )->run();

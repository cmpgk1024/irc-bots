use warnings;
use strict;

package ThunderBot;
use base qw( Bot::BasicBot );

my $storming = 0;

my $stormy = ThunderBot->new(

    server => "irc.foonetic.net",
    port   => "6697",
    ssl => 1,
    channels => ["#sudoers"],

    nick      => "stormy",
    username => "stormer"


  );

sub said {
      my ($self, $message) = @_;
      if (lc($message->{body}) =~ /\bthunder\b/) {
      	$storming = 1;
      	print "thunderstorm time!";
      	return undef;
      }
      #elsif($message->{body} =~ /\b(S|s)top\b/ && $message->{body} =~ /($stormy->nick)/){
     elsif(lc($message->{body}) =~ /\bshut up\b/){
     	print "no more thunder D:";
		$storming = 0;
    	return undef;
      }
}

sub tick {
	my $self = shift;
	if($storming){
		$self->say(
		channel => "#sudoers",
		body => " " x (15 - length $stormy->nick) . "<3 thunder");
	}
	return 3;
}

$stormy->run();
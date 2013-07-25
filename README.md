#irc-bots


This repository contains IRC bots used on a channel I currently run, #sudoers.  

##logbot
LogBot logs chats. You can put LogBot in as many channels as you like. Logs will be put in separate files with this naming convention: "log\<channel\>.txt".
###Commands
Send LogBot commands by addressing it, followed by your command. Current commands are:
* start logging  
requires operator status
* stop logging  
requires operator status
* are you logging  

* start encrypting  
requires operator status
* stop encrypting  
requires operator status
* are you encrypting  

* shut down  
requires operator status

* delete logs / erase logs  
requires operator status

##Configuration
Make a file called "logbot.properties" in the same file as the script. Sample config file:  
`cryptokey=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`  
`nickpass=password`  
`nick=loggerbot`  
`server=irc.foonetic.net`  
`port=6697`  
`ssl=1`  
`channels=#xyz`  

###Bugs
- does not log itself - overriding say subroutine might be necessary
- occasionally spits out uninitialized regex errors


##stormy
Stormy just waits until he hears something about thunder, then says <3 thunder until you tell him to shut up (stormy: shut up). Nothing else to say, really.

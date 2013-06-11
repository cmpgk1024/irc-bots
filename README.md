#irc-bots


This repository contains IRC bots used on a channel I currently run, #sudoers.  

##logbot
LogBot is pretty self-explanatory - it logs chats. You can put LogBot in as many channels as you like. Logs will be put in separate files with this naming convention: "log<channel>.txt".
###Commands
Send LogBot commands by addressing it, followed by your command.
* start logging  
Starts the collection of logs. You must be a channel operator to perform this command. It is important to note that LogBot logs by default.
* stop logging  
Stops the collection of logs. You must be a channel operator to perform this command.
* are you logging  
LogBot will reply to you indicating whether it is collecting logs.

###Bugs
- does not log itself - overriding say subroutine might be necessary
- occasionally spits out uninitialized regex errors


###Planned additions
* timestamps
* improve regexes

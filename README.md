#irc-bots


This repository contains IRC bots used on a channel I currently run, #sudoers.  

##logbot
LogBot is pretty self-explanatory - it logs chats. You can put LogBot in as many channels as you like. Logs will be put in separate files with this naming convention: "log<channel>.txt". You can address it with start logging or stop logging to toggle logging. You can also ask it if it's logging with "are you logging" or shut it down by addressing it with "shut down". You must be a channel operator to change settings for LogBot.
###Bugs
- does not log itself - overriding say subroutine might be necessary
- occasionally spits out uninitialized regex errors


###Planned additions
* timestamps

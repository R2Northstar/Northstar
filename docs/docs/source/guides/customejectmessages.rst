Custom Ejection Messages
==================
How ejection messages are chosen
--------------------------
When ejecting the game selects a random number between 0 and 1, if this number is greater than 0.15 then a random common eject message is returned, if it is less than 0.15 then a rare ejection message is returned.

Adding new messages
-----------------
Using ``AddCommonEjectMessage( String message )`` and ``AddRareEjectMessage( String message )`` in script additional messages can be added to the pool of potential ejection messages

Localisation
------------
Like most things custom ejection messages can be localised through keyvalues

There are no functions to remove ejection messages, however existing ones can be altered by modifying localisation files

# HUD Messages

Functions to render text on the client screen.

Because these can not be removed in demos and are somewhat ugly, **it is recommended to use** [Serverside RUI](../../northstar/serversiderui.md)  **instead**

!!! cpp-function "void SendHudMessage( entity player, string text, int xPos, int yPos, int r1, int g1, int b1, number a1, number r2, number g2, number b2, number a2, number fadeTimeIn, number holdTime, number fadeTimeOut )"

  Send a HUD message to the given player.

!!! cpp-function "void SendHudMessageToAll( string text, int xPos, int yPos, int r1, int g1, int b1, number a1, number r2, number g2, number b2, number a2, number fadeTimeIn, number holdTime, number fadeTimeOut )"

  Send a HUD message to all players.

!!! cpp-function "void CenterPrintAll( string text )"

  Prints white text in the center of the screen on all clients.

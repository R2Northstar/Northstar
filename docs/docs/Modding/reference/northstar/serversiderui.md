# Serverside RUI {#serverside-rui-doc}


Server-side Rui provides a set of functions enabling servers to display complex hud elements on clients without requiring a client-side mod. These functions were introduced in Northstar `1.10.0`.

It should be noted that there’s no guarantee the client will see the hud elements.

## Polls

Creates a poll on `player`.

<figure class="screenshotalign-center">
<img src="/_static/serversiderui/vote.png" class="screenshot"
alt="/_static/serversiderui/vote.png" />
<figcaption>Player POV</figcaption>
</figure>

**Definition:**

!!! cpp-function "void NSCreatePollOnPlayer( entity player, string header, array<string> options, float duration )"

**Example:**

```squirrel
void function CreateDummyPoll()
{
    array<string> options = [ "Vote for a map!", "Amongsus", "sussy", "when", "1.10", "hi H0l0" ]
    foreach(entity player in GetPlayerArray())
        NSCreatePollOnPlayer(player, "Vote who's the biggest dummy!", options, 30)
}
```

### Getting Response

**Definition:**

!!! cpp-function "int NSGetPlayerResponse( entity player )"

    Returns the index of the item from `options` the player voted for. If the player hadn't voted yet it returns a -1.

**Example:**

```squirrel
void function CheckResponseToDummyPoll(entity player)
{
    if(NSGetPlayerResponse(player) != -1)
        print("Player has voted!")
}
```

## Large Message

Sends a large message to `player` which will appear in the top right corner.

<figure class="screenshotalign-center">
<img src="/_static/serversiderui/largemessage.gif" class="screenshot"
alt="/_static/serversiderui/largemessage.gif" />
<figcaption>Player POV</figcaption>
</figure>

**Definition:**

!!! cpp-function "void NSSendLargeMessageToPlayer( entity player, string title, string description, float duration, string image )"

**Example:**

```squirrel
void function SendDummyLargeMessage(entity player)
{
    NSSendLargeMessageToPlayer(player,"I'm not a dummy >:(", "You are", 10, "ui/fd_tutorial_tip.rpak")
}
```

## Info Message

Sends a smaller message to `player` which will appear from the center right.

<figure class="screenshotalign-center">
<img src="/_static/serversiderui/info.gif" class="screenshot"
alt="/_static/serversiderui/info.gif" />
<figcaption>Player POV</figcaption>
</figure>

**Definition:**

!!! cpp-function "void NSSendInfoMessageToPlayer( entity player, string text )"

**Example:**

```squirrel
void function SendDummyInfoMessage(entity player)
{
    NSSendInfoMessageToPlayer(player, "we were sent at the same time but I was sent sooner")
}
```

## PopUp

Send a small popup to `player` which will appear in the lower half of their screen under their cursor.

<figure class="screenshotalign-center">
<img src="/_static/serversiderui/popup.gif" class="screenshot"
alt="/_static/serversiderui/popup.gif" />
<figcaption>Player POV</figcaption>
</figure>

**Definition:**

!!! cpp-function "void function NSSendPopUpMessageToPlayer( entity player, string text )"

**Example:**

```squirrel
void funcions SendDummyPopUp(entity player)
{
    NSSendPopUpMessageToPlayer(player, "very cool text I like")
}
```

## Announcement

Sends a large announcement to `player`.

<figure class="screenshotalign-center">
<img src="/_static/serversiderui/announcement.gif" class="screenshot"
alt="/_static/serversiderui/announcement.gif" />
<figcaption>Player POV</figcaption>
</figure>

**Definition:**

!!! cpp-function "void NSSendAnnouncementMessageToPlayer( entity player, string title, string description, vector color, int priority, int style )"

**Example:**

```squirrel
void function SendDummyAnnouncement(entity player)
{
    NSSendAnnouncementMessageToPlayer(player, "Very cool announcement", "Hi Karma", <1,1,0>, 1, ANNOUNCEMENT_STYLE_QUICK)
}
```

## Status

Status messages allow you to show live data to the player.
Currently status messages are limited to 4 and there's no way to know if the player can see your message.

<figure class="screenshotalign-center">
<img src="/_static/serversiderui/status.gif" class="screenshot"
alt="/_static/serversiderui/status.gif" />
<figcaption>Player POV</figcaption>
</figure>

**Definitions:**

!!! cpp-function "void  NSCreateStatusMessageOnPlayer( entity player, string title, string description, string id )"

    Creates a status message on `player`. `id` is used to identify and edit the message, make sure your id is unique! To generate a unique id, use UniqueString().

!!! cpp-function "void  NSEditStatusMessageOnPlayer( entity player, string title, string description, string id  )"

    Allows for editing of the `title` and `description` of a message which was created using `id`.

!!! cpp-function "void  NSDeleteStatusMessageOnPlayer( entity player, string id  )"

    Deletes the status message which was created with `id`

**Examples:**

```squirrel
void function TestStatusMessage_Threaded(entity player)
{
    string id = UniqueString("votes#")
    NSCreateStatusMessageOnPlayer(player, "have voted", "[0/12]", id)
    wait 3
    NSEditStatusMessageOnPlayer(player, "have voted", "[1/12]", id)
    wait 10
    NSDeleteStatusMessageOnPlayer(player, id)
}
```

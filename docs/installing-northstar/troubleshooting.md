# Troubleshooting

## Engine Error

![Engine Error: File corruption detected. Please repair or re-install the game.](https://user-images.githubusercontent.com/39478251/147338706-74797220-7d7f-4c81-9ba0-d88e29a2a1e2.png)

Don't panic! This warning seems to be caused by Origin and none of your files are actually corrupted. If you get this warning after launching the game try the following steps, closing the game before and launching it again  after:

1. Restart Origin  
   Also check task manager that all Origin processes are gone before restarting it  
   (even if you have the Steam version)
2. Restart your PC
3. Start Northstar with Origin already open
4. Start Northstar with Origin fully closed.
5. Make sure you got the newest version of Northstar
6. Verify game files via Steam/Origin (depending on where you own the game)
7. Check Github issues if anyone else is experiencing this problem. Maybe current release has a bug.
8. Start vanilla game and see if this works
9. If you followed all these steps and even launching the vanilla version of the game doesn't work, your final option is to fully remove the game and reinstall it.  
   Then check if vanilla works before reinstalling Northstar.

## Issues with newest Intel CPU (10th+ gen):

On newer Intel CPUs you might see a message like this

> "Contacting Respawn servers.../Data Center: Searching..."

If you are seeing this in the main menu of TF|2 and have a 10th or 11th generation Intel CPU this is a bug which has a simple fix:

In the Windows Start menu on the bottom left search for "Edit the system environment variables" and open the program. In the "advanced" tab click on "Environment Variables..." near the bottom.  
In System Variables (not user variables) click "New..." and add a new system variable where the variable name is `OPENSSL_ia32cap` and the value is `~0x200000200000000`. Make sure to click OK to apply the changes. Finally restart your device and you should be good to go.

**Note:** This issue is not exclusive to Northstar client but also affects the vanilla version, so if you only get it on Northstar there might be a different problem at hand as well. In fact it's not even unique to Titanfall 2 either.

See also [this thread on Steam](https://steamcommunity.com/app/1237970/discussions/0/3081016749018656768/)

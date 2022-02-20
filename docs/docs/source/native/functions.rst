Functions
=========

The vast majority of GNUT modding within northstar will be done through functions, so understanding the formatting of functions can be somewhat important

Declaring Functions
--------------------
Functions in squirrel are first defined by stating both the **output** followed by the keyword **function**, for example if you wanted to define a function that returns TRUE or FALSE you would:

.. code-block:: javascript

  bool function ReturnTrueOrFalse()


But what if I want my function not to give stuff, but to DO stuff? for that you can define your function as ``void``, this indicated that your function does not return anything. for example:

.. code-block:: javascript

  void function ThisDoesStuff()


If statements
---------------
If statements use a similar style to most programming languages and will execute their asigned code if the test returns the boolean value true, it is worth remembering that unlike some languages the interger 1 is NOT considered equal to the boolean true, true is also always expressed in lowercase when used by a bool function. if i wanted to have something occur if, and only if, our previous ``ReturnTrueOrFalse`` function returned true, then you can use:

.. code-block:: javascript

  if(ReturnTrueOrFalse())


If statements are also functions however, and can be used to determine true or false on their own when provided the == (equal to?) != (not equal to) < (less than) or >(greater than) symbols, if I wanted to simulte rolling a dice and only execute code on a 5 then i could instead:

.. code-block:: javascript

  if(RandomInt(5)+1 == 5)

You can also use short if statements to simplify your code. However, if not used carefully this can worsen readability.
The Syntax is ``condition ? if_condition_true : if_condition_false``. This is especially useful when declaring variables or passing parameters.

.. code-block:: javascript

  // shortenedUsername is "longus..."" if username is "longusername" or "short" if username is "short"
  string shortenedUsername = username.len() > 9 ? username.slice(0,6) + "..." : username;

Loops
------
Loops fall into a few categories but for our purposes we will be only using ``foreach`` and ``while``. ``foreach`` loops are given a data set, such as a list, and will repeat their asigned script for each entry on that list.

.. code-block:: javascript

  array<interger> someinformation = [1,2,3,4,5,6]
  foreach( interger information in someinformation)

while a ``foreach`` loop will occur only as many times as the length of the list. a ``while`` loop functions more like an ``if`` statement, repeating itself endlessly until the test is no longer true

.. code-block:: javascript

  while(ReturnTrueOrFalse)

This script will repeat endlessly until ``ReturnTrueOrFalse`` returns false

Formatting of actions
---------------------
So great, we can loop and check things, but what can we do with this information? Squirrel uses ``{}`` to denote the contense of a series of actions caused by such a statement, however single-line scripts can be used without these, and will just be assumed.

For example, lets make our ReturnTrueOrFalse function, that randomly picks either true or false, first:

.. code-block:: javascript

  bool function ReturnTrueOrFalse()
    return(RandomInt(1) == 1)

As this is a 1 line function it can be executed without needing any ``{}``, but for a longer function we might need one, now lets make a more complicated function that will use the previous script to determine true or false, then each time it returns true it will print each number in the ``someinformation`` array

.. code-block:: javascript

  array<interger> someinformation = [1,2,3,4,5,6]
  void ThisDoesStuff(){
    while(ReturnTrueOrFalse()){
      foreach( interger information in someinformation){
        print(information)
      }
    }
  }


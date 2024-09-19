# Stack

Squirrel exchanges values with the virtual machine through a stack.
This mechanism has been inherited from the language Lua.
For instance to call a Squirrel function from native code it is necessary to push the function and the arguments in the stack and then invoke the function;
also when Squirrel calls a native function the parameters will be in the stack as well.

## Stack Indexes

Many API functions can arbitrarily refer to any element in the stack through an index. The stack indexes follow these conventions:

- 1 is the stack base
- Negative indexes are considered an offset from top of the stack. For instance -1 is always the last item pushed to the stack
- 0 is an invalid index

See this example stack for reference:

|Stack|Positive index|Negative index|
|-----|--------------|--------------|
|p4|4| -1|
|p3|3| -2|
|p2|2| -3|
|p1|1| -4|


## Stack manipulation

The Squirrel API offers several functions to push and retrieve data from the Stack.


!!! cpp-function "__int64 removeFromStack(HSquirrelVM* sqvm)"

    !!! note

        This function (`server.dll+0x7000```) is not available in the launcher or plugins at the moment.

        You can open a PR if you need it now.

    - `HSquirrelVM* sqvm` the target vm

    pops the top item of the stack.

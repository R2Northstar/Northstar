!!! warning

    Parameters or descriptions may be wrong or incomplete

    This list is incomplete and only lists methods available in [squirrel.h](https://github.com/R2Northstar/NorthstarLauncher/blob/main/NorthstarDLL/squirrel/squirrel.h).

    Some descriptions are taken from the [Squirrel Documentation](http://www.squirrel-lang.org/mainsite/squirreldoc/reference/api_reference.html)

# Object creation and handling

!!! cpp-class "SquirrelManager"

    You can access all sq functions only with a `SquirrelManager` instance. You have one available inside the `ADD_SQFUNC` macro.

## Pushing Objects to the stack


!!! cpp-function "void pushbool(HSquirrelVM* sqvm, const SQBool bVal)"

    - `HSquirrelVM* sqvm` the target VM
    - `SQInteger bVal` the bool that will be pushed

    pushes a boolean to the stack


!!! cpp-function "void pushinteger(HSquirrelVM* sqvm, const SQInteger iVal)"

    - `HSquirrelVM* sqvm` the target VM
    - `SQInteger iVal` the integer that will be pushed



!!! cpp-function "void pushfloat(HSquirrelVM* sqvm, const SQFloat fVal)"

    - `HSquirrelVM* sqvm` the target VM
    - `SQInteger fVal` the float that will be pushed

    pushes a float to the stack


!!! cpp-function "void pushstring(HSquirrelVM* sqvm, const SQChar* sVal, int length = -1)"

    - `HSquirrelVM* sqvm` the target VM
    - `SQChar* sVal` the string that will be pushed
    - `int len` length of the string `sVal`
    . If the parameter length is less than 0 the VM will calculate the length using `strlen`

    pushes a string to the stack


!!! cpp-function "void pushasset(HSquirrelVM* sqvm, const SQChar* sVal, int length = -1)"

    - `HSquirrelVM* sqvm` the target VM
    - `SQChar* sVal` the string that will be pushed
    - `int len` length of the string `sVal`
    . If the parameter length is less than 0 the VM will calculate the length using `strlen`

    pushes an asset to the stack


!!! cpp-function "void pushvector(HSquirrelVM* sqvm, const Vector3 vVal)"

    - `HSquirrelVM* sqvm` the target VM
    - `Vector3 vVal` the vector that will be pushed

    pushes a vector to the stack


!!! cpp-function "void pushobject(HSquirrelVM* sqvm, SQObject obj)"

    - `HSquirrelVM* sqvm` the target VM
    - `SQObject obj` the object that will be pushed

    pushes an object like functions to the stack


!!! cpp-function "void pushroottable(HSquirrelVM* sqvm)"

    - `HSquirrelVM* sqvm` the target VM

    pushes the current root table into the stack

!!! note
    `sq_pushnull` (`0x33D0`) and more aren't included in `squirrel.h` right now but may be in the future.

## Getting Objects from the stack


!!! cpp-function "SQBool getbool(HSquirrelVM* sqvm, const SQInteger stackpos)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger stackpos` stack position of the object
    - Returns The value of the object


!!! cpp-function "SQInteger getinteger(HSquirrelVM* sqvm, const SQInteger stackpos)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger stackpos` stack position of the object
    - Returns The value of the object



!!! cpp-function "SQFloat getfloat(HSquirrelVM* sqvm, const SQInteger stackpos)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger stackpos` stack position of the object
    - Returns The value of the object



!!! cpp-function "SQChar* getstring(HSquirrelVM* sqvm, const SQInteger stackpos)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger stackpos` stack position of the object
    - Returns The value of the object



!!! cpp-function "Vector3 getvector(HSquirrelVM* sqvm, const SQInteger stackpos)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger stackpos` stack position of the object
    - Returns The value of the object



!!! cpp-function "SQChar* getasset(HSquirrelVM* sqvm, const SQInteger stackpos)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger stackpos` stack position of the object
    - Returns The value of the object



!!! cpp-function "SQTable* getConstants(HSquirrelVM* sqvm)"

    !!! note

        This function (`server.dll+0x5920```) is not available in the launcher or plugins at the moment.

        You can open a PR if you need it now.

        To define an integer constant you can use `defconst` instead.


    - `HSquirrelVM* sqvm` the target vm
    - Returns the table of constants

    Pushes the constants table to the stack.

    Used to add global constants for scripts.

    ```cpp
        getConstants(sqvm);

        pushstring(sqvm, "MY_CONSTANT");
        pushstring(sqvm, "MY_VALUE");
        newslot(sqvm, -3, false);

        removeFromStack(sqvm); // don't forget this!
    ```


!!! cpp-function "int sq_getfunction(HSquirrelVM* sqvm, const SQChar* name, SQObject* returnObj, const SQChar* signature)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQChar* name` the function name to search for
    - `SQObject* returnObj` reference to the object to hold the function object
    - `SQChar* signature`

    returns `0` if the function was found.

    ```cpp
        SQObject functionobj {};
        int result = sq_getfunction(m_pSQVM->sqvm, funcname, &functionobj, 0);
        if (result != 0) // This func returns 0 on success for some reason
        {
            NS::log::squirrel_logger<context>()->error("Call was unable to find function with name '{}'. Is it global?", funcname);
            return SQRESULT_ERROR;
        }
    ```

!!! cpp-function "T* getentity(HSquirrelVM* sqvm, SQInteger iStackPos)"

    - `HSquirrelVM* sqvm` The target vm
    - `SQInteger iStackPos` Stack position of the entity


!!! cpp-function "void* __sq_getentityfrominstance(CSquirrelVM* sqvm, SQObject* pInstance, char** ppEntityConstant)"

    - `CSquirrelVM* sqvm` The target vm
    - `SQObject* pInstance` Instance holding an entity
    - `char** ppEntityConstant` Entity constant like `ref`__sq_GetEntityConstant_CBaseEntity <sq-GetEntityConstant-CBaseEntity>`


!!! cpp-function "char** __sq_GetEntityConstant_CBaseEntity()"

    There are entity constants for other types, but seemingly CBaseEntity's is the only one needed


!!! cpp-function "SQRESULT __sq_getobject(HSquirrelVM* sqvm, SQInteger iStackPos, SQObject* obj)"

    - `HSquirrelVM* sqvm` The target vm
    - `SQInteger iStackPos` Stack position of the object
    - `SQObject* obj` Pointer that will hold the object

    `obj` will be overwritten to hold the squirrel object.

    This example adds a native function with the `ADD_SQFUNC` macro.
    The function takes a function reference as a callback and calls it immediately.
    More information about function calls are available [here](sq_functions.md)

    ```cpp
        ADD_SQFUNC("void", SQCallbackTest, "void functionref()", "", ScriptContext::UI)
        {
            SQObject fn; // Make an empty sqobject. This will hold the function object later
            g_pSquirrel<context>->__sq_getobject(sqvm, 1, &fn); // Assign the function object to the SQOBJECT
            g_pSquirrel<context>->pushobject(sqvm, &fn); // Push the function object for the call
            g_pSquirrel<context>->pushroottable(sqvm); // Push the root table for the function stack
            g_pSquirrel<context>->__sq_call(sqvm, 1, false, true); // call the function with one parameter (the 'this' object)

            return SQRESULT_NULL;
        }
    ```

!!! cpp-function "SQRESULT get(HSquirrelVM* sqvm, const SQInteger stackpos)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger stackpos` stack position of the object

    Returns an `SQRESULT` that indicates whether or not the access was successful.

    pops a key from the stack and performs a get operation on the object at the position idx in the stack; and pushes the result in the stack.

## Stack Infos


!!! cpp-function "SQRESULT sq_stackinfos(HSquirrelVM* sqvm, int level, SQStackInfos& out)"

    - `HSquirrelVM* sqvm` the target vm
    - `int level` stack depth of the info
    - `SQStackInfos& out` instance that will hold the information


!!! cpp-function "Mod* getcallingmod(HSquirrelVM* sqvm, int depth = 0)"

    - `HSquirrelVM* sqvm` the target vm
    - `int depth` stack depth of the origin mod
    - Returns Pointer to the Mod object at the stack depth

    !!! note

        Not available in [plugins](https://github.com/R2Northstar/NorthstarLauncher/blob/main/NorthstarDLL/plugins/plugin_abi.h>)

## Other


!!! cpp-function "void defconst(CSquirrelVM* csqvm, const SQChar* pName, int nValue)"

    - `CSquirrelVM* csqvm` the target vm
    - `SQChar* pName` the constant name
    - `int nValue` the constant value

    defines a global squirrel integer constant

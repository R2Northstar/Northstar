# Squirrel Functions


## Adding Squirrel Functions {#sq-api-register-native-functions-c-macro}

You can use the `ADD_SQFUNC` macro defined in `squirrelautobind.h` to easily add new Squirrel functions for specific contexts.

Inside the macro you have access to the Squirrel Manager of the context the function has been called from and the SQVM.

Parameters are the initial stack in the function context.

!!! cpp-function "macro ADD_SQFUNC(return_type, funcName, argTypes, helpText, runOnContext)"

    - `return_type` The squirrel return type the compiler expects from this function
    - `funcName` The squirrel function name
    - `argTypes` The args with types the compiler expects
    - `helpText` A help text describing the function
    - `runOnContext` The contexts that have access to this function

### Examples

Return a string from a native registered function:

```cpp

    ADD_SQFUNC("string", CPlugTest, "", "returns \"native gaming\"", ScriptContext::CLIENT | ScriptContext::SERVER)
    {
        g_pSquirrel<context>->pushstring(sqvm, "native gaming"); // push a string to the stack

        return SQRESULT_NOTNULL; // Signal that the topmost item on the stack is returned by this function
    }
```

Return a complex `ornull` type:

```cpp

    ADD_SQFUNC("array<int> ornull", CPlugComplex, "int n", "returns null", ScriptContext::CLIENT | ScriptContext::SERVER | ScriptContext::UI)
    {
        SQInteger n = g_pSquirrel<context>->getinteger(sqvm, 1);

        if (n == 0)
            return SQRESULT_NULL;

        g_pSquirrel<context>->newarray(sqvm, 0);
        g_pSquirrel<context>->pushinteger(sqvm, n);
        g_pSquirrel<context>->arrayappend(sqvm, 2);
        g_pSquirrel<context>->pushinteger(sqvm, n * 2);
        g_pSquirrel<context>->arrayappend(sqvm, 2);

        return SQRESULT_NOTNULL; // return the array [ n, n * 2 ] or NULL if n == 0
    }
```

## Replacing Squirrel Functions

!!! note

    Replacing functions is not possible in plugins

You can use the `REPLACE_SQFUNC` macro to replace an existing sq function.

!!! cpp-function "macro REPLACE_SQFUNC(funcName, runOnContext)"

    - `funcName` The name of the function to replace
    - `runOnContext` The contexts that have access to this function

It's also possible to add an override directly with the `AddFuncOverride` function of the `SquirrelManager` class.

!!! cpp-function "void AddFuncOverride(std::string name, SQFunction func)"

    - `std`string name` The name of the function to override
    - `SQFunc func` A function object that replaces the logic

```cpp

    // Replaces dangerous vanilla functions to only log their call with no further logic.
    g_pSquirrel<context>->AddFuncOverride("DevTextBufferWrite", SQ_StubbedFunc<context, "DevTextBufferWrite">);
    g_pSquirrel<context>->AddFuncOverride("DevTextBufferClear", SQ_StubbedFunc<context, "DevTextBufferClear">);
    g_pSquirrel<context>->AddFuncOverride("DevTextBufferDumpToFile", SQ_StubbedFunc<context, "DevTextBufferDumpToFile">);
```

## Script Contexts

Scriptcontexts are used to define the VMs that have access to a native function. Available Contexts are

- `ScriptContext::SERVER` - The SERVER sqvm
- `ScriptContext::CLIENT` - The CLIENT sqvm
- `ScriptContext::UI` - The UI vm

## Script Returns

Squirrel functions need to return a `SQRESULT`. Valid results are

- `SQRESULT_NULL` - This function returns `null`. Nothing is left over on the stack.
- `SQRESULT_NOTNULL` - This functions returns the last item on the stack.
- `SQRESULT_ERROR` - This function has thrown an error.


## Calling {#sq-api-calling-functions}


!!! cpp-function "SQRESULT Call(const char* funcname)"

    - `char* funcname` Name of the function to call

    !!! note

        This is a squirrel API wrapper added by northstar. It's not available for plugins and is supposed to abstract squirrel calls.


    This function assumes the squirrel VM is stopped/blocked at the moment of call

    Calling this function while the VM is running is likely to result in a crash due to stack destruction

    If you want to call into squirrel asynchronously, use `AsyncCall`_ instead.

    ```cpp

        Call("PluginCallbackTest"); // PluginCallbackTest()
    ```


!!! cpp-function "SQRESULT Call(const char* funcname, Args... args)"

    - `char* funcname` Name of the function to call
    - `Args... args` vector of args to pass to the function

    !!! note

        This is a squirrel API wrapper added by northstar. It's not available for plugins and is supposed to abstract squirrel calls.

    ```cpp

        Call("PluginCallbackTest", "param"); // PluginCallbackTest("param")
    ```


!!! cpp-function "SquirrelMessage AsyncCall(std::string funcname)"

    - `char* funcname` Name of the function to call

    !!! note

        This is a squirrel API wrapper added by northstar. It's not available for plugins and is supposed to abstract squirrel calls.

    This function schedules a call to be executed on the next frame

    This is useful for things like threads and plugins, which do not run on the main thread.


!!! cpp-function "SquirrelMessage AsyncCall(std::string funcname, Args... args)"

    - `char* funcname` Name of the function to call
    - `Args... args` vector of args to pass to the function

    !!! note

        This is a squirrel API wrapper added by northstar. It's not available for plugins and is supposed to abstract squirrel calls.



!!! cpp-function "SQRESULT _call(HSquirrelVM* sqvm, const SQInteger args)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger args` number of arguments to call this function with

    `_call` adds one to the `args` count for `this`.

    !!! note

        This is a squirrel API wrapper added by northstar. It's not available for plugins and is supposed to abstract squirrel calls.

    ```cpp

        SQObject functionobj {};
        SQRESULT result = g_pSquirrel<context>->sq_getfunction(sqvm, "PluginCallbackTest", &functionobj, 0); // Get a global squirrel function called "PluginCallbackTest"

        if (result == SQRESULT_ERROR)
        {
            spdlog::error("Unable to find function. Is it global?");
            return SQRESULT_ERROR;
        }

        g_pSquirrel<context>->pushobject(sqvm, &functionobj);
        g_pSquirrel<context>->pushroottable(sqvm);
        g_pSquirrel<context>->pushstring(sqvm, "param");
        return g_pSquirrel<context>->_call(sqvm, 1); // PluginCallbackTest("param")
    ```


!!! cpp-function "SQRESULT __sq_call(HSquirrelVM* sqvm, SQInteger iArgs, SQBool bShouldReturn, SQBool bThrowError)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQInteger iArgs` number of parameters of the function
    - `SQBool bShouldReturn` if true the function will push the return value to the stack
    - `SQBool bThrowError` if true, if a runtime error occurs during the execution of the call, the vm will invoke the error handler

    calls a closure or a native closure. The function pops all the parameters and leave the closure in the stack; if retval is true the return value of the closure is pushed. If the execution of the function is suspended through sq_suspendvm(), the closure and the arguments will not be automatically popped from the stack.

    When using to create an instance, push a dummy parameter to be filled with the newly-created instance for the constructor's `this` parameter.

## Errors


!!! cpp-function "SQRESULT raiseerror(HSquirrelVM* sqvm, const SQChar* error)"

    - `HSquirrelVM* sqvm` the target vm
    - `SQChar* error` string thrown
    - Returns `SQRESULT_ERROR`

    Throws an error with `error` being the thrown object.

    ```cpp

        ADD_SQFUNC("void", CPlugThrowTest, "", "", ScriptContext::UI)
        {
            return g_pSquirrel<context>->raiseerror(sqvm, "test error");
        }

        /* sq:
        try {
            CPlugThrowTest()
        } catch(e) {
            print(e) // "test error"
        }
        */
    ```

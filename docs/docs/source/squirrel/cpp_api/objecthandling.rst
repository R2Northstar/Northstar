.. warning::

    Parameters or descriptions may be wrong or incomplete

    This list is incomplete and only lists methods available in `squirrel.h <https://github.com/R2Northstar/NorthstarLauncher/blob/main/NorthstarDLL/squirrel/squirrel.h>`_.

    Some descriptions are taken from the `Squirrel Documentation <http://www.squirrel-lang.org/mainsite/squirreldoc/reference/api_reference.html>`_

Object creation and handling
============================

.. cpp:class:: SquirrelManager

    You can access all sq functions only with a ``SquirrelManager`` instance. You have one available inside the ``ADD_SQFUNC`` macro.

Pushing Objects to the stack
----------------------------

.. _pushbool:

.. cpp:function:: void pushbool(HSquirrelVM* sqvm, const SQBool bVal)

    :param HSquirrelVM* sqvm: the target VM
    :param SQInteger bVal: the bool that will be pushed

    pushes a boolean to the stack

.. _pushinteger:

.. cpp:function:: void pushinteger(HSquirrelVM* sqvm, const SQInteger iVal)

    :param HSquirrelVM* sqvm: the target VM
    :param SQInteger iVal: the integer that will be pushed

    pushes an integer to the stack

.. _pushfloat:

.. cpp:function:: void pushfloat(HSquirrelVM* sqvm, const SQFloat fVal)

    :param HSquirrelVM* sqvm: the target VM
    :param SQInteger fVal: the float that will be pushed

    pushes a float to the stack

.. _pushstring:

.. cpp:function:: void pushstring(HSquirrelVM* sqvm, const SQChar* sVal, int length = -1)

    :param HSquirrelVM* sqvm: the target VM
    :param SQChar* sVal: the string that will be pushed
    :param int len: length of the string ``sVal``
    :remarks: if the parameter length is less than 0 the VM will calculate the length using ``strlen``

    pushes a string to the stack

.. _pushasset:

.. cpp:function:: void pushasset(HSquirrelVM* sqvm, const SQChar* sVal, int length = -1)

    :param HSquirrelVM* sqvm: the target VM
    :param SQChar* sVal: the string that will be pushed
    :param int len: length of the string ``sVal``
    :remarks: if the parameter length is less than 0 the VM will calculate the length using ``strlen``

    pushes an asset to the stack

.. _pushvector:

.. cpp:function:: void pushvector(HSquirrelVM* sqvm, const Vector3 vVal)

    :param HSquirrelVM* sqvm: the target VM
    :param Vector3 vVal: the vector that will be pushed

    pushes a vector to the stack

.. _pushobject:

.. cpp:function:: void pushobject(HSquirrelVM* sqvm, SQObject obj)

    :param HSquirrelVM* sqvm: the target VM
    :param SQObject obj: the object that will be pushed

    pushes an object like functions to the stack

.. _pushroottable:

.. cpp:function:: void pushroottable(HSquirrelVM* sqvm)

    :param HSquirrelVM* sqvm: the target VM

    pushes the current root table into the stack

.. note::

    ``sq_pushnull`` (``0x33D0``) and more aren't included in ``squirrel.h`` right now but may be in the future.

Getting Objects from the stack
------------------------------

.. _getbool:

.. cpp:function:: SQBool getbool(HSquirrelVM* sqvm, const SQInteger stackpos)

    :param HSquirrelVM* sqvm: the target vm
    :param SQInteger stackpos: stack position of the object
    :returns: The value of the object

.. _getinteger:

.. cpp:function:: SQInteger getinteger(HSquirrelVM* sqvm, const SQInteger stackpos)

    :param HSquirrelVM* sqvm: the target vm
    :param SQInteger stackpos: stack position of the object
    :returns: The value of the object


.. _getfloat:

.. cpp:function:: SQFloat getfloat(HSquirrelVM* sqvm, const SQInteger stackpos)

    :param HSquirrelVM* sqvm: the target vm
    :param SQInteger stackpos: stack position of the object
    :returns: The value of the object


.. _getstring:

.. cpp:function:: SQChar* getstring(HSquirrelVM* sqvm, const SQInteger stackpos)

    :param HSquirrelVM* sqvm: the target vm
    :param SQInteger stackpos: stack position of the object
    :returns: The value of the object


.. _getvector:

.. cpp:function:: Vector3 getvector(HSquirrelVM* sqvm, const SQInteger stackpos)

    :param HSquirrelVM* sqvm: the target vm
    :param SQInteger stackpos: stack position of the object
    :returns: The value of the object


.. _getasset:

.. cpp:function:: SQChar* getasset(HSquirrelVM* sqvm, const SQInteger stackpos)

    :param HSquirrelVM* sqvm: the target vm
    :param SQInteger stackpos: stack position of the object
    :returns: The value of the object


.. _getConstants:

.. cpp:function:: SQTable* getConstants(HSquirrelVM* sqvm)

    :param HSquirrelVM* sqvm: the target vm
    :returns: the table of constants

    Pushes the constants table to the stack.

    Used to add global constants for scripts.

    .. code-block:: cpp

        getConstants(sqvm);

        pushstring(sqvm, "MY_CONSTANT");
        pushstring(sqvm, "MY_VALUE");
        newslot(sqvm, -3, false);

        removeFromStack(sqvm); // don't forget this!

.. _sq_getfunction:

.. cpp:function:: int sq_getfunction(HSquirrelVM* sqvm, const SQChar* name, SQObject* returnObj, const SQChar* signature)

    :param HSquirrelVM* sqvm: the target vm
    :param SQChar* name: the function name to search for
    :param SQObject* returnObj: reference to the object to hold the function object
    :param SQChar* signature:

    returns ``0`` if the function was found.

    .. code-block:: cpp

        SQObject functionobj {};
        int result = sq_getfunction(m_pSQVM->sqvm, funcname, &functionobj, 0);
        if (result != 0) // This func returns 0 on success for some reason
        {
            NS::log::squirrel_logger<context>()->error("Call was unable to find function with name '{}'. Is it global?", funcname);
            return SQRESULT_ERROR;
        }

.. _getentity:

.. cpp:function:: T* getentity(HSquirrelVM* sqvm, SQInteger iStackPos)

    :param HSquirrelVM* sqvm: The target vm
    :param SQInteger iStackPos: Stack position of the entity

.. _sq_getentityfrominstance:

.. cpp:function:: void* __sq_getentityfrominstance(CSquirrelVM* sqvm, SQObject* pInstance, char** ppEntityConstant)

    :param CSquirrelVM* sqvm: The target vm
    :param SQObject* pInstance: Instance holding an entity
    :param char** ppEntityConstant: Entity constant like :ref:`__sq_GetEntityConstant_CBaseEntity <sq-GetEntityConstant-CBaseEntity>`

.. _sq-GetEntityConstant-CBaseEntity:

.. cpp:function:: char** __sq_GetEntityConstant_CBaseEntity()

    There are entity constants for other types, but seemingly CBaseEntity's is the only one needed

.. _sq_getobject:

.. cpp:function:: __sq_getobject(HSquirrelVM* sqvm, SQInteger iStackPos, SQObject* obj)

    :param HSquirrelVM* sqvm: The target vm
    :param SQInteger iStackPos: Stack position of the object
    :param SQObject* obj: Pointer that will hold the object

.. _get:

.. cpp:function:: SQRESULT get(HSquirrelVM* sqvm, const SQInteger stackpos)

    :param HSquirrelVM* sqvm: the target vm
    :param SQInteger stackpos: stack position of the object
    :returns: an ``SQRESULT`` that indicates whether or not the access was successful.

Stack Infos
-----------

.. _sq_stackinfos:

.. cpp:function:: SQRESULT sq_stackinfos(HSquirrelVM* sqvm, int level, SQStackInfos& out)

    :param HSquirrelVM* sqvm: the target vm
    :param int level: stack depth of the info
    :param SQStackInfos& out: instance that will hold the information

.. _getcallingmod:

.. cpp:function:: Mod* getcallingmod(HSquirrelVM* sqvm, int depth = 0)

    :param HSquirrelVM* sqvm: the target vm
    :param int depth: stack depth of the origin mod
    :returns: Pointer to the Mod object at the stack depth

    .. note::

        Not available in `plugins <https://github.com/R2Northstar/NorthstarLauncher/blob/main/NorthstarDLL/plugins/plugin_abi.h>`_

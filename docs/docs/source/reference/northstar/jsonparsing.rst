JSON Parsing
============

Northstar provides two functions to handle JSON and tables:

- EncodeJSON() to parse a table into a JSON string.
- DecodeJSON() to parse json into a table.

Paired with :doc:`/reference/northstar/httprequests`, this allows you to send and retrieve JSON data from external sources.

JSON API
--------

.. warning::

	The JSON parser currently supports the following types for values: ``string``, ``integer``, ``float``, ``bool``, ``table``, and ``array``.

	Tables and arrays can only hold supported types. Unsupported types will be ignored. Keys can only be strings.

	The JSON parser currently does not support keys holding ``null`` values, and simply won't include them in decoded tables or encoded JSON strings.


.. _json_funcs_decodejson:


.. cpp:function:: table DecodeJSON( string json, bool fatalParseErrors = false )

	Converts a JSON string to a Squirrel table.
	
	**Parameters:**

	- ``string json`` - The JSON string to decode into a table.
	- ``[OPTIONAL] bool fatalParseErrors`` - Whether or not parsing errors should throw a fatal script error. Default to false.

	**Returns:** 
	
	- The table decoded from the JSON string on success, or an empty table ``{}`` on parse failure (if fatalParseErrors is false).


.. _json_funcs_encodejson:


.. cpp:function:: string EncodeJSON( table data )

	Converts a Squirrel table to a JSON string.

	**Parameters:**

	- ``table data`` - The table to encode to a JSON string.

	**Returns:** 
	
	- The JSON string parsed from the Squirrel table.


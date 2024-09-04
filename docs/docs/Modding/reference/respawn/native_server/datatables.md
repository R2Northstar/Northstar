DataTables
==========

.. cpp:function:: var GetDataTable( asset datatablepath )

  Gets the given datable asset

.. cpp:function:: var GetDataTableColumnByName( var datatable, string columnName )

  Finds the column in the datatable with the given name. -1 if none.

.. cpp:function:: int GetDataTableRowCount( var dtatatable )

  Returns the number of rows of a given datatable

.. cpp:function:: bool GetDatatableBool( var dtatable, int row, int column )

  Gets a bool from the given row/column of a datatable

.. cpp:function:: int GetDataTableInt( var datatable, int row, int column )

  Gets an integer from the given row/column of a datatable

.. cpp:function:: float GetDataTableFloat( var datatable, int row, int column )

  Gets a float from the given row/column of a datatable

.. cpp:function:: vector GetDataTableVector( var datatable, int row, int column )

  Gets a vector from the given row/column of a datatable

.. cpp:function:: string GetDataTableString( var datatable, int row, int column )

  Gets a string from the given row/column of a datatable

.. cpp:function:: asset GetDataTableAsset( var datatable, int row, int column )

  Gets an asset from the given row/column of a datatable

.. cpp:function:: bool GetDataTableRowMatchingBoolValue( var datatable, int column, bool value )

  Finds and returns the first row of the datatable for which the bool in the given column matches the given value. -1 if none.

.. cpp:function:: int GetDataTableRowMatchingIntValue( var datatable, int column, int value )

  Finds and returns the first row of the datatable for which the int in the given column matches the given value. -1 if none.

.. cpp:function:: int GetDataTableRowLessThanOrEqualToIntValue( var datatable, int column, int value )

  Finds and returns the first row of the datatable for which the int in the given column is less than or equal to the given value. -1 if none.

.. cpp:function:: int GetDataTableRowGreaterThanOrEqualToIntValue( var datatable, int column, int value )

  Finds and returns the first row of the datatable for which the int in the given column is greater than or equal to the given value. -1 if none.

.. cpp:function:: int GetDataTableRowMatchingFloatValue( var datatable, int column, float value )

  Finds and returns the first for of the datatable for which the float in the given colmn matches the given value. -1 if none.

.. cpp:function:: int GetDataTableRowLessThanOrEqualToFloatValue( var datatable, int column, float value )

  Finds and returns the first row of the datatable for which the float in the given column is less than or equal to the given value. -1 if none.

.. cpp:function:: int GetDataTableRowGreaterThanOrEqualToFloatValue( var datatable, int column, float value )

  Finds and returns the first row of the datatable for which the float in the given column is greater than or equal to the given value. -1 if none.

.. cpp:function:: int GetDataTableRowMatchingVectorValue( var datatable, int column, vector value )

  Finds and returns the first row of the datatable for which the vector in the given column matches the given value. -1 if none.

.. cpp:function:: int GetDataTableRowMatchingStringValue( var datatable, int column, string value )

  Finds and returns the first row of the datatable for which the string in the given column matches the given value. -1 if none.

.. cpp:function:: int GetDataTableRowMatchingAssetValue( car datatable, int column, asset value )

  Finds and returns the first row of the dtatable for which the asset in the given column matches the given value. -1 if none.

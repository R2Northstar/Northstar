# Safe I/O

If you want to store an extended amount of data in your mod it is not sustainable to only use ConVars as they are limited in space and easily reset. With Safe I/O you are able to write to one folder (`<profile>/saves/<mod directory name>`). In this folder you can store text files of any type (e.g. `.txt`, `.json`), it's also possible to use non text file formats (e.g. `.exe`) however you won't be able to run them on your PC. It also allows for sub-folders.


## Saving a file

To save a file you need the content you want to save as `strings-overview` , for this the `json_overview` functions can be useful if you want to store `table_overview` or `arrays_overview`.

To actually save the file you use:

!!! cpp-function "void NSSaveFile( string file, string data )"

    - `string file` The name of the file you want to store, this supports sub folders. Needs to be with the file type (e.g. `/TitanData/tone.txt`).

    - `string data` The saved data, this can be any valid String.

Alternatively if you want a faster way to store `table_overview` you can use:

!!! cpp-function "void NSSaveJSONFile(string file, table data)"


    - `string file` The name of the file you want to store, this supports sub folders. Doesn't have to be `.json` but will use the correct formatting for a `.json`.

    - `table data` The table that will be written to the file, this only supports the types specified in the `json_overview`.

## Loading a file

!!! cpp-function "void function NSLoadFile( string file, void functionref( string ) onSuccess, void functionref() onFailure = null )"

    - `string file` This is the name of the file you want to load, it has the same formating as in `NSSaveFile`.

    - `void functionref( string ) onSuccess` The function that gets execued when the file is successfully loaded, the parameter `string` is the content of the loaded file.

    - `void functionref() onFailure = null` The function that gets execued when the loading was NOT successful, by default the function is just `null`.

    !!! note
        If you are having trouble with functionrefs you can read up on them here: :ref:`functionref_overview`

You can also get all saved file:

!!! cpp-function "array<string> function NSGetAllFiles( string path = "" )"

    - `string path = "": Gets all files in a specified path, by default its just `<profile>/saves/<mod directory name>`.

    Returns: An array with all file names in the specified path.

## Deleting a file

!!! cpp-function "void NSDeleteFile(string file)"

    `string file` This is the name of the file you want to check exsits, it has the same formating as in `NSSaveFile`.


## File checks

!!! cpp-function "bool NSDoesFileExist(string file)"

    `string file` This is the name of the file you want to check exsits, it has the same formating as in `NSSaveFile`.

    Returns: `true` if the file was found, otherwise it returns `false`.


!!! cpp-function "int NSGetFileSize(string file)"

    `string file`: This is the name of the file you want to get the file size from.

    Returns: KB size of the specified file.

    !!! warning
        This fucntion will raise an error when the file doesnt exist.


!!! cpp-function "bool NSIsFolder(string path)"

    `string file` This is the path you want to check.

    Returns: `true` if the path is a folder, otherwise it returns `false`.

!!! cpp-function "int NSGetTotalSpaceRemaining()"

    Returns: Amount of KB you have left to write on.

    !!! note
        The max size of data you can store is `50MB` per mod. Can be overwritten with `-maxfoldersize BYTES` in the launch args.

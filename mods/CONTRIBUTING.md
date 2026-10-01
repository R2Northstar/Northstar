# Contributing
> NOTE: This is the first iteration of this file. You're welcome to pull request changes

### Contents
- [Making issues](#Making-issues)
- [Making pull requests](#Making-pull-requests)
- [Formatting code](#Formatting-code)

## Making issues
When creating issues, whether to track a bug or suggest a feature, please try to follow this set of rules:
1. When filing a bug report issue, please attach a log file ( Located in `R2Northstar/logs/` ).
2. **Short, consise.** No-one wants to read an essay on why x should be added.
3. When applicable attach a short video / screen shots to better convey what the issue is about.

## Making pull requests
When creating a pull request please follow this set of rules:
1. **1 Fix/Feature should equal to 1 Pull Request.** The more you do in 1 PR the longer it'll take to merge.
2. Mark your Pull Request as draft if it isnt finished just yet.
3. Properly format your code. As we currently don't have a formatter we're very lax on this. That doesn't mean you don't have to try to format your code.
4. **Mention how to test your changes / add a test mod to make it easier to test**

## Formatting code
A basic set of rules you should follow when creating a Pull Request

### Comment your code
- If you're adding a new file you should add a doc comment noting what the file does and its origin
  ```cpp
  ///-----------------------------------------------------------------------------
  /// Origin: Northstar
  /// Purpose: handles server-side rui
  ///-----------------------------------------------------------------------------
  ```
  Alternative to `Origin: Northstar` would be `Origin: Respawn`
- Each function should have a header doc comment
  ```cpp
  ///-----------------------------------------------------------------------------
  /// Sends a string message to player
  /// Returns true if it succeeded
  ///-----------------------------------------------------------------------------
  bool function NSSendInfoMessageToPlayer( entity player, string text )
  ```
### Functions
- Functions should have spaces in the parentheses
  ```cpp
  bool function NSSendInfoMessageToPlayer( entity player, string text )
  ```
- If a function need to be threaded off using `thread` it should have a `_Threaded` suffix

### File
- Files should use tabs for indentation

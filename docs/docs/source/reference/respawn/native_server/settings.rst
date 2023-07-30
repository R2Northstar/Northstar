Settings
========

Player Settings
---------------

.. cpp:function:: var GetPlayerSettingsFieldForClassName( string className, string fieldName, var unknown = 0 )

  Returns the value for the requested field from the corresponding .set file.

.. cpp:function:: float GetPlayerSettingsFieldForClassName_Health( string className )

  Returns the value for the default health field from the corresponding .set file.

.. cpp:function:: float GetPlayerSettingsFieldForClassName_HealthShield( string className )

  Returns the value for the default health shield field from the corresponding .set file.

.. cpp:function:: float GetPlayerSettingsFieldForClassName_HealthDoomed( string className )

  Returns the value for the default health doomed field from the corresponding .set file.

.. cpp:function:: float GetPlayerSettingsFieldForClassName_HealthPerSegment( string className )

.. cpp:function:: table GetSettingsForPlayer_DodgeTable( entity player )

  Returns a table with all the dodge related active settings for a given player

.. cpp:function:: int PlayerSettingsNameToIndex( string className )

.. cpp:function:: string PlayerSettingsIndexToName( int settingsNum )

.. cpp:function:: asset GetPlayerSettingsAssetForClassName( string className, fieldName )

  Returns the value for the requested field from the corresponding .set file.

.. cpp:function:: var Dev_GetPlayerSettingByKeyField_Global( string a, string b )

.. cpp:function:: var Dev_GetPlayerSettingAssetByKeyField_Global( string a, string b )

Weapon Settings
---------------

.. cpp:function:: var GetWeaponInfoFileKeyField_Global( string a, string b )

.. cpp:function:: var GetWeaponInfoFileKeyField_WithMods_Global( string weaponName, array<string> modArray, string key )

  Given a weapon name, a list of weapon mods to apply, and key, returns the value of that field in that weapons info file.

.. cpp:function:: array<string> GetWeaponMods_Global( string weaponName )

  Given a weapon name, returns a list of the mods available on that weapon

.. cpp:function:: void SetBodyGroupsForWeaponConfig( entity ent, string weaponName, array<string> modArray )

.. cpp:function:: asset GetWeaponInfoFileKeyFieldAsset_Global( string weaponName, string key )

  Given a weaon name and key, resolves a string key to its value in that weapons info file. assumes no mods set.

.. cpp:function:: asset GetWeaponInfoFileKeyFieldAsset_WithMods_Global( string weaponName, array<string> modArray, string key )

  Given a weapon name, a list of weapon mods to apply and key, returns the value of that field in that weapons info file.

.. _ai-settings:

AI Settings
-----------

.. cpp:function:: int GetAISettingHullType( string aiSettingsName )

.. cpp:function:: var Dev_GetAISettingAssetByKeyField_Global( string a, string b )

.. cpp:function:: var Dev_GetAISettingByKeyField_Global( string a, string b )

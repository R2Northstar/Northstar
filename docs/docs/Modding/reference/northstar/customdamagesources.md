# Custom Damage Source IDs

Custom damage source IDs can be used to create new damage source IDs for modded weapons, abilities, damage, etc.

They can only be registered server-side and cannot modify existing damage source IDs. Clients pre-1.9.4 will not see the custom damage sources in the obituary.

To add a single damage source ID, use:

!!! cpp-function "void RegisterWeaponDamageSource( string weaponRef, string damageSourceName )"

To add multiple damage source IDs, use

!!! cpp-function "void RegisterWeaponDamageSources( table< string, string > newValueTable )"

The first string parameter is the in-code weapon name while the latter is the name displayed in the obituary.

Damage source IDs should be added in `"After"` server callbacks.

For example, we can call the methods from a function in `damage_source_example.nut`:

```squirrel
global function SimpleSourceInit

void function SimpleSourceInit()
{
    // Server-side code

    // Register a single damage source ID
    RegisterWeaponDamageSource( "mp_weapon_minigun", "Minigun" )

    // Register multiple damage source IDs
    RegisterWeaponDamageSources(
        {
            mp_titanweapon_barrage_core_launcher = "Barrage Core",
            mp_titanweapon_grenade_launcher = "Grenade Launcher"
        }
    )
}
```

Then call the function as an `"After"` server callback in the `mod.json`:

```javascript
{
    "Scripts": [
        {
            "Path": "damage_source_example.nut",
            "RunOn": "SERVER && MP",
            "ServerCallback": {
                "After": "SimpleSourceInit"
            }
        },
    ]
}
```

Now, these damage source IDs can be referenced in script like so:

```squirrel
eDamageSourceId.mp_weapon_minigun
eDamageSourceId.mp_titanweapon_barrage_core_launcher
eDamageSourceId.mp_titanweapon_grenade_launcher
```

and their corresponding precached weapons (if applicable) will automatically use their custom damage source IDs.

# shamey-bathing

A free, open-source RedM script for bathing indoors and outdoors

## Credit
- The tub feature is an enhancement to [xK3LY/redm_bathing](https://github.com/xK3LY/redm_bathing). All original credit to them! The reverse-engineered bathing minigame is still a mystery to me.

## Features
- Tub bathing with cutscene
- "Deluxe Assistants" for NPC-assisted tub bathing (multiple options of NPCs of multiple genders)
- Changeable camera
- Outdoor bathing option using a soap item (with scrub animations)
- HUD icon to show dirtiness level
- "Flies" particle effect when the character gets too dirty
- Configurable ("Deluxe Assistant" NPCs, buttons, prompts, animations, soap items, flies threshold)
- Organized & documented
- Performant

## Known Issues
- For tub bathing, you have to hold down the scrub button for the entire bath.

## Requirements
- VORP Framework
- [jo_libs](https://github.com/Jump-On-Studios/RedM-jo_libs)
- [shamey-core](https://github.com/ShameyWinehouse/shamey-core) (for particle effects)

## Database Changes
This script assumes the presence of a `character_statuses` database table, which I originally created for my Addiction script.

If you use my Addiction script and already have a `character_statuses` database table, then you only need to run the `2-bathing-table.sql` SQL script in your database (to add the "cleanliness" column).

If you *don't* use my Addiction script, then you'll need to run the `1-character-statuses.sql` SQL script (to first create the table) and *then* `2-bathing-table.sql`.

## License & Support
This software was formerly proprietary to Rainbow Railroad Roleplay, but I am now releasing it free and open-source under GNU GPLv3. I cannot provide any support.
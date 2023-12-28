# vanilla-luab
Source code for agent logic.

Very early in development. If you want to test or something:
1. Create a mage, warrior (only human or orc atm), priest, rogue. The only 4 classes with any logic implemented.
2. Do not use gm accounts or characters you actually want to play yourself.
3. Log into each created character, get through the cutscene and log out. Should show their location on login screen now.
4. Open _test_.lua with a plain text editor like notepad++ and edit table t_agentInfo at the very beginning of the file. Change the character names to ones you created matching each class. Name may be case sensitive, never checked.
5. If your mangosd was running while you made the edits use command ".luab reset" to reload the file.
6. ".luab addparty Hive" to spawn characters. They should teleport to you. Party name is case sensitive.
7. ".luab groupall" to add them to your group.
8. Go to Ragefire and try it out. The only instance that's implemented atm.
9. Use .replenish if you get bored of waiting on drinking.
10. ".luab removeall" will get rid of them.

The bots are generally meant to be hands off and your only control over them is to tell them to attack by right clicking.

### Pulling:
- Need to have a tank. Right click an enemy inside an instance. So long as its not in combat your warrior tank will try to pull it. You can interrupt the pull by unselecting the enemy if you do it before combat begins.
- After firing the tank will run back a bit to pull it away. If any enemies are detected as using ranged attacks it will pull much farther.
- Due to current implementation limitations, when dungeon forks and multiple directions are available the far pull for ranged enemies may or may not be limited in distance if done near the fork.
- Pull direction will generally run using the direction from enemy to you when you first initiated the pull. Calculated once at the start of pull.
- Tank will always face the enemy to match what it considers "forward" direction based on your initial position with regards to the enemy. This direction is only calculated once at the start of combat.
- You can face pull enemies yourself if you don't want to wait for the process if the pull isn't dangerous. Tank will hopefully be able to take it from you.
- Other bots keep following you until pulled.

Bots will generally watch out for their threat and stop attacking if they come close to taking over from tank so they take some time to engage after the pull to let tank build a bit of a lead.

### CC:
- Currently just mage polymorph. Will select the highest health target that can be polymorphed and keep it CC'd until its dead, then pick a new one. Can sometimes be dangerous as enemies don't gain threat while polymorphed and so the mage might be on the top of the list as the only "player" to have any threat.
- Other bots won't attack polymorphed enemy until there's no other option.

Bots might not interrupt their food/water even if you start combat so keep in mind.

Don't use tank/healer bots outside of dungeons, not really implemented, and other bots will ignore the tank anyway which is intentional.

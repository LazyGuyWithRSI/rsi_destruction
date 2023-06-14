# RSI_DESTRUCTION

## Build-style destruction for GZDoom! *NO scripting required!*
### (TODO) [Video demonstration and instructions]()
### (TODO) [Demo WAD]()
---

Aren't those Build engine games cool with all those explosions and walls that get holes blown in them?
Why is that so freaking hard in doom, even with the GZDoom engine?

Well now it's easier than ever. (still a bit of a pain due to engine limitations, but hey). Mappers can create more interactive, explode-y levels with relative ease.

Built for use with [Nobody Told Me About id](https://github.com/LazyGuyWithRSI/NTMAi) (though not required)


---
---
### Philosophy Technical stuff

At its core this project was about overcoming the limitations of GZdoom engine (and editors), specifically in comparison to the Build engine. Build is, technically speaking, a steaming pile of code, but with some cool features that have a place in doom as well.

First and formost was mapping. I wanted to make destruction easy for a mapper, like it is in Build. I had to resort to some odd choices in UDB to allow this (like using the `health` multiplier as a timer). It was also important for me to allow the mapper to setup what the map should look like AFTER the desctruction, and somehow fill in the holes when the level loads.

Seems easy at first, just lower the ceilings like Build, and move them up fast when it's "destroyed". Build can do this fine, even with slopes. GZDoom on the other hand cannot change the angle of slopes after they are created. If you lower the ceilings to cover the gaps, you get z-fighting between the bottom and top textures where they overlap.

My solution to this is to set the mid texture to be identical to the top texture (copying over the offset and scale). Then when the destruction happens, clear the mid texture, instantly lower the ceiling, then raise it really fast (gives the same sort of look as the Build engine).

In addition to easily setting up destruction, I added some actors that facilitate extra behavior like explosions, delayed explosions, and triggering of destruction with `actions`.


---
## **How To**

Basic steps (in Ultimate Doom Builder):
1. setup how you want your sectors to look AFTER the destruction (like in Build)
2. edit the sectors you want to be destroyed and go to `Custom`
3. refer to [Custom Properties](#custom-properties) section to add desired behavior

> For easy explosions, place an `RSI_ExplosionSpot` and make its tag match the `user_dest_group` (you can delay the explosion by increasing the `Health` property. This is how many ticks to wait).


### Custom Properties

| Name | value | Description |
| ----- | ----- | ----- |
| user_dest_group | `int` | defines what destruction a sector is a part of |
| user_dest_type | `1` or `2` | `1` means it is a wall, `2` means it is a floor
| user_dest_start_height | `int` | *FLOOR ONLY* determines what height the floor should start at (pre-destruction)
| healthfloor / healthceiling | `int` | (*built-in*) determines health of floor and ceiling. When part of an rsi_destruction sector, can only take damage from radii. [More Information](https://forum.zdoom.org/viewtopic.php?f=59&t=62420)
| healthfloorgroup / healthceilinggroup | `int` | (*built-in*) a way to sync health across sectors. [More Information](https://forum.zdoom.org/viewtopic.php?f=59&t=62420)


> Regarding the build-in sector health stuff: When a sector `explodable` (has a `user_dest_type`), I do 2 things:
> 
> 1. it can only take radius damage (explosions)
> 2. that damage must be enough to one-shot it, otherwise it does nothing.
> 
> this means you cannot "chip away" at a destructable sector, you must deliver enough damage in one attack. This was to manage the damge-falloff from splash damage, enabling the mapper to determine just how on-target they need to be to trigger the destruction. (There is another way to trigger destructions as well)


### Custom `Actors`
| Name | Type | Description |
| ----- | ----- | ----- |
| RSI_ExplosionSpot | 26002 | Creates an explosion after a delay. `Tag` must match the destruction's `user_dest_group`. `Health` determines delay (in `ticks`). Will also trigger its `Action`. Can be triggered by an `Activate Thing` action.
| RSI_TriggerSpot | 26003 | When activated, triggers the desctruction of the sector it is in (it really just deals damage to the sector with a tiny silent explosion), and also triggers its `Action` |
| WallDecal | 27001 | A sprite for cracks / show a wall can be destroyed. Destruction will remove any decals whose `Tag` matches the `user_dest_group`. (*Not to be confused with Zdoom `Decal`*)

---
---
### Credits
- Explosion graphics: (one of these, not sure which so they all get credit) 3D Realms, Banjo Software, Lobotomy Software, id Software
- ExplosionFX actor definitions: Kinsie's Metadoom Props

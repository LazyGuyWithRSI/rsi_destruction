# RSI_DESTRUCTION

## Build-style destruction for GZDoom! *NO scripting required!*
---
### [Video demonstration and instructions]()
### [Demo WAD]()
---

Aren't those Build engine games cool with all those explosions and walls that get holes blown in them?
Why is that so freaking hard in doom, even with the GZDoom engine?

Well now it's easier than ever. (still a bit of a pain due to engine limitations, but hey)



---
## **Documentation**

Basic steps (in Ultimate Doom Builder):
1. setup how you want your sectors to look AFTER the destruction (like in Build)
2. select the sectors you want to be destroyed and go to `Custom`
3. refer to [Custom Properties] section to add desired behavior

> For easy explosions, place an `RSI_ExplosionSpot` and make its tag match the `user_dest_group` (you can delay the explosion by increasing the `Health` property. This is how many ticks to wait).



### Custom Properties:
| Name | value | Description |
| ----- | ----- | ----- |
| user_dest_group | `int` | defines what explosion a sector is a part of |
| user_dest_type | `1` or `2` | `1` means it is a wall, `2` means it is a floor
| user_dest_start_height | `int` | *FLOOR ONLY* determines what height the floor should start at (pre-destruction)
| healthfloor / healthceiling | `int` | (*built-in*) determines health of floor and ceiling. When part of an rsi_destruction sector, can only take damage from radii. [More Information](https://forum.zdoom.org/viewtopic.php?f=59&t=62420)
| healthfloorgroup / healthceilinggroup | `int` | a way to sync health across sectors. [More Information](https://forum.zdoom.org/viewtopic.php?f=59&t=62420)

> Regarding the build-in sector health stuff: When a sector `explodable` (has a `user_dest_type`), I do 2 things:
> 
> 1. it can only take radius damage (explosions)
> 2. that damage must be enough to one-shot it, otherwise it does nothing.
> 
> this means you cannot "chip away" at a destructable sector, you must deliver enough damage in one attack. This was to manage the damge-falloff from splash damage, enabling the mapper to determine just how on-target they need to be to trigger the destruction. (There is another way to trigger destructions as well)

class RSI_TriggerSpot : Actor
{
	Default {
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		-NODAMAGE
		+INVULNERABLE
		RenderStyle "None";
	}
	
	override void Activate(Actor activator) {
		A_Explode(2047483646, 1, 0, false);
		A_CallSpecial(special, args[0], args[1], args[2], args[3], args[4]);
		Destroy();
		//super.Activate(activator);
	}
}

class RSI_ExplosionSpot : MapSpot
{
	int elapsed;
	bool started;
	bool firstTick; // gross hack so Tick() doesn't do anything before BeginPlay()

	Default {
		health 1;
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		-NODAMAGE
		+INVULNERABLE
		RenderStyle "None";
	}
	
	override void Tick() {
		if (started && !firstTick) {
			elapsed += 1;
			if (elapsed > SpawnHealth()) {
				Destroy();
			}
		}
		super.Tick();
	}
	
	override void BeginPlay() {
		started = false;
		elapsed = 0;
		firstTick = false;
		super.BeginPlay();
	}
	
	override void Activate(Actor activator) {
		if (!started) {
			started = true;
		}
		
		super.Activate(activator);
	}

	override void OnDestroy() {
		console.printf("health was "..SpawnHealth()..", elapsed was "..elapsed);
		Spawn("NTM_FXExplosion", Vec3Offset(0, 0, 0));
		A_CallSpecial(special, args[0], args[1], args[2], args[3], args[4]);
		super.OnDestroy();
	}
}

class NTM_Destructables : EventHandler {
	Dictionary dictOriginalSectorHeights;
	
	override void WorldLoaded(WorldEvent e) {
	
		dictOriginalSectorHeights = Dictionary.Create();
		
		int BYTE = 4;
		// find all desctructable sectors
		console.printf("total sectors: "..level.Sectors);
		for (int i = 0; i < level.Sectors.size(); i++) {
			Sector sector = level.Sectors[i];
			int destType = sector.GetUDMFInt("user_dest_type");
			if (destType > 0) {// destructable
				int floorHeight = sector.CenterFloor();
				
				if (destType == 2) {
					int startHeight = sector.GetUDMFInt("user_dest_start_height");
					dictOriginalSectorHeights.Insert(""..sector.Index(), ""..floorHeight);
					sector.MoveFloor(startHeight - floorHeight, sector.floorplane.PointToDist(sector.centerspot, startHeight), 0, 1, false, true);
					//level.CreateFloor(sector, Floor.floorRaiseByValue, null, 10, startHeight - floorHeight);
				}
				else { // dest type == 1
					int ceilingHeight = sector.CenterCeiling();
					dictOriginalSectorHeights.Insert(""..sector.Index(), ""..ceilingHeight);
					//sector.MoveCeiling(1000, sector.ceilingplane.PointToDist(sector.centerspot, floorHeight), 0, -1, false);
					
					// set midtexture to repeat top texture
					for (int j = 0; j < sector.lines.size(); j++) {
						// find the 'open' sides with no mid texture
						Line line = sector.lines[j];
						Side side = line.sidedef[0];
						if (!side.getTexture(Side.Mid)) {
							
							line.Flags |= Line.ML_BLOCKEVERYTHING;
							side.Flags |= Side.WALLF_WRAP_MIDTEX;
							
							side.setTexture(Side.Mid, side.getTexture(Side.Top));
							
							side.setTextureXOffset(Side.Mid, side.getTextureXOffset(Side.Top));
							side.setTextureYOffset(Side.Mid, side.getTextureYOffset(Side.Top));
							
							side.setTextureXScale(Side.Mid, side.getTextureXScale(Side.Top));
							side.setTextureYScale(Side.Mid, side.getTextureYScale(Side.Top));
						}
					}
				}
			}
		}
	}
	
	override void WorldSectorDamaged(WorldEvent e) {
		int destType = e.DamageSector.GetUDMFInt("user_dest_type");
		int destGroup = e.DamageSector.GetUDMFInt("user_dest_group");
		if (destType > 0) {// destructable
			if (!e.DamageIsRadius)
			{
				e.newDamage = 0;
				return;
			}
			
			console.printf("hit by radius! Dealing "..e.newDamage.." damage. Health: "..e.DamageSector.healthfloor);
			
			if ((e.DamageSector.healthfloor > 0 && e.DamageSector.healthfloor - e.newDamage < 0) || (e.DamageSector.healthceiling > 0 && e.DamageSector.healthceiling - e.newDamage < 0)) {
			
				for (int i = 0; i < level.Sectors.size(); i++) {
					Sector sector = level.Sectors[i];
					//if (sector.healthfloorgroup != e.DamageSector.healthfloorgroup) continue;
					if (sector.GetUDMFInt("user_dest_group") != destGroup) continue;
					int secDestType = sector.GetUDMFInt("user_dest_type");
					
					if (secDestType == 2) {
					
						// move to original height
						int originalHeight = dictOriginalSectorHeights.At(""..sector.Index()).ToInt(10);
						//console.printf("move floor to desired height of "..originalHeight);
						uint moveAmount = originalHeight - sector.CenterFloor();
						//sector.MoveFloor(moveAmount, sector.floorplane.PointToDist(sector.centerspot, originalHeight), 0, -1, false, false);
						level.CreateFloor(sector, Floor.floorLowerByValue, null, 25, sector.CenterFloor() - originalHeight);
					}
					else if (secDestType == 1) {
						
						// move to original height
						int originalHeight = dictOriginalSectorHeights.At(""..sector.Index()).ToInt(10);
						//console.printf("move height to desired height of "..originalHeight);
						//console.printf("Raw dict value: "..dictOriginalSectorHeights.At(""..e.DamageSector.Index()));
						
						uint moveAmount = originalHeight - sector.CenterFloor();
						
						//sector.MoveCeiling(1000, sector.ceilingplane.PointToDist(sector.centerspot, originalHeight), 0, 1, false);
						
						int floorHeight = sector.CenterFloor();
						sector.MoveCeiling(1000, sector.ceilingplane.PointToDist(sector.centerspot, floorHeight - 10), 0, -1, false);
						level.CreateCeiling(sector, Ceiling.ceilRaiseByValue, null, 50, 50, moveAmount);
						
						// set midtexture to repeat top texture
						for (int j = 0; j < sector.lines.size(); j++) {
							// find the 'open' sides with no mid texture
							Line line = sector.lines[j];
							Side side = line.sidedef[0];
							//console.printf("side mid: "..side.getTexture(Side.Mid));
							if (side.getTexture(Side.Mid) == side.getTexture(Side.Top)) {
								line.Flags &= ~Line.ML_BLOCKEVERYTHING;
								textureid tex;
								tex.SetNull();
								side.setTexture(Side.Mid, tex);
							}
						}
						
						// get all actors tagged the same as the dest_group and remove them (they are decals)
						ActorIterator actorIter = level.CreateActorIterator(destGroup);
						Actor actor;
						Array<Actor> actorsToDelete;
						while (actor = actorIter.Next()) {
							console.printf("actor class: "..actor.GetClassName());
							
							if (actor is "RSI_ExplosionSpot") actor.Activate(actor);
							else actorsToDelete.Push(actor);
						}
						
						for (int a = 0; a < actorsToDelete.size(); a++) {
							actorsToDelete[a].Destroy();
						}
						
						/*
						Actor actor = sector.thinglist;
						while (actor) {
							console.printf("actor tag: "..actor.GetTag("0").ToInt(10));
							if (false) {
								console.printf("decal found, destroying");
								actor.Destroy();
							}
							actor = actor.snext;
						}*/
					}
				}
			}
			else { e.NewDamage = 0; }
		}
	}
}
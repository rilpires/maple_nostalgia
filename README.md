# maple_nostalgia
A "2.5D" old Maple Story prototype using Godot (v3.2.3)


<img src="https://i.imgur.com/W8adRqc.png">

This project was more "Searching-for-3D-best-pratices-using-Godot-engine" than anything.
The idea came off when a friend of mine [@vgarciasc](https://github.com/vgarciasc) was praticing 3D for the first time on Blender.
I'm an old user of Godot Engine but never touched the 3D part. So for a few weeks in our free time he was doing 3D models and I was scripting stuffs and eventually made some 3D models too.

There is not much anything to play with. You can... 
- Move around (arrows)
- Jump (Z)
- Attack(X) 

I think this project is more valuable as a proof-of-concept of some basic mechanics and a possible organization of a project that would use such workflow. 

## About project organization

Some scripts may seen 'over-engineered'. That is because I made them in a way that it would be scalable for a game like the original Maple Story, 
that is, huge variety of modular characters, monsters, scenarios, abilities, etc

For example, humanoid characters and enemies both inherits from the same class "character", that has generic functions useful for both entities. 
Also, only humanoid characters are modular in a way that it equips different weapons and it alters it default animations. By the architecture presented, creating a new "Prefab" for a new monster would only be necessaire to create a new inherited scene from "Monster" and import a ".gltf" from Blender that has "Standing","Walking","Knockbacked" and "Dying" animations.

## to-do
- Scenario assets (there is a bunch from kerning city) was abandoned when trying to fit it into a 'tiled' approach. So we gotta organize all these materials that keep coming

[Maple Story is a trademark of NEXON KOREA CORPORATION](https://maplestory.nexon.net/) <div style="font-size:10px">please nexon do not sue me and bring pre big-bang maple story also<div>

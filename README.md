# FixAnimationForModifiedCharacterBoneStructure
Created by polill00, polill00#5018

Fixes an animation for a modified bone structure.

## Description
    Generates a keyframe sequence that looks identical to another keyframe sequence for a modified bone structure.

    It does this by calculating the relative position of the part in any given pose in the first model, then calculating the bone transformation.


##Rules
	All parts in each rig must have unique names
	All parts in the old rig must share a name and size with a part in the new rig.

	The root parts must be named "HumanoidRootPart"
	The root of all bones must be the root part
	
##Directions:
	* Update all the config variables in the 'FixAnimationBoneStructure' file
		* OldModel is the rig with the old bone structure
		* NewModel is the rig with the changed bone structure
		* OldKeyframeSequenceToFix is the keyframesequence you want updated to work with the NewModel
	* Press Run/Play
	* Copy the generated keyframe sequence
	* Press Stop
	* Paste the generated keyframe sequence
## 
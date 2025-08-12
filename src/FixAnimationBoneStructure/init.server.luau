--[[ Originally put together by polill00

	Description
		Generates a keyframe sequence that looks identical to another keyframe sequence for a modified bone structure

	Rules
		All parts in the rig must have unique names
		All parts in the old rig must have a unique part in the new rig that shares it's name and vise versa
		The root part must be named "HumanoidRootPart"
		The root of all bones must be the root part
	
	Directions:
		Update all the config variables
			OldModel is the rig with the old bone structure
			NewModel is the rig with the changed bone structure
			OldKeyframeSequenceToFix is the keyframesequence you want updated to work with the NewModel
		Press Run/Play
		Copy the generated keyframe sequence
		Press Stop
		Paste the generated keyframe sequence
--]]

--// Config
local OldModel = game.Workspace:FindFirstChild("Old Bones") -- | Set this to the rig with the old bone structure
local NewModel = game.Workspace:FindFirstChild("New Bones") --| Set this to the rig with the new bone structure

local OldKeyframeSequenceToFix = game.Workspace:FindFirstChild("BrokenKFS") -- | Set this to the KeyframeSequence you want to fix
--\\

--// Dependencies
local GetLinkedModelMaps = require(script.GetLinkedModelMaps)
local FixPose = require(script.FixPose)
--\\

print("[Fix Keyframe Sequence] Attempting to link models")

local _, NewModelMap = GetLinkedModelMaps(OldModel, NewModel)

print("[Fix Keyframe Sequence] Fixing the KeyframeSequence")

--| Generating the new keyframe sequence
local FixedKeyframeSequence = Instance.new("KeyframeSequence")
FixedKeyframeSequence.Name = "Fixed " .. OldKeyframeSequenceToFix.Name
FixedKeyframeSequence.Loop = OldKeyframeSequenceToFix.Loop
FixedKeyframeSequence.Priority = OldKeyframeSequenceToFix.Priority

--| Adding Each Keyframe
for i, OldKeyframe in ipairs(OldKeyframeSequenceToFix:GetChildren()) do
	if not OldKeyframe:IsA("Keyframe") then
		continue
	end
	--| Generating a new keyframe
	local FixedKeyframe = Instance.new("Keyframe")
	FixedKeyframe.Name = OldKeyframe.Name
	FixedKeyframe.Time = OldKeyframe.Time

	--| Generating the fixed keyframe poses

	local FixedPose = FixPose(OldKeyframe.HumanoidRootPart, NewModelMap)
	FixedPose.Parent = FixedKeyframe

	if i % 10 == 0 then
		print("[Fix Keyframe Sequence] Fixed " .. tostring(i) .. " keyframes")
		task.wait()
	end

	for _, child in ipairs(OldKeyframe:GetChildren()) do
		if child:IsA("KeyframeMarker") then
			local NewKFMarker = Instance.new("KeyframeMarker")
			NewKFMarker.Name = child.Name
			NewKFMarker.Value = child.Value
			NewKFMarker.Parent = FixedKeyframe
		end
	end

	FixedKeyframe.Parent = FixedKeyframeSequence
end

FixedKeyframeSequence.Parent = game.Workspace

print(
	"[Fix Keyframe Sequence] KeyframeSequence Successfully Fixed, Fetch it under workspace under the name '"
		.. FixedKeyframeSequence.Name
		.. "'"
)

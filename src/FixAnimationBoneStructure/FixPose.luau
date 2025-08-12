--[[ Fix Pose - Put together by polill00

Fixes a pose provided a oldpose, and a linked new model map.


--]]

--// Private Functions
local CopyPoseInfo = function(Pose, PoseCopy)
	PoseCopy.Name = Pose.Name
	PoseCopy.CFrame = Pose.CFrame
	PoseCopy.EasingDirection = Pose.EasingDirection
	PoseCopy.EasingStyle = Pose.EasingStyle
	PoseCopy.Weight = Pose.Weight
end

local GeneratePoseRoot = function(Pose)
	local PoseCopy = Instance.new("Pose")
	CopyPoseInfo(Pose, PoseCopy)

	--| Why does this need to be here? Idk, I couldn't find anything about it online. It exists in the sequences I was working with.
	--| Let me know if there is a purpose and what it is, I'm curious.
	local NullValue = Instance.new("IntValue")
	NullValue.Name = "Null"
	NullValue.Parent = PoseCopy
	NullValue.Value = 0

	return PoseCopy
end

local CheckIfPartIsRelevant = function(RelevantParts, Part)
	for _, PartName in ipairs(RelevantParts) do
		if Part.Name == PartName then
			return true
		end
	end

	return false
end

local GeneratePoseStructure
GeneratePoseStructure = function(RelevantParts, ModelMapNode, ParentPose)
	--|| Add node
	if CheckIfPartIsRelevant(RelevantParts, ModelMapNode.Value) then
		local Pose = Instance.new("Pose")
		Pose.Parent = ParentPose
		Pose.Name = ModelMapNode.Value.Name

		--|| Add node for it's children
		for _, Child in pairs(ModelMapNode.Children) do
			GeneratePoseStructure(RelevantParts, Child, Pose)
		end
	else -- Exclude it from the structure
		return
	end
end

local FixPoseRecursive
FixPoseRecursive = function(OldPose, NewPose, NewModelNode, NewParentHRPOffset)
	NewParentHRPOffset = NewParentHRPOffset and NewParentHRPOffset or CFrame.new()

	local OldModelNode = NewModelNode.Link

	--| Get CFrame in HRP's Space of the Object in the OldPose

	local TotalOffset = CFrame.new()
	local Current = OldModelNode
	local PathToOldPose = {}

	--| Head up through the ancestors calculating total offset as you go
	while Current.Parent do
		table.insert(PathToOldPose, 1, Current)
		Current = Current.Parent
	end

	for _, OldNode in ipairs(PathToOldPose) do -- like lower torso, upper torso, head
		local Bone = OldNode.Motor6D
		local OldPoseLink = OldPose:FindFirstChild(OldNode.Value.Name, true)

		TotalOffset = TotalOffset * Bone.C0 * OldPoseLink.CFrame * Bone.C1:Inverse()
	end

	--| Find HRP Offset needed for the NewPose Object to equal the old pose HRP offset

	local OffsetDifference = (NewParentHRPOffset * NewModelNode.Motor6D.C0):Inverse()
		* TotalOffset
		* NewModelNode.Motor6D.C1

	--| Set the new pose's value
	CopyPoseInfo(OldPose:FindFirstChild(NewPose.Name, true), NewPose)
	NewPose.CFrame = OffsetDifference

	--| Handle Children
	for _, Child in ipairs(NewPose:GetChildren()) do
		FixPoseRecursive(OldPose, Child, NewModelNode.Children[Child.Name], TotalOffset)
	end
end
--\\

--// Main Function
local FixPose = function(OldPose, NewModelMap)
	--| Generate RootPose
	local NewPose = GeneratePoseRoot(OldPose)

	--| Get list of parts in the bone
	local RelevantParts = {}

	for _, Object in ipairs(OldPose:GetDescendants()) do
		if Object:IsA("Pose") then
			table.insert(RelevantParts, Object.Name)
		end
	end

	--| Generate Pose Structure
	for _, Child in pairs(NewModelMap.Children) do
		GeneratePoseStructure(RelevantParts, Child, NewPose)
	end

	--| Fix Poses
	for _, Child in ipairs(NewPose:GetChildren()) do
		if Child:IsA("Pose") then
			FixPoseRecursive(OldPose, Child, NewModelMap.Children[Child.Name])
		end
	end

	return NewPose
end
--\\

return FixPose

--[[ Made by polill00

Creates linked tree structures based on the bones of the given models

--]]

--// Dependencies
local NodeObject = require(script.NodeObject)
--\\

--|| <><><> Create Model Map <><><> ||--

--| Helper Functions
local FindConnectedBones = function(Model, Part0)
	local ConnectedBones = {}

	for _, Descendant in ipairs(Model:GetDescendants()) do
		if Descendant:IsA("Motor6D") and Descendant.Part0 == Part0 then
			table.insert(ConnectedBones, Descendant)
		end
	end

	return ConnectedBones
end

local GetModelMapRecursive
GetModelMapRecursive = function(Model, ParentNode)
	--// Looking for objcets with bones connected to parent1
	local Part0 = ParentNode.Value
	local Bones = FindConnectedBones(Model, Part0)

	for _, Bone in ipairs(Bones) do
		local NewNode = NodeObject.new(Bone.Part1)

		ParentNode:AddChild(NewNode)
		NewNode:SetParent(ParentNode)
		NewNode:SetMotor6D(Bone)

		GetModelMapRecursive(Model, NewNode)
	end
end

local GetModelMap = function(Model)
	local ModelMap = NodeObject.new(Model.HumanoidRootPart)

	GetModelMapRecursive(Model, ModelMap)

	return ModelMap
end

--|| <><><> LInk Model Maps <><><> ||--
local FindLinkedNodeRecursive
FindLinkedNodeRecursive = function(ObjectName, Node)
	--| Correct Node Found

	if Node.Value.Name == ObjectName then
		return Node
	end

	--| Search Through Children
	for _, child in pairs(Node.Children) do
		local ChildSearchResult = FindLinkedNodeRecursive(ObjectName, child)

		if ChildSearchResult ~= nil then
			return ChildSearchResult
		end
	end

	--| No Node Found
	return nil
end

local FindLinkedNode = function(ObjectName, ModelMap)
	local Result = FindLinkedNodeRecursive(ObjectName, ModelMap)

	if Result then
		return Result
	else
		error("Couldn't link models, missing object: " .. ObjectName)
	end
end

local LinkModelMapsRecursive
LinkModelMapsRecursive = function(Node1, ModelMap2)
	local LinkedNode = FindLinkedNode(Node1.Value.Name, ModelMap2)

	Node1:SetLink(LinkedNode)
	LinkedNode:SetLink(Node1)

	for _, childNode in pairs(Node1.Children) do
		LinkModelMapsRecursive(childNode, ModelMap2)
	end
end

--| Main function
local LinkModelMaps = function(ModelMap1, ModelMap2)
	LinkModelMapsRecursive(ModelMap1, ModelMap2)
end

local GetLinkedModelMaps = function(Model1, Model2)
	local ModelMap1 = GetModelMap(Model1)
	local ModelMap2 = GetModelMap(Model2)

	LinkModelMaps(ModelMap1, ModelMap2)

	return ModelMap1, ModelMap2
end

return GetLinkedModelMaps

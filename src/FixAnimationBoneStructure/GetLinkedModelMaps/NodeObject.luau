--[[ NodeObject: Put together by polill00;

Simple tree structure used for keeping track of the bone structure with some handy variables.

]]

--// Decloration
local NodeObject = {}
NodeObject.__index = NodeObject
--\\

--// Constructor
function NodeObject.new(Value)
	local self = setmetatable({}, NodeObject)

	self.Value = Value
	self.Parent = nil
	self.Children = {}
	self.Link = nil
	self.Motor6D = nil

	return self
end

function NodeObject:ChangeValue(Value)
	self.Value = Value
end

function NodeObject:SetParent(Parent)
	self.Parent = Parent
end

function NodeObject:AddChild(Child)
	self.Children[Child.Value.Name] = Child
end

function NodeObject:SetLink(Link)
	self.Link = Link
end

function NodeObject:SetMotor6D(Motor6D)
	self.Motor6D = Motor6D
end

return NodeObject

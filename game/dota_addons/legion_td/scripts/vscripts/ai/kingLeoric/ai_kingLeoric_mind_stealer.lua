require("ai/ai_core")
print("y")
function aiThinkStandardSkill(self)
	if not self:IsAlive() and not self:HasModifier("modifier_invulnerable") then
		return
	end

	if self:HasModifier("modifier_unit_freeze_lua") or GameRules:IsGamePaused() then
		return STANDARD_THINK_TIME
	end
	if self:CheckIfHasAggro() then
		for i,v in ipairs(self.ability) do
			if v:IsCooldownReady() then
				v.Skill(self, v)
			end
		end
	end

	if self.wayStep and ((self:GetAbsOrigin() - self.waypoints[self.wayStep]):Length2D() < 50) then -- we've hit a waypoint
		return self:NextWayPoint()
	end

	if self:IsIdle() and not self:CheckIfHasAggro() then
		return self:Unstuck()
	end
	return STANDARD_THINK_TIME
end

function Spawn(entity)
    InitAI(thisEntity)
end

function InitAI( self )
	self:SetContextThink( "init_think", function()
		self.aiThink = aiThinkStandardSkill
		self.CheckIfHasAggro = CheckIfHasAggro
		self.ability = {}
		self.ability[1] = self:FindAbilityByName("kingLeoric_hinder")
		self.ability[1].Skill = UseSkillOnTargetPosition
		self.Unstuck = Unstuck
		self:SetContextThink( "ai_mind_stealer.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
	end, 0 )
end
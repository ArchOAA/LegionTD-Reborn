STANDARD_THINK_TIME = 0.1

EXPORTS = {}

LinkLuaModifier( "modifier_unit_freeze_lua", "abilities/modifier_unit_freeze_lua.lua", LUA_MODIFIER_MOTION_NONE)

EXPORTS.Init = function( self )
	self:SetContextThink( "init_think", function()
		self.aiThink = aiThinkStandard
		self.NextWayPoint = NextWayPoint
		self.Unstuck = Unstuck
		self.CheckIfHasAggro = CheckIfHasAggro
		self:Unstuck()
		self:SetContextThink( "ai_standard.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
	end, 0 )
end

function aiThinkStandard(self)
	if not self:IsAlive() and not self:HasModifier("modifier_invulnerable") then
		return
	end
	if self:HasModifier("modifier_unit_freeze_lua") or GameRules:IsGamePaused() then
		return STANDARD_THINK_TIME
	end
	if self.wayStep and ((self:GetAbsOrigin() - self.waypoints[self.wayStep]):Length2D() < 50) then -- we've hit a waypoint
		return self:NextWayPoint()
	end
	if self:IsIdle() and not self:CheckIfHasAggro() then
		return self:Unstuck()
	end

	return STANDARD_THINK_TIME
end

function aiThinkStandardBuff(self)
	if not self:IsAlive() and not self:HasModifier("modifier_invulnerable") then
		return
	end
	if self:HasModifier("modifier_unit_freeze_lua") or GameRules:IsGamePaused() then
		return STANDARD_THINK_TIME
	end
	if self.ability:IsCooldownReady() then
		return self:Skill()
	end
	if self.wayStep and ((self:GetAbsOrigin() - self.waypoints[self.wayStep]):Length2D() < 50) then -- we've hit a waypoint
		return self:NextWayPoint()
	end
	if self:IsIdle() and not self:CheckIfHasAggro() then
		return self:Unstuck()
	end
	return STANDARD_THINK_TIME
end

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

function UseSkillNoTarget(self, ability)
	self:CastAbilityNoTarget(ability, -1)
	return 1
end

function UseSkillOnTargetPosition(self, ability)
	self:CastAbilityOnPosition(self:GetAggroTarget():GetAbsOrigin(), ability, -1)
	return 1
end

function UseSkillOnTarget(self, ability)
	self:CastAbilityOnTarget(self:GetAggroTarget(), ability, -1)
	return 1
end

function UseSkillOnSelf(self, ability)
	self:CastAbilityOnTarget(self, ability, -1)
	return 1
end

function NextWayPoint(self)
--	print("lane creep hit waypoint " .. self.wayStep)
		if self.wayStep < 4 then
			self.wayStep = self.wayStep + 1
			ExecuteOrderFromTable({
	          UnitIndex = self:entindex(), 
	          OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
	          TargetIndex = 0, --Optional.  Only used when targeting units
	          AbilityIndex = 0, --Optional.  Only used when casting abilities
	          Position = self.waypoints[self.wayStep], --Optional.  Only used when targeting the ground
	          Queue = 0 --Optional.  Used for queueing up abilities
	        })
		end
		
        return STANDARD_THINK_TIME
    end

function Unstuck(self)
	if self.wayStep then -- is this a wave/send creep?
		--print ("Unsticking unit with .WayStep")
		ExecuteOrderFromTable({
          UnitIndex = self:entindex(), 
          OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
          TargetIndex = 0, --Optional.  Only used when targeting units
          AbilityIndex = 0, --Optional.  Only used when casting abilities
          Position = self.waypoints[self.wayStep], --Optional.  Only used when targeting the ground
          Queue = 0 --Optional.  Used for queueing up abilities
        })
	elseif self.nextTarget then
		--print ("Unsticking unit with .nextTarget: " .. self.nextTarget.x .. ", " .. self.nextTarget.y)
		self:Stop()
		ExecuteOrderFromTable({
	          UnitIndex = self:entindex(), 
	          OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
	          TargetIndex = 0, --Optional.  Only used when targeting units
	          AbilityIndex = 0, --Optional.  Only used when casting abilities
	          Position = self.nextTarget, --Optional.  Only used when targeting the ground
	          Queue = 0 --Optional.  Used for queueing up abilities
	        })
	end
	return 1.0
end

function CheckIfHasAggroInRange(self)
	if self:GetAggroTarget() ~= nil then
		if CalcDistanceBetweenEntityOBB(self, self:GetAggroTarget()) < self.skillUseRange then
			return true
		end
	end
	return false
end

function CheckIfHasAggro( self )
	return self:GetAggroTarget() ~= nil
end

return EXPORTS

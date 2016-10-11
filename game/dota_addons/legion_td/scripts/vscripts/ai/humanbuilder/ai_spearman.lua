require("ai/ai_core")

function Spawn(entity)
    InitAI(thisEntity)
end

function InitAI( self )
	self:SetContextThink( "init_think", function()
		self.aiThink = aiThinkStandardSkill
		self.CheckIfHasAggro = CheckIfHasAggro
		self.Skill = UseSkillOnTarget
		self.ability = self:FindAbilityByName("spearman_shield_bash")
		self.Unstuck = Unstuck
		self:SetContextThink( "ai_spearman.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
	end, 0 )
end

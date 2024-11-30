--日冕黑子 晷昶龙
function c21300705.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),12,3,c21300705.ovfilter,aux.Stringid(21300705,0),3,c21300705.xyzop)
	c:EnableReviveLimit() 
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.xyzlimit)
	c:RegisterEffect(e1)
	--spsummon success
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c21300705.sumcon)
	e2:SetOperation(c21300705.sucop)
	c:RegisterEffect(e2) 
	--destroy all
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING) 
	e3:SetRange(LOCATION_MZONE)  
	e3:SetCountLimit(1) 
	e3:SetCondition(c21300705.descon1) 
	e3:SetCost(c21300705.descost)
	e3:SetTarget(c21300705.destg)
	e3:SetOperation(c21300705.desop)
	c:RegisterEffect(e3)
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING) 
	e3:SetRange(LOCATION_MZONE)  
	e3:SetCountLimit(1) 
	e3:SetCondition(c21300705.descon2) 
	e3:SetCost(c21300705.descost)
	e3:SetTarget(c21300705.destg)
	e3:SetOperation(c21300705.desop)
	c:RegisterEffect(e3) 
	--destroy and damage
	local e4=Effect.CreateEffect(c) 
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_CONFIRM)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c21300705.ddcon)
	e4:SetTarget(c21300705.ddtg)
	e4:SetOperation(c21300705.ddop)
	c:RegisterEffect(e4)
	if not c21300705.global_check then
		c21300705.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c21300705.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c21300705.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function c21300705.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,21300705)>0 and Duel.GetFlagEffect(tp,11300705)==0 end
	Duel.RegisterFlagEffect(tp,11300705,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c21300705.check(c)
	return c and c:IsSetCard(0x680)
end
function c21300705.checkop(e,tp,eg,ep,ev,re,r,rp)
	if c21300705.check(Duel.GetAttacker()) or c21300705.check(Duel.GetAttackTarget()) then
		Duel.RegisterFlagEffect(tp,21300705,RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(1-tp,21300705,RESET_PHASE+PHASE_END,0,1)
	end
end
function c21300705.sumcon(e,tp,eg,ep,ev,re,r,rp) 
	local mg=e:GetHandler():GetMaterial()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and mg:GetCount()>0 and mg:FilterCount(Card.IsSetCard,nil,0x680)==mg:GetCount() 
end
function c21300705.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT) 
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te)
	return te:GetOwner()~=e:GetOwner() end) 
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function c21300705.descon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp   
end 
function c21300705.descon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():GetOverlayGroup():IsExists(function(c) return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x680) end,1,nil)  
end 
function c21300705.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end 
function c21300705.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c21300705.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function c21300705.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
function c21300705.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD) 
end
function c21300705.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		local dc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if Duel.Destroy(dc,REASON_EFFECT)>0 and dc:GetBaseAttack()>0 then
			Duel.Damage(1-tp,dc:GetBaseAttack(),REASON_EFFECT) 
		end
	end
end

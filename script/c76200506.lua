--灾厄的赤龙 梅柳齐娜 赤热偏位
function c76200506.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--synchro summon
	aux.AddSynchroProcedure(c,function(c) return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) end,function(c) return c:IsCode(76200500) end,1,1)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.synlimit)
	e1:SetRange(LOCATION_EXTRA) 
	c:RegisterEffect(e1) 
	--destroy all
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,76200506)
	e1:SetCondition(function(e) 
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e1:SetTarget(c76200506.destg)
	e1:SetOperation(c76200506.desop)
	c:RegisterEffect(e1)
	--destroy and damage
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,16200506)
	e2:SetCondition(c76200506.ddcon)
	e2:SetTarget(c76200506.ddtg)
	e2:SetOperation(c76200506.ddop)
	c:RegisterEffect(e2)
	--reg
	local e3=Effect.CreateEffect(c) 
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c76200506.regop)
	c:RegisterEffect(e3) 
end
function c76200506.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c76200506.desop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if g:GetCount()>0 then
		local x=Duel.Destroy(g,REASON_EFFECT) 
		if c:IsRelateToEffect(e) and x>0 then 
			local e1=Effect.CreateEffect(c) 
			e1:SetType(EFFECT_TYPE_SINGLE) 
			e1:SetCode(EFFECT_UPDATE_ATTACK) 
			e1:SetRange(LOCATION_MZONE) 
			e1:SetValue(x*600) 
			e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
			c:RegisterEffect(e1) 
		end 
	end
end
function c76200506.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
function c76200506.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsAbleToRemove() end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
function c76200506.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)>0 then
		local dam=bc:GetBaseAttack()
		if dam>0 then Duel.Damage(p,dam,REASON_EFFECT) end
	end
end
function c76200506.regop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND) 
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD) 
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1) 
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(c76200506.tecon)
	e1:SetTarget(c76200506.tetg)
	e1:SetOperation(c76200506.teop)
	c:RegisterEffect(e1)
end
function c76200506.tecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()  
end 
function c76200506.tetg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return true end 
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0) 
end
function c76200506.tspfil(c,e,tp)
	return c:IsCode(76200500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c76200506.teop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster() and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) and Duel.IsExistingMatchingCard(c76200506.tspfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(76200506,0)) then
		local g=Duel.SelectMatchingCard(tp,c76200506.tspfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
	end
end







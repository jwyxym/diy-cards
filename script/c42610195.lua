--盾之勇者成名录 岩谷尚文
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700521)
	--link summon
	aux.AddLinkProcedure(c,nil,2,3,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(cm.atlimit)
	c:RegisterEffect(e1)
	--destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(0x1c)
	e5:SetTarget(cm.desreptg)
	e5:SetValue(cm.desrepval)
	e5:SetOperation(cm.desrepop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_WIND) and g:IsExists(Card.IsLinkRace,1,nil,RACE_WARRIOR)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.atlimit(e,c)
	return not c:IsCode(m)
end

function cm.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and not c:IsCode(m)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function cm.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(cm.repfilter,1,nil,tp) and ((c:IsAbleToGrave() and c:IsOnField() and Duel.GetFlagEffect(tp,m+1)==0) or (c:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,0x02,0,1,nil) and c:IsLocation(0x10) and Duel.GetFlagEffect(tp,m)==0)) end
	if c:IsOnField() then
		return Duel.SelectEffectYesNo(tp,c,96)
	else
		return Duel.SelectYesNo(tp,aux.Stringid(m,0))
	end
end

function cm.desrepval(e,c)
	return cm.repfilter(c,e:GetHandlerPlayer())
end

function cm.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(0x10) then
		Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1,nil)
		if Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil) then
			Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT+REASON_REPLACE)
		end
	else
		Duel.RegisterFlagEffect(tp,m+1,RESET_PHASE+PHASE_END,0,1,nil)
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_REPLACE)
	end
	Duel.Hint(HINT_CARD,0,m)
end
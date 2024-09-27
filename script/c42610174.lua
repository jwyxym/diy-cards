--为美好世界献上祝福! 阿库娅
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700141)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(cm.adval)
	c:RegisterEffect(e6)
    --immune
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0x0c,0)
	e1:SetValue(cm.efilter)
	c:RegisterEffect(e1)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_WATER)
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

function cm.valafilter(c,tp)
    return c:IsFaceup() and ((c:IsAttribute(ATTRIBUTE_WATER) and c:IsControler(tp)) or (c:IsRace(0x4010) and c:IsControler(1-tp)))
end

function cm.adval(e,c)
	return Duel.GetMatchingGroupCount(cm.valafilter,e:GetHandlerPlayer(),0x34,0x34,nil,e:GetHandlerPlayer())*100
end

function cm.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsRace(0x4010)
end
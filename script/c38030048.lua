--苍辉银河 宇宙埃列什基伽勒
function c38030048.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3,99,c38030048.lcheck)
	c:EnableReviveLimit()
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(aux.linklimit)
	c:RegisterEffect(e0)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	--activate limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c38030048.actcon)
	e2:SetValue(c38030048.aclimit)
	c:RegisterEffect(e2)
	--disable search
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetCondition(c38030048.actcon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_GRAVE))
	c:RegisterEffect(e3)
	--cannot to deck
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TO_DECK)
	c:RegisterEffect(e4)
	--atk
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c38030048.atkval)
	c:RegisterEffect(e5)
	--immune
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_LEAVE_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,38030048)
	e6:SetCondition(c38030048.tgcon)
	e6:SetOperation(c38030048.immop)
	c:RegisterEffect(e6)
end
function c38030048.mfilter(c)
	return c:IsLinkSetCard(0x613) and c:IsLinkAbove(4)
end
function c38030048.lcheck(g)
	return g:IsExists(c38030048.mfilter,1,nil)
end
function c38030048.actcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetHandler():GetSequence()>4
end
function c38030048.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE and not re:GetHandler():IsSetCard(0x611)
end
function c38030048.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_GRAVE,LOCATION_GRAVE)*100
end
function c38030048.tgfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
function c38030048.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38030048.tgfilter,1,nil,tp)
end
function c38030048.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c38030048.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function c38030048.efilter(e,re)
	return re:GetOwner()~=e:GetOwner()
end

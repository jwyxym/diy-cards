-- 摹画龙形
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--cannot be link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(SUMMON_VALUE_SELF)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--effect gain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(s.immcon)
	e3:SetTarget(s.immtg)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
function s.refilter(c,tp)
	return ((c:GetOriginalRace()&RACE_WYRM>0 and not c:IsLocation(LOCATION_MZONE)) or c:IsRace(RACE_WYRM)) and ((c:IsControler(tp) and c:IsFaceupEx()) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
function s.rfilter(c,tp)
	return ((c:GetOriginalAttribute()&ATTRIBUTE_WATER>0 and not c:IsLocation(LOCATION_MZONE)) or c:IsAttribute(ATTRIBUTE_WATER)) and ((c:IsControler(tp) and c:IsFaceupEx()) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
function s.fselect(g,tp)
	return g:IsExists(s.rfilter,1,nil,tp)	and Duel.GetMZoneCount(tp,g)>0
end
function s.spcon(e,c,tp)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.refilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,LOCATION_ONFIELD,nil,tp)
	return rg:CheckSubGroup(s.fselect,3,3,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.refilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,LOCATION_ONFIELD,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=rg:SelectSubGroup(tp,s.fselect,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	local g1=g:Filter(Card.IsPreviousLocation,nil,LOCATION_MZONE)
	local g2=g:Filter(Card.IsPreviousLocation,nil,LOCATION_SZONE+LOCATION_EXTRA)
	local atk=g1:GetSum(Card.GetPreviousAttackOnField)+g2:GetSum(Card.GetBaseAttack)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttack()>3000
end
function s.immtg(e,c)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg:IsContains(c) and c:IsSetCard(0xe91)
end
function s.efilter(e,te)
	return te:IsActivated() and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.spfilter(c,e,tp,exc)
	return c:IsSetCard(0xe91) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetMZoneCount(tp,exc)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp,nil):GetFirst()
		if sc then
			Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(c:GetPreviousAttackOnField())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			sc:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end
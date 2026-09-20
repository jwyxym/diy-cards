--永劫的决斗·莫迪凯
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--融合召唤
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),true)
	c:EnableReviveLimit()
	--效果耐性    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.flagop)
	c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.indcon)
	e3:SetTarget(s.imval)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--回复
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetOperation(s.rcop)
	c:RegisterEffect(e4)    
	--特殊召唤
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(1,id)
	e5:SetCondition(s.spcon)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)       
end
function s.matfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER)
end
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end
function s.indcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.imval(e,c)
	return c~=e:GetHandler()
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return end
	local c=e:GetHandler()
    Duel.Hint(HINT_CARD,0,id)
	Duel.Recover(tp,ev,REASON_EFFECT)
    local pdef=c:GetDefense()
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(-ev)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
    if pdef~=0 and c:IsDefense(0) then
        Duel.BreakEffect()
        Duel.Release(c,REASON_EFFECT)       
    end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.selfspcon)
	e1:SetOperation(s.selfspop)
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
        e1:SetLabel(Duel.GetTurnCount())
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
        e1:SetLabel(0)
	end
	Duel.RegisterEffect(e1,tp)
end
function s.selfspfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.selfspfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetTurnCount()~=e:GetLabel()
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.selfspfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
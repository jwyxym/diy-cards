--永远的决斗者·莫迪凯
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--融合召唤
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),true)
	c:EnableReviveLimit()
	--送去墓地    
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--多次攻击    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.flagop)
	c:RegisterEffect(e0)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(s.bdcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--特殊召唤    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or (re and not re:GetHandler():IsCode(id))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
    if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
end
function s.bdcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetCountLimit(1)
	e1:SetCondition(s.selfspcon)
	e1:SetOperation(s.selfspop)
	if Duel.GetCurrentPhase()==PHASE_BATTLE_START then
		e1:SetReset(RESET_PHASE+PHASE_BATTLE_START,2)
        e1:SetLabel(Duel.GetTurnCount())
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE_START)
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
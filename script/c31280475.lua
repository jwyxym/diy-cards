--恶魂猎手
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--融合召唤
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_EFFECT),false)
	c:EnableReviveLimit()
	--特召限制    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.fuslimit)
	c:RegisterEffect(e0)
	--改变效果    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.flagop)
	c:RegisterEffect(e3)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
	--特殊召唤
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)      
end
function s.matfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER)
end
function s.fuslimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end    
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return loc&(LOCATION_HAND|LOCATION_GRAVE)>0 and re:IsActiveType(TYPE_MONSTER) and e:GetHandler():GetFlagEffect(id)>0
end                
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp) and c:IsCode(code)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,rp)
    	and Duel.IsExistingMatchingCard(s.spfilter,rp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,re,rp,rc:GetCode()) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c,rp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local g=Group.CreateGroup()
		Duel.ChangeTargetCard(ev,g)
		Duel.ChangeChainOperation(ev,s.repop)
    end
end
function s.desfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local res=false
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,c:GetCode()):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
    	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
        res=true
    end
    Duel.SpecialSummonComplete()
    Duel.AdjustAll()
    if res and Duel.IsExistingMatchingCard(s.desfilter,1-tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetCode())
    	and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(1-tp,s.desfilter,1-tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c:GetCode())
		if g:GetCount()>0 then
        	Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
        end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
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
	return aux.IsCodeListed(c,31280102) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.selfspfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetTurnCount()~=e:GetLabel()
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.selfspfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
    	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(2500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
    Duel.SpecialSummonComplete()
end
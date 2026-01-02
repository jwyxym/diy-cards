--焕花的学徒 迷迷灯
local s,id,o=GetID()
function s.initial_effect(c)
	--除外特召	
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_IGNITION+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_REMOVED)
    e0:SetCountLimit(1,id+o+EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.spcon1)
	e0:SetOperation(s.spop1)
	c:RegisterEffect(e0)   
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_REMOVED)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon0)
	c:RegisterEffect(e1)    
	--墓地特召
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	--检索除外送墓    
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.spfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_PYRO+RACE_PLANT+RACE_SPELLCASTER) 
    	and not c:IsCode(id) and c:IsAbleToDeckAsCost()
end
function s.spcon1(e)
	local c=e:GetHandler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil)
end        
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,1,REASON_COST)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SpecialSummonRule(tp,c)
	c:ResetFlagEffect(id)
end
function s.spcon0(e,c)
	if c==nil then return true end
	return c:GetFlagEffect(id)~=0
end
function s.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,1,REASON_COST)
end
function s.rmfilter(c)
	return c:IsSetCard(0xfb19) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_PYRO+RACE_PLANT+RACE_SPELLCASTER) and c:IsLocation(LOCATION_EXTRA)
end
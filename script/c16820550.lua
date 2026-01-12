--焕花幻化
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--衍生物
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--盖放回合发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCost(s.actcost)
	c:RegisterEffect(e3)        
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb19) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 
    	and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    	local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)	
		if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.HintSelection(g)
			Duel.Release(g,REASON_EFFECT)
		end    
    end
end    
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16820545,0xdf22,TYPES_TOKEN_MONSTER,0,0,4,RACE_PYRO,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16820545,0xdf22,TYPES_TOKEN_MONSTER,0,0,4,RACE_PYRO,ATTRIBUTE_FIRE) then
		local token=Duel.CreateToken(tp,16820545)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		Duel.SpecialSummonComplete()
	end
end
function s.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER+RACE_PYRO+RACE_PLANT)
end
function s.rfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER+RACE_PYRO+RACE_PLANT) and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,c) 
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.rfilter,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,s.rfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
--恶魔神 绝望世界
function c21362800.initial_effect(c) 
	aux.AddCodeList(c,21362800)
	c:SetSPSummonOnce(21362800)
	c:EnableCounterPermit(0xba38,LOCATION_PZONE+LOCATION_MZONE)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c) 
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_PZONE)
	e1:SetValue(function(e,te)
	return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e1)
	--skip 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21362800,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1)  
	e1:SetTarget(c21362800.skiptg)
	e1:SetOperation(c21362800.skipop)
	c:RegisterEffect(e1)
	--to deck 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21362800,2))
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN) 
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_MZONE) 
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)  
	e2:SetCondition(c21362800.tdcon)
	e2:SetTarget(c21362800.tdtg)
	e2:SetOperation(c21362800.tdop)
	c:RegisterEffect(e2) 
	--counter 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F) 
	e1:SetCode(EVENT_PHASE+PHASE_DRAW)  
	e1:SetRange(LOCATION_PZONE) 
	e1:SetCountLimit(1)  
	e1:SetTarget(c21362800.cttg)
	e1:SetOperation(c21362800.ctop)
	c:RegisterEffect(e1) 
	local e2=e1:Clone() 
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY) 
	c:RegisterEffect(e2) 
	local e2=e1:Clone() 
	e2:SetCode(EVENT_PHASE+PHASE_MAIN1) 
	c:RegisterEffect(e2) 
	local e2=e1:Clone() 
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE) 
	c:RegisterEffect(e2) 
	local e2=e1:Clone() 
	e2:SetCode(EVENT_PHASE+PHASE_MAIN2) 
	c:RegisterEffect(e2) 
	local e2=e1:Clone() 
	e2:SetCode(EVENT_PHASE+PHASE_END) 
	c:RegisterEffect(e2)  
	--setsp
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e3:SetCode(EVENT_CHAINING) 
	e3:SetProperty(EFFECT_FLAG_DELAY)   
	e3:SetRange(LOCATION_PZONE)   
	e3:SetCost(c21362800.stspcost)
	e3:SetTarget(c21362800.stsptg)
	e3:SetOperation(c21362800.stspop)
	c:RegisterEffect(e3)
end
function c21362800.skipcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c21362800.skiptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_M1)
	local b2=not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_BP)
	local b3=not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_M2)
	if chk==0 then return b1 or b2 or b3 end
end
function c21362800.skipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_M1)
	local b2=not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_BP)
	local b3=not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_M2) 
	if b1 or b2 or b3 then 
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(21362800,3)},{b2,aux.Stringid(21362800,4)},{b3,aux.Stringid(21362800,5)}) 
		local ecode=0 
		if op==1 then ecode=EFFECT_SKIP_M1 end 
		if op==2 then ecode=EFFECT_SKIP_BP end 
		if op==3 then ecode=EFFECT_SKIP_M2 end 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(ecode) 
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		Duel.RegisterEffect(e1,tp) 
	end 
end
function c21362800.tdckfil(c) 
	return c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0xba38)  
end 
function c21362800.tdcon(e,tp,eg,ep,ev,re,r,rp) 
	local g=Duel.GetMatchingGroup(c21362800.tdckfil,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=4  
end
function c21362800.tdtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c21362800.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,e:GetHandler()) 
	if g:GetCount()>0 then 
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end 
end 
function c21362800.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0xba38,1) end
end
function c21362800.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0xba38,1)
	end
end
function c21362800.stspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xba38,12,REASON_COST) end 
	e:GetHandler():RemoveCounter(tp,0xba38,12,REASON_COST)
end
function c21362800.setfil(c) 
	return c:IsSetCard(0xba38) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable(true)
end 
function c21362800.setgck(g,tp) 
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	return g:GetCount()<=ft and aux.dncheck(g)  
end 
function c21362800.stsptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(c21362800.setfil,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(c21362800.setgck,1,4,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end 
end
function c21362800.stspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c21362800.setfil,tp,LOCATION_DECK,0,nil)
	if g:CheckSubGroup(c21362800.setgck,1,4,tp) then 
		local sg=g:SelectSubGroup(tp,c21362800.setgck,false,1,4,tp) 
		if Duel.SSet(tp,sg)~=0 then 
			local tc=sg:GetFirst() 
			while tc do 
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(21362800,0))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=sg:GetNext() 
			end 
			if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
				Duel.BreakEffect()
				Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)  
				c:CompleteProcedure()
			end 
		end 
	end 
end 





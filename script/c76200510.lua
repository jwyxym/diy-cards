--光之地平线
function c76200510.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c76200510.activate)
	c:RegisterEffect(e1)
	--act limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c76200510.limcon)
	e2:SetOperation(c76200510.limop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(c76200510.limop2)
	c:RegisterEffect(e3) 
	--synchro summon
	local e4=Effect.CreateEffect(c) 
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c76200510.sccon)
	e4:SetTarget(c76200510.sctg)
	e4:SetOperation(c76200510.scop)
	c:RegisterEffect(e4)
end
function c76200510.tgfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1) and c:IsAbleToGrave()
end
function c76200510.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c76200510.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(76200510,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT) 
	end
end
function c76200510.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c76200510.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76200510.limfilter,1,nil,tp)
end
function c76200510.limop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(c76200510.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(76200510,RESET_EVENT+RESETS_STANDARD,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c76200510.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function c76200510.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(76200510)
	e:Reset()
end
function c76200510.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(76200510)~=0 then
		Duel.SetChainLimitTillChainEnd(c76200510.chainlm)
	end
	e:GetHandler():ResetFlagEffect(76200510)
end
function c76200510.chainlm(e,rp,tp)
	return tp==rp
end
function c76200510.sccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)  
end 
function c76200510.syncheck(g,tp,syncard)
	return g:IsExists(Card.IsCode,1,nil,76200500) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1) and aux.SynMixHandCheck(g,tp,syncard)
end
function c76200510.spfilter(c,tp,mg)
	return mg:CheckSubGroup(c76200510.syncheck,2,#mg,tp,c)
end
function c76200510.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		return Duel.IsExistingMatchingCard(c76200510.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c76200510.scop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	local g=Duel.GetMatchingGroup(c76200510.spfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local tg=mg:SelectSubGroup(tp,c76200510.syncheck,false,2,#mg,tp,sc)
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end







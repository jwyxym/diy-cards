--莱欧斯小队 齐尔查克
function c31280203.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31280203)
	e1:SetCondition(c31280203.spcon)
	e1:SetTarget(c31280203.sptg)
	e1:SetOperation(c31280203.spop)
	c:RegisterEffect(e1)
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
	e2:SetCode(EVENT_CHAIN_SOLVING)  
	e2:SetRange(LOCATION_MZONE) 
	e2:SetCondition(c31280203.thcon) 
	e2:SetOperation(c31280203.thop)
	c:RegisterEffect(e2)
	--lock
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,11280203)
	e2:SetCost(c31280203.lkcost)
	e2:SetTarget(c31280203.lktg)
	e2:SetOperation(c31280203.lkop)
	c:RegisterEffect(e2)
end
--c31280203.SetCard_TnT_Lwsteam=true 
function c31280203.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca0) 
end
function c31280203.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31280203.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280203.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280203.thfil(c) 
	return c:IsAbleToHand() and c.SetCard_TnT_Lwsteam and c:IsType(TYPE_SPELL+TYPE_TRAP)  
end 
function c31280203.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.BreakEffect()  
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
		e1:SetCode(EVENT_PHASE+PHASE_END) 
		e1:SetCountLimit(1)
		e1:SetOperation(c31280203.xdrop) 
		e1:SetReset(RESET_PHASE+PHASE_END) 
		Duel.RegisterEffect(e1,tp)
	end
end
function c31280203.xdrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,31280203) 
	Duel.Draw(tp,1,REASON_EFFECT) 
end 
function c31280203.thcon(e,tp,eg,ep,ev,re,r,rp) 
	local rc=re:GetHandler()
	return e:GetHandler():IsAbleToHand() and re:IsActiveType(TYPE_TRAP) and rp==1-tp 
	and (c:GetOriginalLevel()>0
		or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
		or bit.band(c:GetOriginalAttribute(),0x7f)~=0
		or c:GetBaseAttack()>0
		or c:GetBaseDefense()>0)
end 
function c31280203.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAbleToHand() and Duel.SelectEffectYesNo(tp,c,aux.Stringid(31280203,0)) then 
		Duel.Hint(HINT_CARD,0,31280203)  
		Duel.SendtoHand(c,nil,REASON_EFFECT) 
	end 
end 
function c31280203.xctfil(c) 
	if c:IsLocation(LOCATION_HAND) then 
		return c:IsDiscardable() 
	else  
		return c:IsHasEffect(31280208)
	end 
end 
function c31280203.lkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c31280203.xctfil,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
	if chk==0 then return g:GetCount()>0 end 
	local tc=g:Select(tp,1,1,nil):GetFirst()  
	local te=tc:IsHasEffect(31280208) 
	if te then 
		te:UseCountLimit(tp) 
		Duel.SendtoDeck(tc,nil,2,REASON_COST)
	else 
		Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
	end 
end
function c31280203.xcfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function c31280203.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and c31280203.xcfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280203.xcfilter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectTarget(tp,c31280203.xcfilter,tp,0,LOCATION_SZONE,1,1,nil) 
end
function c31280203.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget() 
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then 
		Duel.ConfirmCards(tp,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) 
		tc:RegisterEffect(e1) 
	end
end


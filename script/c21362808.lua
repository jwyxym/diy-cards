--魔诞 死亡狮虎
function c21362808.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--pendulum set
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetRange(LOCATION_HAND) 
	e1:SetCountLimit(1,21362808) 
	e1:SetTarget(c21362808.pctg)
	e1:SetOperation(c21362808.pcop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE) 
	e2:SetTarget(function(e,c) 
	return c~=e:GetHandler() end)
	e2:SetCondition(function(e)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) end)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,11362808)
	e3:SetTarget(c21362808.srtg)
	e3:SetOperation(c21362808.srop)
	c:RegisterEffect(e3)
end
function c21362808.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362808.pctg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362808.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,21362800) and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return (b1 or b2) and Duel.GetFlagEffect(tp,21362808)==0 end
end
function c21362808.spfil(c,e,tp) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xba38)  
end 
function c21362808.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362808.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,21362800) and Duel.IsPlayerCanDraw(tp,1)
	local b3=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,21362800) and Duel.IsExistingMatchingCard(c21362808.spfil,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	if b1 or b2 then 
		if b2 or b3 then 
			local op=aux.SelectFromOptions(tp,{b2,aux.Stringid(21362808,1)},{b3,aux.Stringid(21362808,2)}) 
			if op==1 then 
				Duel.Draw(tp,1,REASON_EFFECT)  
				Duel.RegisterFlagEffect(tp,21362808,RESET_PHASE+PHASE_END,0,2)
			elseif op==2 then 
				local sg=Duel.SelectMatchingCard(tp,c21362808.spfil,tp,LOCATION_HAND,0,1,1,nil,e,tp) 
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) 
			end 
		else  
			local tc=Duel.SelectMatchingCard(tp,c21362808.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)  
		end 
	end 
end
function c21362808.srfilter(c)
	return c:IsSetCard(0xba38) and c:IsAbleToHand()
end
function c21362808.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362808.srfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function c21362808.srop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21362808.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g) 
		if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then 
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE_START)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.ReturnToField(e:GetLabelObject()) end)
			Duel.RegisterEffect(e1,tp)
		end 
	end
end

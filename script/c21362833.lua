--伪型恶魔神 巴洛姆
function c21362833.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS) end)
	c:RegisterEffect(e1)
	--
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21362833)
	e1:SetTarget(c21362833.pltg)
	e1:SetOperation(c21362833.plop)
	c:RegisterEffect(e1) 
	--xx
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE) 
	e2:SetCountLimit(1,21362834) 
	e2:SetCondition(c21362833.xxcon)
	e2:SetTarget(c21362833.xxtg)
	e2:SetOperation(c21362833.xxop)
	c:RegisterEffect(e2)
end
function c21362833.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_SZONE,0) or Duel.CheckLocation(tp,LOCATION_SZONE,4) end
end
function c21362833.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end  
	local zone=0 
	local filter=0
	filter=filter|512
	filter=filter|1024
	filter=filter|2048 
	filter=filter|8192
	local flag=Duel.SelectField(tp,1,LOCATION_SZONE,0,filter)  
	if flag==256 then zone=1 end 
	if flag==4096 then zone=16 end 
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
function c21362833.xxcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsType(TYPE_SPELL) and e:GetHandler():IsType(TYPE_CONTINUOUS)  
end 
function c21362833.setfil(c) 
	return c:IsSSetable() and c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0xba38)   
end 
function c21362833.xxtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=Duel.IsExistingMatchingCard(c21362833.setfil,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	local b2=Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanSendtoDeck(tp) 
	if chk==0 then return b1 or b2 end 
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(21362833,3)},{b2,aux.Stringid(21362833,4)})  
	e:SetCategory(0) 
	e:SetLabel(0)
	if op==1 then 
		e:SetCategory(CATEGORY_SPECIAL_SUMMON) 
		e:SetLabel(1)
	end 
	if op==2 then 
		e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_DESTROY) 
		e:SetLabel(2) 
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) 
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	end 
end
function c21362833.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel() 
	if op==1 then 
		if Duel.IsExistingMatchingCard(c21362833.setfil,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then 
			local tc=Duel.SelectMatchingCard(tp,c21362833.setfil,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if Duel.SSet(tp,tc)~=0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(21362833,0)) then 
				Duel.BreakEffect()
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			end  
		end 
	end 
	if op==2 then 
		if Duel.Draw(tp,1,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) then  
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil) 
			if Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,21362800) and c:IsRelateToEffect(e) then 
				Duel.Destroy(c,REASON_EFFECT)
			end 
		end 
	end 
end 






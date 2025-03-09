--泰拉饭 丛林肥鸟大餐
function c31280209.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--change cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(31280208)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,31280209)
	c:RegisterEffect(e1)
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11280209)  
	e2:SetTarget(c31280209.xxtg)
	e2:SetOperation(c31280209.xxop)
	c:RegisterEffect(e2)
end
c31280209.SetCard_TnT_TLmeal=true 
function c31280209.xtgfil(c) 
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WIND) or c:IsSetCard(0x3a21)) 
end 
function c31280209.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c31280209.xtgfil,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToDeck() end 
	Duel.SelectTarget(tp,c31280209.xtgfil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  
end
function c31280209.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0) then return end 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then   
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(31280209,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
		e1:SetCode(EVENT_LEAVE_FIELD) 
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)   
		e1:SetCondition(c31280209.spcon)
		e1:SetOperation(c31280209.spop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		if not tc:IsType(TYPE_EFFECT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end 
end 
function c31280209.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and e:GetHandler():GetReasonPlayer()==1-tp  
end 
function c31280209.spop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
	e1:SetCode(EVENT_PHASE+PHASE_END) 
	e1:SetLabelObject(c) 
	e1:SetCountLimit(1)
	e1:SetOperation(c31280209.xspop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c31280209.xspcon(e,tp,eg,ep,ev,re,r,rp) 
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) 
end 
function c31280209.xspop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) then 
		Duel.Hint(HINT_CARD,0,31280209) 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
	end 
end 



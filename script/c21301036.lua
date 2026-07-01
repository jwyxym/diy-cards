--墨染乐章 决裂
function c21301036.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	c:RegisterEffect(e1)   
	--atk 
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD) 
	e1:SetCode(EFFECT_UPDATE_ATTACK) 
	e1:SetRange(LOCATION_SZONE) 
	e1:SetTargetRange(LOCATION_MZONE,0) 
	e1:SetTarget(function(e,c) 
	return c:IsSetCard(0x682) end)
	e1:SetValue(function(e) 
	local tp=e:GetHandlerPlayer() 
	return Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE):GetClassCount(Card.GetRace)*200 end) 
	c:RegisterEffect(e1)   
	local e2=e1:Clone() 
	e2:SetType(EFFECT_UPDATE_DEFENSE) 
	c:RegisterEffect(e2) 
	--remove  
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN) 
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,21301036)
	e2:SetTarget(c21301036.rmtg)
	e2:SetOperation(c21301036.rmop)
	c:RegisterEffect(e2) 
	--place 
	local e3=Effect.CreateEffect(c)  
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)  
	e3:SetCode(EVENT_REMOVE) 
	e3:SetProperty(EFFECT_FLAG_DELAY) 
	e3:SetCountLimit(1,21301037)
	e3:SetCondition(function(e) 
	return not e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
	e3:SetTarget(c21301036.pltg)
	e3:SetOperation(c21301036.plop)
	c:RegisterEffect(e3)
end
function c21301036.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x682) and c:IsAbleToRemove()
end
function c21301036.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c21301036.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,c21301036.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE) 
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end
function c21301036.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT) 
	end
end
function c21301036.pltg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end  
end
function c21301036.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if c:IsRelateToEffect(e) then 
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) 
	end 
end 


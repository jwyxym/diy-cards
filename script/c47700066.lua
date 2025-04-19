--宇灾 邪月骨榕
function c47700066.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	c:EnableReviveLimit()
	--material
	aux.AddFusionProcFun2(c,c47700066.matfilter,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	--search
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,47700066)  
	e1:SetTarget(c47700066.thtg)
	e1:SetOperation(c47700066.thop)
	c:RegisterEffect(e1)	
	--pz
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_EXTRA) 
	e2:SetCountLimit(1,17700066)  
	e2:SetCondition(c47700066.pzcon)
	e2:SetTarget(c47700066.pztg)
	e2:SetOperation(c47700066.pzop)
	c:RegisterEffect(e2)  
	--draw 
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c47700066.drcon)
	e1:SetTarget(c47700066.drtg)
	e1:SetOperation(c47700066.drop)
	c:RegisterEffect(e1)
	--pzone fusion material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetValue(function(e,c)
	if not c then return true end
	return c:IsAttribute(ATTRIBUTE_DARK) end)
	c:RegisterEffect(e1)
end
function c47700066.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and (c:IsRace(RACE_PLANT) or c:IsSetCard(0x470))
end
function c47700066.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x470) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsAbleToHand()
end
function c47700066.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c47700066.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end 
function c47700066.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c47700066.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g) 
	end
end
function c47700066.pckfil(c,tp) 
	return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION) and c:IsFaceup() 
end 
function c47700066.pzcon(e,tp,eg,ep,ev,re,r,rp) 
	return eg:IsExists(c47700066.pckfil,1,nil,tp) and e:GetHandler():IsFaceup()
end
function c47700066.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c47700066.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c47700066.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
function c47700066.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47700066.cfilter,1,nil)
end
function c47700066.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c47700066.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end



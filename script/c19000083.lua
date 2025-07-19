--扭曲蜕变
function c19000083.initial_effect(c)
	c:SetUniqueOnField(1,0,19000083)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000083,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c19000083.cost)
	c:RegisterEffect(e1)
	--salvage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCountLimit(1)
	e2:SetDescription(aux.Stringid(19000083,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetCondition(c19000083.thcon)
	e2:SetTarget(c19000083.thtg)
	e2:SetOperation(c19000083.thop)
	c:RegisterEffect(e2)
	--inactivatable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(c19000083.effectfilter)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(c19000083.effectfilter)
	c:RegisterEffect(e5)
end
function c19000083.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp=Duel.GetLP(tp)
	if chk==0 then return Duel.CheckLPCost(tp,lp-1,true) end
	e:SetLabel(lp-1)
	Duel.PayLPCost(tp,lp-1,true)
end
function c19000083.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function c19000083.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c19000083.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
function c19000083.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
--燃烧的灾厄之焰
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddCodeList(c,31000201)
	aux.AddRitualProcGreater2(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEASTWARRIOR),LOCATION_HAND,nil,nil)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(this.thcon)
	e2:SetTarget(this.thtg)
	e2:SetOperation(this.thop)
	c:RegisterEffect(e2)
end
function this.thfilter(c)
	return (c:IsCode(31000201) or aux.IsCodeListed(c,31000201)) and c:IsFaceup()
end
function this.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(this.setfilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

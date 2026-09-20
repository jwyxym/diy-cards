--寿司战舰的破浪
function c35100291.initial_effect(c)
    --destory
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(c35100291.decost)
    e1:SetTarget(c35100291.destg)
    e1:SetOperation(c35100291.desop)
    c:RegisterEffect(e1)
    --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35100291,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35100291)
	e2:SetCondition(c35100291.thcon)
	e2:SetTarget(c35100291.thtg)
	e2:SetOperation(c35100291.thop)
	c:RegisterEffect(e2)
end
function c35100291.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x166) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function c35100291.decost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100291.dfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local c=Duel.SelectMatchingCard(tp,c35100291.dfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=og:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_COST)
        end
end
function c35100291.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c35100291.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function c35100291.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function c35100291.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35100291.cfilter,1,nil,tp)
end
function c35100291.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c35100291.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
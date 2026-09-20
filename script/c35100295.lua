--特种军贯-鲑鱼子级救援舰
function c35100295.initial_effect(c)
	aux.AddCodeList(c,24639891,61027400)
	--xyz summon
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--apply the effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c35100295.valcheck)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35100295,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,35100295)
	e1:SetCondition(c35100295.effcon)
	e1:SetTarget(c35100295.efftg)
	e1:SetOperation(c35100295.effop)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
    --pop
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(c35100295.cost)
    e2:SetCondition(c35100295.condition)
	e2:SetTarget(c35100295.target)
	e2:SetOperation(c35100295.activate)
	c:RegisterEffect(e2)
end
function c35100295.valcheck(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=0
	if c:GetMaterial():FilterCount(Card.IsCode,nil,24639891)>0 then flag=flag|1 end
	if c:GetMaterial():FilterCount(Card.IsCode,nil,61027400)>0 then flag=flag|2 end
	e:GetLabelObject():SetLabel(flag)
end
function c35100295.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_OVERLAY)
end
function c35100295.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function c35100295.thfilter(c)
	return c:IsSetCard(0x166) and c:IsAbleToGrave()
end
function c35100295.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	if chk==0 then return chk1 or chk2 and Duel.IsExistingMatchingCard(c35100295.thfilter,tp,LOCATION_DECK,0,1,nil) end
	e:SetCategory(0)
	if chk1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,1)
	end
	if chk2 then
		e:SetCategory(e:GetCategory()|(CATEGORY_TOGRAVE))
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
function c35100295.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chk1=e:GetLabel()&1>0
	local chk2=e:GetLabel()&2>0
	if chk2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,c35100295.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if chk1 then
        Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    e1:SetCode(EVENT_PHASE+PHASE_END)
	    e1:SetCountLimit(1)
	    e1:SetOperation(c35100295.thop)
	    e1:SetReset(RESET_PHASE+PHASE_END)
	    Duel.RegisterEffect(e1,tp)
	end
end
function c35100295.filter(c)
	return (c:IsRace(RACE_AQUA) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToHand()
end
function c35100295.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,35100295)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35100295.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c35100295.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function c35100295.defilter(c)
	return c:IsSetCard(0x166) and c:IsAbleToDeckAsCost()
end
function c35100295.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c35100295.defilter,tp,LOCATION_GRAVE,0,nil,nil)
	local count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local b1=#g>=3 and count>=3 and Duel.GetDecktopGroup(tp,3):IsExists(Card.IsAbleToHand,1,nil)
	local b2=#g>=6 and count>=6 and Duel.GetDecktopGroup(tp,6):IsExists(Card.IsAbleToHand,1,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetFlagEffect(tp,35100295)==0 and (b1 or b2)
	end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(35100295,1),aux.Stringid(35100295,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(35100295,1))
	end
	local ct= op==0 and 3 or 6
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=g:Select(tp,ct,ct,nil)
	Duel.SendtoDeck(rg,nil,SEQ_DECKBOTTOM,REASON_COST)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function c35100295.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.ConfirmDecktop(p,d)
	local g=Duel.GetDecktopGroup(p,d)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
		local sc=g:Select(p,1,1,nil):GetFirst()
		if sc:IsAbleToHand() then
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-p,sc)
			Duel.ShuffleHand(p)
		else
			Duel.SendtoGrave(sc,REASON_RULE)
		end
	end
	if #g>1 then
		Duel.ShuffleDeck(tp)
	end
end

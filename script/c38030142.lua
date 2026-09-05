--No.64 太古狸 三太夫
function c38030142.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38030142)
	e1:SetCondition(c38030142.thcon)
	e1:SetTarget(c38030142.thtg)
	e1:SetOperation(c38030142.thop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030142,1))
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030142+1)
	e2:SetCost(c38030142.atkcost)
	e2:SetTarget(c38030142.atktg)
	e2:SetOperation(c38030142.atkop)
	c:RegisterEffect(e2)
end
aux.xyz_number[38030142]=64
function c38030142.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function c38030142.thfilter(c)
	return c:IsCode(38030144) and (c:IsAbleToHand() or c:IsSSetable())
end
function c38030142.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030142.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c38030142.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,c38030142.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	end
end
function c38030142.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function c38030142.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
function c38030142.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g,atk=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler()):GetMaxGroup(Card.GetAttack)
	if not c:IsRelateToChain() or c:IsFacedown() or not g or #g==0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end

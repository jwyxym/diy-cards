--邪魔主宰的旧世界
function c19000088.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19000088+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c19000088.activate)
	c:RegisterEffect(e1)
	--To hand & special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000088,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c19000088.thtg)
	e2:SetOperation(c19000088.thop)
	c:RegisterEffect(e2)
	--get effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000088,3))
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CHANGE_RANK)
	e3:SetValue(9)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetValue(2000)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	e5:SetValue(2000)
	c:RegisterEffect(e5)
end
function c19000088.ssfilter(c,tp)
	return c:IsCode(19000086) and not c:IsForbidden() and c:IsSSetable()
end
function c19000088.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c19000088.ssfilter,tp,LOCATION_DECK,0,nil,tp)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19000088,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
		Duel.SSet(tp,sg:GetFirst())
	end
end
function c19000088.thfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:GetOwner()==tp
end
function c19000088.xfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(9)
		and c:GetOverlayGroup():IsExists(c19000088.thfilter,1,nil,tp)
end
function c19000088.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c19000088.xfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c19000088.xfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c19000088.xfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
function c19000088.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=tc:GetOverlayGroup():Filter(c19000088.thfilter,nil,tp)
	if tc:IsRelateToEffect(e) and #mg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local bc=mg:Select(tp,1,1,nil):GetFirst()
		if Duel.SendtoHand(bc,nil,REASON_EFFECT)>0
			and bc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,bc)
			Duel.ShuffleHand(tp)
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and bc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and Duel.SelectYesNo(tp,aux.Stringid(19000088,2)) then
				Duel.BreakEffect()
				Duel.SpecialSummon(bc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
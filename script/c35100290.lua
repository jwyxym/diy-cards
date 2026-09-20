--军贯的出征
function c35100290.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35100290+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c35100290.cost)
	e1:SetTarget(c35100290.target)
	e1:SetOperation(c35100290.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(35100290,ACTIVITY_SPSUMMON,c35100290.counterfilter)
end
function c35100290.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_XYZ)
end
function c35100290.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(35100290,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c35100290.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c35100290.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
function c35100290.chkfilter(c,tp)
	return c:IsSetCard(0x166) and c:IsType(TYPE_XYZ) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(c35100290.thfilter1,tp,LOCATION_DECK,0,1,nil,c:GetTextDefense())
        and Duel.IsExistingMatchingCard(c35100290.thfilter2,tp,LOCATION_DECK,0,1,nil,tp)
end
function c35100290.thfilter1(c,def)
	return c:IsSetCard(0x166) and c:IsDefense(def) and c:IsAbleToHand()
end
function c35100290.thfilter2(c)
	return c:IsCode(24639891) and c:IsAbleToHand()
end
function c35100290.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100290.chkfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function c35100290.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,c35100290.chkfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if rc then
	local def=rc:GetTextDefense()
	Duel.ConfirmCards(1-tp,rc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabel(rc:GetCode())
	e1:SetOperation(c35100290.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(c35100290.damcon)
	e2:SetOperation(c35100290.damop)
	e2:SetLabelObject(e1)
	Duel.RegisterEffect(e2,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,c35100290.thfilter1,tp,LOCATION_DECK,0,1,1,nil,def)
	local g2=Duel.SelectMatchingCard(tp,c35100290.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g1>0 and #g2>0 then
			g1:Merge(g2)
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
		end
	end
end
function c35100290.regfilter(c,tp,code)
	return c:IsSummonPlayer(tp) and c:IsCode(code)
end
function c35100290.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	if eg:IsExists(c35100290.regfilter,1,nil,tp,e:GetLabel()) then
		e:SetLabel(0)
	end
end
function c35100290.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
function c35100290.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,2000,REASON_EFFECT)
end
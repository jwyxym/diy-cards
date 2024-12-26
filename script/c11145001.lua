--六欲界辟
function c11145001.initial_effect(c)
	aux.AddCodeList(c,11145000)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11145001,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,11145001)
	e2:SetTarget(c11145001.sptg)
	e2:SetOperation(c11145001.spop)
	c:RegisterEffect(e2)
	--Draw
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(11145001,1))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetTarget(c11145001.drtg)
	e3:SetOperation(c11145001.drop)
	c:RegisterEffect(e3)
	--Field
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(11145001,2))
	e4:SetTarget(c11145001.fdtg)
	e4:SetOperation(c11145001.fdop)
	c:RegisterEffect(e4)
	--GY field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11145001,3))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCategory(CATEGORY_GRAVE_ACTION)
	e5:SetCountLimit(1,11145001+1000)
	e5:SetCondition(c11145001.gfcon)
	e5:SetTarget(c11145001.gftg)
	e5:SetOperation(c11145001.gfop)
	c:RegisterEffect(e5)
	--Field2
	local e6=e5:Clone()
	e6:SetDescription(aux.Stringid(11145001,4))
	e6:SetCondition(c11145001.fdcon)
	e6:SetTarget(c11145001.fdtg2)
	e6:SetOperation(c11145001.fdop2)
	c:RegisterEffect(e6)
	--Damage
	local e7=e5:Clone()
	e7:SetDescription(aux.Stringid(11145001,5))
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetCondition(c11145001.damcon)
	e7:SetTarget(c11145001.damtg)
	e7:SetOperation(c11145001.damop)
	c:RegisterEffect(e7)
end
function c11145001.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11145001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11145001.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c11145001.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11145001.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c11145001.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c11145001.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.ShuffleHand(tp)
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function c11145001.setfilter(c,tp)
	return c:IsCode(11145000) and not c:IsForbidden()
end
function c11145001.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11145001.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function c11145001.fdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,c11145001.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function c11145001.gfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c11145001.gffilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
function c11145001.gftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11145001.gffilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c11145001.gfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c11145001.gffilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c11145001.setfilter2(c,tp)
	return c:IsCode(11145001) and not c:IsForbidden()
end
function c11145001.fdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c11145001.fdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11145001.setfilter2,tp,LOCATION_DECK,0,1,nil,tp) end
end
function c11145001.fdop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,c11145001.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function c11145001.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c11145001.damfilter(c,tp)
	return c:IsType(TYPE_FIELD)
end
function c11145001.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroupCount(c11145001.damfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
function c11145001.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroupCount(c11145001.damfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
	if g:GetCount()==0 then return end
	Duel.Damage(1-tp,g*500,REASON_EFFECT)
end


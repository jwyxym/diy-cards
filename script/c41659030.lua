--唱晓的文写·科维娜
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--灵摆①
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,10))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id+30000)
	e1:SetCost(s.pcost)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	--灵摆②
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.racetg)
	e2:SetValue(RACE_SPELLCASTER)
	c:RegisterEffect(e2)
	--①
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetCondition(s.facecon)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.top)
	c:RegisterEffect(e3)
	--②
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.ecxcon)
	e4:SetCost(s.ecxcost)
	e4:SetTarget(s.ecxtg)
	e4:SetOperation(s.ecxop)
	c:RegisterEffect(e4)
end
function s.racetg(e,c)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and aux.GetColumn(c)==aux.GetColumn(e:GetHandler())
end
--灵摆①
function s.rvf(c)
	return c:IsSetCard(0xe99)
end
function s.sphandfilter(c,e,tp)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rvf,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.rvf,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	local hg=Duel.GetMatchingGroup(s.sphandfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if hg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=hg:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--①
function s.facecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_HAND) or c:IsFaceup()
end
function s.pmfilter(c,ec)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_PENDULUM) and c~=ec
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.effchk(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra()
		and Duel.IsExistingMatchingCard(s.pmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE,0,1,nil,c) end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.effchk(e,tp,eg,ep,ev,re,r,rp,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.top(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOEXTRA)
	local g=Duel.SelectMatchingCard(tp,s.pmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil,c)
	if g:GetCount()==0 then return end
	Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	if Duel.SendtoExtraP(c,nil,REASON_EFFECT)==0 then return end
	Duel.Draw(tp,2,REASON_EFFECT)
	if not Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return end
	local eg=Duel.GetMatchingGroup(s.exmfilter,tp,LOCATION_EXTRA,0,nil)
	if eg:GetCount()==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=eg:Select(tp,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.scfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.exmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--②
function s.ecxcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return false end
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc=re:GetHandler()
	return rc:IsSetCard(0xe99) and rc:IsRace(RACE_SPELLCASTER)
		and rc:IsControler(tp) and rc:IsLocation(LOCATION_MZONE)
end
--回手作为cost
function s.ecxcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SendtoHand(c,nil,REASON_COST)
	Duel.ConfirmCards(1-tp,c)
end
function s.ecxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exmfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.ecxop(e,tp,eg,ep,ev,re,r,rp)
	s.exop(e,tp,e:GetHandler())
end
--回手后的效果（陷阱②也适用这部分）
function s.exop(e,tp,ec)
	local g=Duel.GetMatchingGroup(s.exmfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
_G.KETSUBA_EXTRA_EFFECTS=_G.KETSUBA_EXTRA_EFFECTS or {}
_G.KETSUBA_EXTRA_EFFECTS[id]=s.exop

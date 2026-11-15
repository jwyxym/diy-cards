--唱晓的采撷·埃拉拉
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--灵摆①
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,10))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.plimit)
	c:RegisterEffect(e1)
	--灵摆②
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,11))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+30000)
	e2:SetCondition(s.pencon)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--①
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND+CATEGORY_SEARCH)
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
	e4:SetCategory(CATEGORY_CONTROL)
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
function s.plimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
		and not c:IsSetCard(0xe99)
end
function s.cxtgfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cxtgfilter,1,nil,tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(RACE_SPELLCASTER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,12)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0xe99) and c:IsAbleToHand()
end
--①
function s.facecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_HAND) or c:IsFaceup()
end
function s.dfilter(c)
	return c:IsSetCard(0xe99) and c:IsAbleToHand()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.top(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local wiz=c:IsRace(RACE_SPELLCASTER)
	if not Duel.SendtoExtraP(c,nil,REASON_EFFECT) then return end
	local top=Duel.GetDecktopGroup(tp,3)
	if top:GetCount()==0 then return end
	Duel.ConfirmCards(tp,top)
	local ok=false
	local sum=0
	for tc in aux.Next(top) do
		if tc:IsType(TYPE_MONSTER) then sum=sum+tc:GetLevel() end
		if tc:IsSetCard(0xe99) then ok=true end
	end
	if sum>=9 then ok=true end
	if ok then
		local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_DECK,0,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			if sg:GetCount()>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
	if not wiz then return end
	local cg=top:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if cg:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=cg:Select(tp,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	Duel.ShuffleDeck(tp)
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
function s.maxtgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
--回手作为cost
function s.ecxcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SendtoHand(c,nil,REASON_COST)
	Duel.ConfirmCards(1-tp,c)
end
function s.ecxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.maxtgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.ecxop(e,tp,eg,ep,ev,re,r,rp)
	s.exop(e,tp,e:GetHandler())
end
--回手后的效果（陷阱②也适用这部分）
function s.exop(e,tp,ec)
	local g=Duel.GetMatchingGroup(s.maxtgfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local maxlv=0
	for tc in aux.Next(g) do
		if tc:GetLevel()>maxlv then maxlv=tc:GetLevel() end
	end
	local sg=g:Filter(Card.IsLevel,nil,maxlv)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if tc then Duel.GetControl(tc,tp) end
end
_G.KETSUBA_EXTRA_EFFECTS=_G.KETSUBA_EXTRA_EFFECTS or {}
_G.KETSUBA_EXTRA_EFFECTS[id]=s.exop

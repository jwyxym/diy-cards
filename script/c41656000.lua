-- 蓝堇的消华
local s,id,o=GetID()
function s.initial_effect(c)
	-- ① 仪式召唤（去掉1回合1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	-- ② 墓效（加1回合1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.relfilter(c)
	return c:IsReleasable() and c:IsType(TYPE_MONSTER)
end
function s.relgoal(sg,tp)
	Duel.SetSelectedCard(sg)
	return sg:CheckWithSumGreater(Card.GetLevel,7) and sg:IsExists(Card.IsSetCard,1,nil,0xe96)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then return mg:CheckSubGroup(s.relgoal,1,7,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=mg:SelectSubGroup(tp,s.relgoal,false,1,7,tp)
	aux.UseExtraReleaseCount(sg,tp)
	if Duel.Release(sg,REASON_COST)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e1:SetCountLimit(1)
		e1:SetCondition(s.spcon)
		e1:SetOperation(s.spop)
		if Duel.GetCurrentPhase()<=PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_BATTLE,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		end
		Duel.RegisterEffect(e1,tp)
	end
end
function s.relfilter2(c)
	return c:IsReleasable() and c:IsSetCard(0xe96)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=Duel.SelectMatchingCard(tp,s.relfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	if Duel.Release(sg,REASON_COST)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e1:SetCountLimit(1)
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.spcon)
		e1:SetOperation(s.spop)
		if Duel.GetCurrentPhase()<=PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_BATTLE,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		end
		Duel.RegisterEffect(e1,tp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe96) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
-- 墓效对象：双方场上任意表侧蓝堇卡（前场后场均可）
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe96)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and e:GetHandler():IsAbleToHand() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.codefilter(c,code)
	return c:IsCode(code) and not c:IsSetCard(0xe96)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsSetCard(0xe96)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=tc:GetColumnGroup()
		g:AddCard(tc)
		local cc=g:GetFirst()
		while cc do
			local code=cc:GetCode()
			local cg=Duel.GetMatchingGroup(s.codefilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,nil,code)
			local tc2=cg:GetFirst()
			while tc2 do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,3))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_ADD_SETCODE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
				e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
				e1:SetValue(0xe96)
				tc2:RegisterEffect(e1)
				tc2=cg:GetNext()
			end
			cc=g:GetNext()
		end
		if c:IsRelateToEffect(e) then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND,0,1,1,nil)
			Duel.ConfirmCards(1-tp,rg:GetFirst())
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
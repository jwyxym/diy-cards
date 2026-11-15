--黄金短剑
local s,id,o=GetID()
function s.initial_effect(c)
	--①：给予对方400伤害，那之后可以公开3张不同卡名的「黄金」·「篡夺」卡，让场上1张卡效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--①：可以公开的卡
function s.revfilter(c)
	return c:IsSetCard(0x570) or c:IsSetCard(0x571)
end
--①：可以无效的场上卡（除这张卡本身）
function s.disfilter(c,ec)
	return c~=ec and c:IsFaceup() and not c:IsDisabled()
		and (c:IsType(TYPE_SPELL+TYPE_TRAP) or (c:IsType(TYPE_MONSTER) and c:IsType(TYPE_EFFECT)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Damage(1-tp,400,REASON_EFFECT)
	local mg=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
	local names={}
	local ct=0
	for tc in aux.Next(mg) do
		local code=tc:GetCode()
		if not names[code] then
			names[code]=true
			ct=ct+1
		end
	end
	if ct<3 then return end
	if not Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local sg=Group.CreateGroup()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=mg:Select(tp,1,1,nil)
		local tc=g:GetFirst()
		if not tc then break end
		sg:AddCard(tc)
		local code=tc:GetCode()
		mg:RemoveCard(tc)
		mg=mg:Filter(function(dc) return dc:GetCode()~=code end,nil)
	end
	if sg:GetCount()<3 then return end
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local tg=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,c)
	local tc=tg:GetFirst()
	if tc and tc:IsCanBeDisabledByEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end

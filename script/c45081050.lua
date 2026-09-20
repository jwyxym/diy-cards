local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,25862681)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.chcon)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return aux.IsCodeListed(c,25862681) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.indtg(e,c)
	if not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,5414777) then
		return false
	end
	if not c:IsType(TYPE_SYNCHRO) then return false end
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil,TYPE_SYNCHRO)
	if g:GetCount()==0 then return false end
	local mg=g:GetMaxGroup(Card.GetDefense)
	return mg:IsContains(c)
end
function s.chfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
		and (c:IsCode(25862681) or aux.IsCodeListed(c,25862681))
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Recover(1-tp,1000,REASON_EFFECT)
end

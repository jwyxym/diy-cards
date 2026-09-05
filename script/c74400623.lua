local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,2,99,s.matcheck)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x74b)
end
function s.matcheck(g)
	return g:FilterCount(s.matfilter,nil)>=1
end
function s.lcfilter(c)
	return c:IsFaceup() and c:IsLink(3) and c:IsSetCard(0x74b)
end
function s.atkval(e)
	return Duel.GetMatchingGroupCount(s.lcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*100
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_LINK) then return true end
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	local lg=Group.CreateGroup()
	if lg1 then lg:Merge(lg1) end
	if lg2 then lg:Merge(lg2) end
	return lg:IsContains(c)
end
function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(s.lcfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.stfilter(chkc) end
	if chk==0 then return ct>0
		and Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

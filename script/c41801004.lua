local m=41801004
local cm=_G["c"..m]
cm.name="天底熔渣//铸物"
function cm.initial_effect(c)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.sstg)
	e1:SetOperation(cm.ssop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--des
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,m+100)
	e3:SetTarget(cm.destg)
	e3:SetOperation(cm.desop)
	c:RegisterEffect(e3)

end
function cm.desfilter(c)
	return c:IsFaceupEx() and not c:IsCode(m)
		and c:IsRace(RACE_WYRM)
end
function cm.ssfilter(c)
	return (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618))
	and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function cm.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(cm.ssfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
end
function cm.ssop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cm.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local g=Duel.SelectMatchingCard(tp,cm.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.SSet(tp,g:GetFirst())
			end
		end
	end
end
function cm.desfilter2(c)
	return (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618)) and c:IsDestructable() and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.desfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cm.desfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

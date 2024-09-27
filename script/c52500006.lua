--Sneak·燃烧突击机
local s,id,o=GetID()
Duel.LoadScript("Sneak.lua")
function s.initial_effect(c)
	--normal XYZ summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),7,2)
	--XYZ summon using set monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetTargetRange(POS_FACEDOWN_DEFENSE,0)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCost(sk.xcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--return to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCountLimit(1,id*2)
	e3:SetCost(sk.xcost)
	e3:SetTarget(s.rdtg)
	e3:SetOperation(s.rdop)
	c:RegisterEffect(e3)
end
function s.xyzfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x520) and c:IsCanBeXyzMaterial(nil) and not c:IsType(TYPE_XYZ)
end
function s.xyzcheck(sg,tp)
	return sg:FilterCount(s.xyzfilter,nil)==#sg and Duel.GetMZoneCount(tp,sg)>0
end
function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetOwner()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(s.xyzcheck,2,2,tp)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	local sg=g:SelectSubGroup(tp,s.xyzcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=e:GetLabelObject()
	local sg=Group.CreateGroup()
	local tc=mg:GetFirst()
	while tc do
		local sg1=tc:GetOverlayGroup()
		sg:Merge(sg1)
		tc=mg:GetNext()
	end
	Duel.SendtoGrave(sg,REASON_RULE)
	c:SetMaterial(mg)
	Duel.Overlay(c,mg)
	mg:DeleteGroup()
	Duel.ConfirmCards(1-tp,c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.ffilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT) then
			if Duel.Damage(1-tp,1000,REASON_EFFECT) and e:GetHandler():IsCanTurnSet() and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				if #g and Duel.SendtoGrave(g,REASON_EFFECT) then Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE) end
			end
		end
	end
end
function s.tdfilter(c)
	return c:IsSetCard(0x520) and c:IsAbleToDeck()
end
function s.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	if Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and e:GetHandler():IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g and Duel.SendtoGrave(g,REASON_EFFECT) then Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE) end
	end
end

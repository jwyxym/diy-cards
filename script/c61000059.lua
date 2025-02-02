--狂焰忠魂
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),10,2,this.xyzfilter,aux.Stringid(id,0),2,this.xyzop)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(this.ovtg)
	e1:SetOperation(this.ovop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(this.tgtg)
	e2:SetOperation(this.tgop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(this.descon)
	e3:SetTarget(this.destg)
	e3:SetOperation(this.desop)
	c:RegisterEffect(e3)
end
function this.xyzfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
function this.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
function this.xyzop(e,tp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.cfilter,tp,LOCATION_HAND,0,1,nil) end
	local g=Duel.GetMatchingGroup(this.cfilter,tp,LOCATION_HAND,0,nil)
    Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function this.ovfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsLocation(LOCATION_GRAVE) and not c:IsHasEffect(EFFECT_NECRO_VALLEY) or c:IsPosition(POS_FACEUP))
end
function this.setfilter(c)
	return c:IsSetCard(0x37c0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function this.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.ovfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function this.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,this.ovfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
		if g:GetCount()>0 then
			Duel.Overlay(c,g)
		end
		if Duel.IsExistingMatchingCard(this.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local tc=Duel.SelectMatchingCard(tp,this.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			if tc then Duel.SSet(tp,tc) end
		end
	end
end
function this.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function this.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	local g=Duel.GetDecktopGroup(tp,ct)
	Duel.DisableShuffleCheck()
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function this.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRace(RACE_ZOMBIE)
end
function this.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function this.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,aux.ExceptThisCard(e))
	if tc then Duel.Destroy(tc,REASON_EFFECT) end
end

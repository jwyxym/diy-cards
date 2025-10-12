--月之蛹 糖果滕蔓
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,5,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.attval)
	c:RegisterEffect(e1)
	--immune monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--get material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
function s.reltg(e,c)
	return c~=e:GetHandler()
end
function s.ovfilter(c)
	return c:IsFaceup() and (c:IsRank(4) or c:IsRank(5)) and c:IsRace(RACE_CYBERSE) and c:GetOverlayCount()==0
end
function s.effilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.attval(e,c)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup()
	local wg=og:Filter(s.effilter,nil)
	local wbc=wg:GetFirst()
	local att=0
	while wbc do
		att=att|wbc:GetAttribute()
		wbc=wg:GetNext()
	end
	return att
end
function s.efilter(e,te)
	if not te:IsActiveType(TYPE_MONSTER) or te:GetOwnerPlayer()==e:GetHandlerPlayer() then return false end
	local tc=te:GetHandler()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(te) and tc:IsControler(1-c:GetControler()) then
		if tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
			return tc:GetAttribute()==c:GetAttribute()
		else
			return tc:GetOriginalAttribute()==c:GetAttribute()
		end
		Debug.Message(tc,c)
	end
end
function s.mfilter(c)
	return bit.band(c:GetOriginalType(),TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK)>0
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(s.mfilter,1,nil)
end
function s.xyzfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.xyzfilter(chkc) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Duel.Overlay(c,Group.FromCards(tc))
		local att=c:GetAttribute()
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		local sum=g:Filter(Card.IsAttribute,nil,att):GetSum(Card.GetBaseAttack)
		if sum>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(sum)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
--天界审判兽·达克摩斯之羽
local cm,m,o=GetID()
function cm.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),10,3,nil,nil,3)
	c:EnableReviveLimit()
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.xyzlimit)
	c:RegisterEffect(e1)
	--materia
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,m+4)
	e1:SetCondition(cm.con)
	e1:SetTarget(cm.tg)
	e1:SetOperation(cm.op)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+5)
	e2:SetCondition(cm.con1)
	e2:SetTarget(cm.tg1)
	e2:SetOperation(cm.op1)
	c:RegisterEffect(e2)
end
function cm.filter(c)
	return c:IsCanOverlay()
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_SZONE,1,nil) end
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_SZONE,0,1,nil) or not Duel.IsExistingMatchingCard(cm.filter,tp,0,LOCATION_SZONE,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_SZONE,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,cm.filter,tp,0,LOCATION_SZONE,1,1,nil)
	g1:Merge(g2)
	Duel.Overlay(c,g1)
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		if not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return false end
		local g=c:GetOverlayGroup()
		if (g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c))
			or (g:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP)
			and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c)) then return true
		else return false end
	end
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	local g=c:GetOverlayGroup()
	local tg=Group.CreateGroup()
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_MONSTER))
	end
	if Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) then
		tg:Merge(g:Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local slc=tg:Select(tp,1,1,nil):GetFirst()
	if not slc then return end
	local typ
	if slc:GetOriginalType()&TYPE_MONSTER~=0 then typ=TYPE_MONSTER
	else typ=TYPE_SPELL+TYPE_TRAP end
	local sg=tg:Filter(Card.IsType,nil,typ)
	if Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
		if slc:IsType(TYPE_MONSTER) then 
			local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
			if dg then Duel.Destroy(dg,REASON_EFFECT) end
		else
			local dg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_SZONE,LOCATION_SZONE,c)
			for tc in aux.Next(dg)  do
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				e3:SetValue(RESET_TURN_SET)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
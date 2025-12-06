--至黑之剑 盗火行者
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFunRep(c,47700138,aux.FilterBoolFunction(Card.IsFusionSetCard,0x474,0x471),1,127,true,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(1) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(2)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(200)
	c:RegisterEffect(e2)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabelObject(c)
	e1:SetCondition(s.tdcon2)
	e1:SetOperation(s.tdop2)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetValue(Duel.GetTurnCount())
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	Duel.RegisterEffect(e1,tp)
	if c:IsSummonType(SUMMON_TYPE_FUSION) then
		local g=c:GetMaterial()
		if #g==0 then return end
		if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e3:SetValue(aux.tgoval)
			c:RegisterEffect(e3)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
		end
		if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) then
			local e4=Effect.CreateEffect(c)
			e4:SetDescription(aux.Stringid(id,6))
			e4:SetCategory(CATEGORY_DESTROY)
			e4:SetType(EFFECT_TYPE_QUICK_O)
			e4:SetCode(EVENT_CHAINING)
			e4:SetRange(LOCATION_MZONE)
			e4:SetCountLimit(1)
			e4:SetCondition(s.descon)
			e4:SetTarget(s.destg)
			e4:SetOperation(s.desop)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e4)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		end
		if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then
			local e5=Effect.CreateEffect(c)
			e5:SetDescription(aux.Stringid(id,7))
			e5:SetCategory(CATEGORY_NEGATE)
			e5:SetType(EFFECT_TYPE_QUICK_O)
			e5:SetCode(EVENT_CHAINING)
			e5:SetCountLimit(1)
			e5:SetRange(LOCATION_MZONE)
			e5:SetCondition(s.negcon)
			e5:SetTarget(s.negtg)
			e5:SetOperation(s.negop)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e5)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		end
		if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER) then
			local e6=Effect.CreateEffect(c)
			e6:SetDescription(aux.Stringid(id,8))
			e6:SetCategory(CATEGORY_TODECK)
			e6:SetType(EFFECT_TYPE_QUICK_O)
			e6:SetCode(EVENT_FREE_CHAIN)
			e6:SetRange(LOCATION_MZONE)
			e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e6:SetCountLimit(1)
			e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
			e6:SetTarget(s.tdtg3)
			e6:SetOperation(s.tdop3)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e6)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		end
		if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) then
			local e7=Effect.CreateEffect(c)
			e7:SetDescription(aux.Stringid(id,9))
			e7:SetCategory(CATEGORY_ATKCHANGE)
			e7:SetType(EFFECT_TYPE_QUICK_O)
			e7:SetCode(EVENT_FREE_CHAIN)
			e7:SetRange(LOCATION_MZONE)
			e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e7:SetCountLimit(1)
			e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
			e7:SetTarget(s.tttg)
			e7:SetOperation(s.ttop)
			e7:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e7)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
		end
	end
end
function s.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
function s.tdop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetLabelObject(),nil,2,REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and re:GetHandler():IsRelateToEffect(re)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return Duel.GetTurnPlayer()==1-tp and bit.band(loc,LOCATION_SZONE)~=0
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
function s.tdtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(4) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelBelow(3) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-3)
	c:RegisterEffect(e1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.filter1(c)
	local ct=Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)
	return c:IsSetCard(0x119b) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and ct>0
end
function s.tttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) 
	end
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<300
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-300)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
end
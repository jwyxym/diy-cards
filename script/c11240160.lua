-- 龙拳吟 小玲
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),s.ffilter2,false)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE+CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep~=tp end)
	e1:SetTarget(s.movetg)
	e1:SetOperation(s.moveop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.seletg)
	e2:SetOperation(s.seleop)
	c:RegisterEffect(e2)
end
function s.ffilter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:IsControler(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	Duel.MoveSequence(c,seq)
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		if (LOCATION_HAND+LOCATION_ONFIELD)&loc~=0 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND+LOCATION_ONFIELD)>0 then
			local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
			local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
			local g
			if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0) then
				g=hg:RandomSelect(tp,1)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
			end
			if g:GetCount()~=0 then
				Duel.HintSelection(g)
				Duel.Destroy(g,REASON_EFFECT)
			end
		elseif (LOCATION_GRAVE+LOCATION_REMOVED)&loc~=0 and Duel.IsChainDisablable(ev) then
			Duel.NegateEffect(ev)
		elseif (LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)&loc==0 and c:IsRelateToChain() and c:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			Duel.Damage(1-tp,1200,REASON_EFFECT)
		end
	end
end
function s.negfilter(c,g)
	return aux.NegateAnyFilter(c) and g:IsContains(c)
end
function s.seletg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
end
function s.seleop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,5))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,6))+1
	else return end
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
		local tc=g:GetFirst()
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e2:SetValue(s.fuslimit)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e4)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,8))
	elseif op~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,7))
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
		local tc=g:GetFirst()
		Duel.HintSelection(g)
		if tc:IsControler(tp) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local m=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
		local nseq=math.log(bit.rshift(m,16),2)
		Duel.MoveSequence(tc,nseq)
		local cg=c:GetColumnGroup()
		if c:IsRelateToChain() and c:IsFaceup() and Duel.GetMatchingGroupCount(s.negfilter,tp,0,LOCATION_ONFIELD,nil,cg)>0 then
			Duel.BreakEffect()
			local g=Duel.GetMatchingGroup(s.negfilter,tp,0,LOCATION_ONFIELD,nil,cg)
			for tc2 in aux.Next(g) do
				Duel.NegateRelatedChain(tc2,RESET_TURN_SET)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc2:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc2:RegisterEffect(e2)
			end
		end
	end
end
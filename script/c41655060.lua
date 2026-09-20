-- 烬雪的霜君·格罗姆海尔
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,s.matfilter,nil,nil,aux.NonTuner(nil),1,1)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	--attackall
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--atk up
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68507541,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.atkcon1)
	e3:SetOperation(s.atkop1)
	c:RegisterEffect(e3)
	--Destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.desreptg)
	c:RegisterEffect(e4)
	--splimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTargetRange(1,0)
	e5:SetTarget(s.splimit)
	c:RegisterEffect(e5)
end
function s.matfilter(c,syncard)
	return c:IsTuner(syncard) or c:IsType(TYPE_NORMAL)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.tdfilter2(c)
	return c:IsSetCard(0xe93) and c:IsAbleToDeck()
end
function s.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsDiscardable()
end
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsChainDisablable(0) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.DiscardHand(1-tp,s.costfilter,1,1,REASON_EFFECT+REASON_DISCARD)
		Duel.NegateEffect(0)
		return
	end
	if Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_HAND,0,2,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_HAND,0,2,2,nil)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		for tc in aux.Next(dg) do
			if tc:IsCanBeDisabledByEffect(e) then
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
		Duel.BreakEffect()
		Duel.AdjustInstantly()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttacker()
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(s.atkval)
		c:RegisterEffect(e1)
	end
end
function s.vfilter(c)
	return c:IsSetCard(0xe93) and c:IsFaceup()
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.vfilter,c:GetControler(),LOCATION_EXTRA,0,nil)
	return g:GetClassCount(Card.GetCode)*250
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,41655000) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,41655000)
		Duel.SendtoHand(g,nil,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xe93) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

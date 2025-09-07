--N-CH039 《希望姬战妃-爱尔比斯·特瓦莱特》
function c10110039.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	--special summon rule
	local e01=Effect.CreateEffect(c)
	e01:SetType(EFFECT_TYPE_FIELD)
	e01:SetCode(EFFECT_SPSUMMON_PROC)
	e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e01:SetRange(LOCATION_EXTRA)
	e01:SetCondition(c10110039.sprcon)
	e01:SetTarget(c10110039.sprtg)
	e01:SetOperation(c10110039.sprop)
	c:RegisterEffect(e01)
	Duel.AddCustomActivityCounter(10110039,ACTIVITY_CHAIN,c10110039.chainfilter)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c10110039.atktg)
	e1:SetOperation(c10110039.atkop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10110039)
	e2:SetTarget(c10110039.distg)
	e2:SetOperation(c10110039.disop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,10110039+1)
	e3:SetCondition(c10110039.spcon)
	e3:SetTarget(c10110039.sptg)
	e3:SetOperation(c10110039.spop)
	c:RegisterEffect(e3)
end
function c10110039.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsSetCard(0x314) and re:IsActiveType(TYPE_MONSTER))
end
function c10110039.spsfilter(c,fc,tp)
	return c:IsSetCard(0x314) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0
end
function c10110039.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return (Duel.GetCustomActivityCount(10110039,tp,ACTIVITY_CHAIN)~=0 or Duel.GetCustomActivityCount(10110039,1-tp,ACTIVITY_CHAIN)~=0)
		and Duel.CheckReleaseGroupEx(tp,c10110039.spsfilter,1,REASON_SPSUMMON,false,nil,c,tp)
end
function c10110039.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c10110039.spsfilter,nil,c,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function c10110039.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	Duel.Release(tc,REASON_SPSUMMON)
end
function c10110039.filter1(c)
	return c:IsFaceupEx() and (c:IsSetCard(0x314) or c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS))
end
function c10110039.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=Duel.GetMatchingGroupCount(c10110039.filter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)*500
	if chk==0 then return atk>0 end
end
function c10110039.atkop(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetMatchingGroupCount(c10110039.filter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)*500
	if atk<1 then return end
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local dg=Group.CreateGroup()
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		while tc do
			local preatk=tc:GetAttack()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if preatk~=0 and tc:IsAttack(0) then dg:AddCard(tc) end
			tc=g:GetNext()
		end
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function c10110039.filter(c)
	return aux.NegateMonsterFilter(c) and c:IsAttackPos()
end
function c10110039.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c10110039.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(c10110039.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
function c10110039.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c10110039.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
function c10110039.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c10110039.spfilter(c,e,tp)
	return c:IsCode(10100039) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c10110039.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10110039.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c10110039.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c10110039.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c10110039.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
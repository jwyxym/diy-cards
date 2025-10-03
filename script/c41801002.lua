local m=41801002
local cm=_G["c"..m]
cm.name="天底根须//芽孢"
function cm.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.destg)
	e1:SetOperation(cm.desop)
	c:RegisterEffect(e1)
	--lv
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,m+100)
	e2:SetTarget(cm.cntg)
	e2:SetOperation(cm.cnop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(cm.spcon2)
	e4:SetTarget(cm.sptg2)
	e4:SetOperation(cm.spop2)
	c:RegisterEffect(e4)
end
function cm.des1filter(c)
	return c:IsFaceup() and (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618))
end
function cm.des2filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingTarget(cm.des1filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(cm.des2filter,tp,LOCATION_PZONE,0,1,nil,e) end
	local ct=Duel.GetMatchingGroupCount(cm.des2filter,tp,LOCATION_PZONE,0,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,cm.des1filter,tp,LOCATION_MZONE,0,1,ct,nil)
	local ect=g1:GetCount()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,cm.des2filter,tp,LOCATION_PZONE,0,ect,ect,nil,e)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,g2:GetCount(),0,0)
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	local lvg=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if lvg:GetCount()>0 then
		local tc=lvg:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=lvg:GetNext()
		end
	end
	local desg=tg:Filter(Card.IsLocation,nil,LOCATION_PZONE)
	if desg:GetCount()>0 then
		Duel.Destroy(desg,REASON_EFFECT)
	end
end
function cm.cnfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618))
end
function cm.cntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.cnfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.cnfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cm.cnfilter,tp,LOCATION_MZONE,0,1,2,nil)
end
function cm.cnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
function cm.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
function cm.sp2filter(c,e,tp)
	return c:IsCode(m) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_MONSTER)
end
function cm.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.sp2filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function cm.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.sp2filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(cm.atkcon)
	e1:SetTarget(cm.atktg)
	e1:SetValue(900)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function cm.atktg(e,c)
	return c:IsRace(RACE_WYRM) and c:IsFaceup()
end
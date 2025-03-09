--
function c20020016.initial_effect(c)
	c:SetUniqueOnField(1,0,20020016)
	--synchro summon
	aux.AddSynchroMixProcedure(c,c20020016.matfilter,nil,nil,aux.FilterBoolFunction(Card.IsSetCard,0xb35),1,99)
	c:EnableReviveLimit()
	--defense attack
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_DEFENSE_ATTACK)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--mat check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c20020016.matcheck)
	c:RegisterEffect(e1)
	--todeck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20020016,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c20020016.tdcon)
	e2:SetTarget(c20020016.tdtg)
	e2:SetOperation(c20020016.tdop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--set trap from deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20020016,3))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(c20020016.settg)
	e3:SetOperation(c20020016.setop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(20020016,1))
	e4:SetCategory(CATEGORY_SUMMON)
	e4:SetTarget(c20020016.stg)
	e4:SetOperation(c20020016.sop)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetDescription(aux.Stringid(20020016,2))
	e5:SetOperation(c20020016.ptop)
	c:RegisterEffect(e5)
end
function c20020016.matfilter(c,syncard)
	return c:IsTuner(syncard) or c:IsSetCard(0xb35)
end
function c20020016.matcheck(e,c)
	local ct=c:GetMaterial():Filter(Card.IsSetCard,nil,0xb35):GetClassCount(Card.GetOriginalAttribute)
	e:SetLabel(ct)
end
function c20020016.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c20020016.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	local ct=e:GetLabelObject():GetLabel()
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) and ct>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c20020016.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function c20020016.setfilter(c)
	return c:IsSetCard(0xb35) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c20020016.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20020016.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c20020016.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c20020016.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function c20020016.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20020016.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c20020016.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsSetCard(0xb35)
end
function c20020016.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c20020016.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
function c20020016.ptop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c20020016.pttg)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
end
function c20020016.pttg(e,c)
	return c:IsSetCard(0xb35)
end
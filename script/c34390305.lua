--通关白银之城的Master&Love
function c34390305.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34390305,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,34390305)
	e1:SetCost(c34390305.spcost)
	e1:SetCondition(c34390305.spcon)
	e1:SetTarget(c34390305.sptg)
	e1:SetOperation(c34390305.spop)
	c:RegisterEffect(e1)
	--reflect battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34390305,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,34390305+1)
	e3:SetCondition(c34390305.thcon)
	e3:SetTarget(c34390305.thtg)
	e3:SetOperation(c34390305.thop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34390305,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SSET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,34390305+1)
	e4:SetCondition(c34390305.thcon2)
	e4:SetTarget(c34390305.thtg)
	e4:SetOperation(c34390305.thop)
	c:RegisterEffect(e4)
end
--spsummon
function c34390305.cpfilter(c)
	return c:IsSetCard(0x17e) and c:GetType()==TYPE_TRAP and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(false,true,false)
end
function c34390305.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c34390305.cpfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,c34390305.cpfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local te,ceg,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.SendtoGrave(tc,REASON_COST)
end
function c34390305.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp or (Duel.GetTurnPlayer()~=tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function c34390305.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c34390305.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local te=e:GetLabelObject()
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
--to hand
function c34390305.gcfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
function c34390305.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP)
end
function c34390305.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return true
end
function c34390305.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(c34390305.gcfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function c34390305.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SendtoHand(c,nil,REASON_EFFECT) and Duel.IsExistingMatchingCard(c34390305.gcfilter,tp,0,LOCATION_MZONE,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local cg=Duel.SelectMatchingCard(tp,c34390305.gcfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if cg:GetCount()>0 then
			Duel.HintSelection(cg)
			Duel.GetControl(cg:GetFirst(),tp)
		end
	end
end

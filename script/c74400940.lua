local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddSetNameMonsterList(c,0x742)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.exccon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.releasable(c)
	return c:IsReleasableByEffect()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.releasable,1-tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeTargetCard(ev,Group.CreateGroup())
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.releasable,1-tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(1-tp,s.releasable,1-tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
function s.exccon(e)
	return aux.exccon(e)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x742) and c:IsType(TYPE_RITUAL)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		if Duel.GetCurrentPhase()==PHASE_END then
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.descon)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END)
		end
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() and tc:IsControler(tp) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
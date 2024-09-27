--
function c21300520.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,21300520)
	e1:SetCondition(c21300520.condition)
	e1:SetTarget(c21300520.target)
	e1:SetOperation(c21300520.activate)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,21300519)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21300520.sptg)
	e2:SetOperation(c21300520.spop)
	c:RegisterEffect(e2)
end
function c21300520.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetControler()~=tp and Duel.IsExistingMatchingCard(c21300520.filter,tp,LOCATION_MZONE,0,1,nil)
end
function c21300520.filter(c)
	return c:IsSetCard(0x674) and c:IsFaceup()
end
function c21300520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local sg=Duel.GetAttacker()
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,0,0)
end
function c21300520.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetAttacker()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function c21300520.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_XYZ) and c:IsRace(RACE_WYRM)
end
function c21300520.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c21300520.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c21300520.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c21300520.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c21300520.matfilter(c)
	return c:IsCanOverlay()
end
function c21300520.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		if Duel.IsExistingMatchingCard(c21300520.matfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21300520,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local g=Duel.SelectMatchingCard(tp,c21300520.matfilter,tp,LOCATION_HAND,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.Overlay(tc,g)
			end
		end
	end
end
--君临的红龙
function c31280325.initial_effect(c)
	--墓地苏生
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,31280325+EFFECT_COUNT_CODE_OATH)
    e1:SetCost(c31280325.cost)
	e1:SetTarget(c31280325.target)
	e1:SetOperation(c31280325.activate)
	c:RegisterEffect(e1)
end
function c31280325.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1400) end
	Duel.PayLPCost(tp,1400)
end
function c31280325.filter(c,e,tp)
	return c:IsSetCard(0xca3) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c),POS_FACEUP_DEFENSE)
end
function c31280325.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31280325.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280325.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31280325.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c31280325.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP_DEFENSE)~=0 
    	and Duel.SelectYesNo(tp,aux.Stringid(31280325,0))  then
		Duel.BreakEffect()
		local b1=Duel.IsExistingMatchingCard(c31280325.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_RITUAL) 
        	and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		if b1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
			local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
			if g:GetCount()>0 then
				local tg=g:GetFirst()
                Duel.HintSelection(g)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tg:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CANNOT_TRIGGER)
				tg:RegisterEffect(e2)
            end    
		end
        local b2=Duel.IsExistingMatchingCard(c31280325.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) 
        	and Duel.IsExistingMatchingCard(c31280325.filter1,tp,LOCATION_MZONE,0,1,nil) 
            and Duel.IsExistingMatchingCard(c31280325.filter2,tp,LOCATION_GRAVE,0,1,nil)
        if b2 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tmg=Duel.SelectMatchingCard(tp,c31280325.filter1,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			local mg=Duel.SelectMatchingCard(tp,c31280325.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
			if mg:GetCount()>0 then
				Duel.Overlay(tmg,mg)
            end    
		end
    end   
end            
function c31280325.cfilter(c,type)
	return c:IsFaceup() and c:IsType(type)
end
function c31280325.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xca3) and c:IsType(TYPE_XYZ)
end
function c31280325.filter2(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
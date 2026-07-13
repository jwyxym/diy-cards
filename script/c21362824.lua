--哀悼恶魔的激战
function c21362824.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)  
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET) 
	e1:SetCountLimit(1,21362824)
	e1:SetCost(c21362824.cost)
	e1:SetTarget(c21362824.target)
	e1:SetOperation(c21362824.activate)
	c:RegisterEffect(e1)
end
function c21362824.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end 
function c21362824.rlfil1(c,tp) 
	return c:IsReleasableByEffect() and Duel.CheckReleaseGroup(tp,nil,1,c,tp)
end 
function c21362824.rlfil2(c,tp) 
	return c:IsReleasableByEffect() 
end 
function c21362824.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c21362824.rlfil1(chkc,tp) end 
	if chk==0 then return Duel.IsExistingTarget(c21362824.rlfil1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end 
	local g=Duel.SelectTarget(tp,c21362824.rlfil2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,g:GetCount(),0,0)
end
function c21362824.xspfil1(c,e,tp) 
	return c:IsSetCard(0xba38) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 
end 
function c21362824.xspfil2(c,e,tp) 
	return c:IsSetCard(0xba38) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end 
function c21362824.xspfil3(c,e,tp) 
	return c:IsSetCard(0xba38) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end 
function c21362824.xspfil4(c,e,tp) 
	return c:IsSetCard(0xba38) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end 
function c21362824.xspfil5(c,e,tp) 
	return c:IsSetCard(0xba38) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end 
function c21362824.xspfil6(c,e,tp) 
	return c:IsSetCard(0xba38) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end 
function c21362824.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then 
		if tc:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(c21362824.xspfil1,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21362824,1)) then 
			local sc=Duel.SelectMatchingCard(tp,c21362824.xspfil1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()  
			Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP) 
			sc:CompleteProcedure()
		end 
		if tc:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(c21362824.xspfil2,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21362824,1)) then 
			local sc=Duel.SelectMatchingCard(tp,c21362824.xspfil2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()  
			Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) 
			sc:CompleteProcedure()
		end 
		if tc:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(c21362824.xspfil3,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21362824,1)) then 
			local sc=Duel.SelectMatchingCard(tp,c21362824.xspfil3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()  
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) 
			sc:CompleteProcedure()
		end 
		if tc:IsType(TYPE_LINK) and Duel.IsExistingMatchingCard(c21362824.xspfil4,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21362824,1)) then 
			local sc=Duel.SelectMatchingCard(tp,c21362824.xspfil4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()  
			Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP) 
			sc:CompleteProcedure()
		end 
		if tc:IsType(TYPE_PENDULUM) and Duel.IsExistingMatchingCard(c21362824.xspfil5,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21362824,1)) then 
			local sc=Duel.SelectMatchingCard(tp,c21362824.xspfil5,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()  
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)  
		end 
		if tc:IsType(TYPE_RITUAL) and Duel.IsExistingMatchingCard(c21362824.xspfil6,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21362824,1)) then 
			local sc=Duel.SelectMatchingCard(tp,c21362824.xspfil6,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()  
			Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) 
			sc:CompleteProcedure() 
		end 
	end
end


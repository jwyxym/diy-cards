--魔诞 魔唤师 吉奥斯
function c21362818.initial_effect(c)
	c:SetSPSummonOnce(21362818)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xba38),2,true) 
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	--esp 
	local e1=Effect.CreateEffect(c)
	--e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION) 
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1,21362818)
	--e1:SetCost(c21362818.espcost)
	--e1:SetTarget(c21362818.esptg)
	--e1:SetOperation(c21362818.espop)
	e1:SetCost(c21362818.esetcost)
	e1:SetTarget(c21362818.esettg)
	e1:SetOperation(c21362818.esetop)
	c:RegisterEffect(e1)
	--xx
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_TO_GRAVE) 
	e2:SetProperty(EFFECT_FLAG_DELAY)  
	e2:SetCountLimit(1,21362819) 
	e2:SetTarget(c21362818.xxtg)
	e2:SetOperation(c21362818.xxop)
	c:RegisterEffect(e2)
end
function c21362818.ctfil(c)  
	return c:IsAbleToGraveAsCost() and c:IsFaceup() and c:IsRace(RACE_FIEND) 
end 
function c21362818.esetcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362818.ctfil,tp,LOCATION_REMOVED,0,1,nil) end 
	local g=Duel.SelectMatchingCard(tp,c21362818.ctfil,tp,LOCATION_REMOVED,0,1,1,nil) 
	Duel.SendtoGrave(g,REASON_COST) 
end
function c21362818.esetfilter(c)
	return c:IsCode(21362824) and c:IsSSetable()
end
function c21362818.esettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362818.esetfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c21362818.esetop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c21362818.esetfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
function c21362818.espfil(c,e,tp)
	return c:IsSetCard(0xba38) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 
end
function c21362818.esptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362818.espfil,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c21362818.espop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c21362818.espfil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) 
		tc:CompleteProcedure() 
	end
end
function c21362818.xxtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end 
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(21362818,1)},{b2,aux.Stringid(21362818,2)})  
	e:SetLabel(op) 
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(21362818,1))
	end
	if op==2 then
		e:SetCategory(CATEGORY_TODECK) 
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(21362818,2)) 
	end  

	
end
function c21362818.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel() 
	if op==1 then 
		if c:IsRelateToEffect(e) then 
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
		end 
	elseif op==2 then 
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end 
end 






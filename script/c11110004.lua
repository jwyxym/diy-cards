--杜丝娜瑞尔·源心
local m=11110004
local cm=_G["c"..m]
function c11110004.initial_effect(c)
	 local e3=Effect.CreateEffect(c)  
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND) 
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e3:SetCode(EVENT_TO_GRAVE) 
	e3:SetProperty(EFFECT_FLAG_DELAY)  
	e3:SetCountLimit(1,m)
	e3:SetCondition(function(e) 
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetTarget(cm.thtg) 
	e3:SetOperation(cm.thop) 
	c:RegisterEffect(e3)
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,m+1000)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cm.drtg)
	e2:SetOperation(cm.drop)
	c:RegisterEffect(e2)
end
function cm.filter2(c,e,tp,g) 
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk) 
local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(0xa61) and (c:IsAbleToDeck() or c:IsAbleToExtra()) and c:IsCanBeSynchroMaterial() end,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(cm.matgck,2,99,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end 

end 
function cm.drop(e,tp,eg,ep,ev,re,r,rp)  
	local c=e:GetHandler() 
	local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(0xa61) and (c:IsAbleToDeck() or c:IsAbleToExtra()) and c:IsCanBeSynchroMaterial() end,tp,LOCATION_GRAVE,0,e:GetHandler())  
	if g:CheckSubGroup(cm.matgck,2,99,e,tp) then 
		local mg=g:SelectSubGroup(tp,cm.matgck,false,2,99,e,tp)
		local sc=Duel.SelectMatchingCard(tp,cm.espfil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg):GetFirst()
		Duel.ConfirmCards(1-tp,sc)
		  
		sc:SetMaterial(mg)   
		Duel.SendtoDeck(mg,tp,2,REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)   
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()  
	end   
end 
function cm.espfil(c,e,tp,mg)  
	return c:IsType(TYPE_SYNCHRO) and c:GetLevel()==mg:GetSum(Card.GetLevel) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false) 
end 
function cm.matgck(g,e,tp) 
	return Duel.IsExistingMatchingCard(cm.espfil,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end 
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0xa61) end 
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end 
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler() 
local aa=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_MZONE,0,1,1,nil,0xa61)
if Duel.SendtoHand(aa,tp,REASON_EFFECT)~=0 then
Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
local bb=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND,0,1,1,nil,RACE_REPTILE)
Duel.SendtoGrave(bb,REASON_EFFECT)
end
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.splimit(e,c)
return not (c:IsRace(RACE_REPTILE))
end 












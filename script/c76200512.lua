--于龙骸中诞生
function c76200512.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--Activate 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN)  
	e1:SetCountLimit(1,76200512)	
	e1:SetTarget(c76200512.actg) 
	e1:SetOperation(c76200512.acop) 
	c:RegisterEffect(e1) 
	--To hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,76200512)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c76200512.thtg)
	e2:SetOperation(c76200512.thop)
	c:RegisterEffect(e2)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c76200512.handcon)
	c:RegisterEffect(e2)
end  
function c76200512.stgfil(c,e,tp) 
	return c:IsFaceup() and c:IsReleasable() and (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(8)) and Duel.IsExistingMatchingCard(c76200512.spfil,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end 
function c76200512.spfil(c,e,tp,sc) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(sc:GetLevel()) and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0 
end 
function c76200512.actg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c76200512.stgfil,tp,LOCATION_MZONE,0,1,nil,e,tp) end 
	local tc=Duel.SelectMatchingCard(tp,c76200512.stgfil,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst() 
	e:SetLabelObject(tc) 
	Duel.Release(tc,REASON_COST) 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK) 
end
function c76200512.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and Duel.IsExistingMatchingCard(c76200512.spfil,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc) then 
		local sg=Duel.SelectMatchingCard(tp,c76200512.spfil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end 
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c76200512.thfilter(c)
	return (c:IsCode(76200500) or aux.IsCodeListed(c,76200500)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c76200512.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76200512.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c76200512.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c76200512.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c76200512.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
function c76200512.filter(c)
	return c:IsFaceup() and (c:IsCode(76200500) or aux.IsCodeListed(c,76200500))
end
function c76200512.handcon(e)
	return Duel.IsExistingMatchingCard(c76200512.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end


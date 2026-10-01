--盗贼浮世绘·初登场
function c21363703.initial_effect(c)
	aux.AddCodeList(c,21363700) 
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)  
	c:RegisterEffect(e1)
	--SpecialSummon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE) 
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN) 
	e1:SetTarget(c21363703.sptg)
	e1:SetOperation(c21363703.spop)
	c:RegisterEffect(e1)  
	--dtd
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c21363703.dtdtg)
	e2:SetOperation(c21363703.dtdop)
	c:RegisterEffect(e2)
	--disable
	--local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(21363703,1))
	--e1:SetCategory(CATEGORY_DISABLE)
	--e1:SetType(EFFECT_TYPE_ACTIVATE)
	--e1:SetCode(EVENT_CHAINING) 
	--e1:SetCountLimit(1,21363703+EFFECT_COUNT_CODE_OATH) 
	--e1:SetCondition(c21363703.discon)
	--e1:SetTarget(c21363703.distg)
	--e1:SetOperation(c21363703.disop)
	--c:RegisterEffect(e1)
	--set
	--local e2=Effect.CreateEffect(c) 
	--e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	--e2:SetCode(EVENT_TO_GRAVE)
	--e2:SetProperty(EFFECT_FLAG_DELAY) 
	--e2:SetCondition(c21363703.setcon)
	--e2:SetTarget(c21363703.settg)
	--e2:SetOperation(c21363703.setop)
	--c:RegisterEffect(e2)
	--act in hand
	--local e2=Effect.CreateEffect(c)
	--e2:SetDescription(aux.Stringid(21363703,0))
	--e2:SetType(EFFECT_TYPE_SINGLE)
	--e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	--e2:SetCondition(c21363703.handcon)
	--c:RegisterEffect(e2)
	--act in set turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetDescription(aux.Stringid(21363703,0))
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(c21363703.cost)
	c:RegisterEffect(e0)
end
function c21363703.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end 
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil) 
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)  
end
function c21363703.spfilter(c,e,tp)
	return c:IsCode(21363700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c21363703.setfil(c)
	return not c:IsCode(21363703) and aux.IsCodeListed(c,21363700) and c:IsSSetable() and c:IsType(TYPE_TRAP)
end
function c21363703.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363703.setfil,tp,LOCATION_DECK,0,1,nil) end 
end 
function c21363703.spop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if c:IsRelateToEffect(e) and c:IsAbleToGrave() and Duel.IsExistingMatchingCard(c21363703.setfil,tp,LOCATION_DECK,0,1,nil) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 then 
		local tc=Duel.SelectMatchingCard(tp,c21363703.setfil,tp,LOCATION_DECK,0,1,1,nil):GetFirst() 
		if Duel.SSet(tp,tc)~=0 then   
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON) 
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21363703,2)) then
				Duel.BreakEffect() 
				local g=Duel.SelectMatchingCard(tp,c21363703.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)  
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
			end
		end 
	end 
end
function c21363703.dtdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end 
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and e:GetHandler():IsAbleToDeck() end 
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0) 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c21363703.dtdop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then 
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT) 
	end 
end 

function c21363703.filter(c)
	return c:IsFaceup() and c:IsCode(21363700) 
end
function c21363703.handcon(e)
	return Duel.IsExistingMatchingCard(c21363703.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c21363703.discon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainDisablable(ev) then return false end
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and (aux.IsCodeListed(te:GetHandler(),21363700) or (te:GetHandler():IsRace(RACE_WARRIOR) and te:GetHandler():IsAttribute(ATTRIBUTE_WIND))) and p==tp and rp==1-tp
end
function c21363703.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c21363703.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c21363703.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) 
end
function c21363703.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c21363703.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
		Duel.SSet(tp,c) 
	end
end 






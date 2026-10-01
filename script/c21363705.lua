--盗贼浮世绘·义之术
function c21363705.initial_effect(c)
	aux.AddCodeList(c,21363700)
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)  
	c:RegisterEffect(e1)
	--to hand 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE) 
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN) 
	e1:SetTarget(c21363705.xthtg)
	e1:SetOperation(c21363705.xthop)
	c:RegisterEffect(e1) 
	--Activate
	--local e1=Effect.CreateEffect(c)
	--e1:SetCategory(CATEGORY_POSITION)
	--e1:SetType(EFFECT_TYPE_ACTIVATE)
	--e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	--e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetTarget(c21363705.target)
	--e1:SetOperation(c21363705.activate)
	--c:RegisterEffect(e1)
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F) 
	e2:SetCode(EVENT_REMOVE)
	e2:SetTarget(c21363705.thtg)
	e2:SetOperation(c21363705.thop)
	c:RegisterEffect(e2)
	--act in hand
	--local e2=Effect.CreateEffect(c)
	--e2:SetDescription(aux.Stringid(21363705,0))
	--e2:SetType(EFFECT_TYPE_SINGLE)
	--e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	--e2:SetCondition(c21363705.handcon)
	--c:RegisterEffect(e2)
	--act in set turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetDescription(aux.Stringid(21363705,0))
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(c21363705.cost)
	c:RegisterEffect(e0)
end
function c21363705.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end 
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil) 
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)  
end
function c21363705.xthfilter(c,e,tp)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function c21363705.setfil(c)
	return not c:IsCode(21363703) and aux.IsCodeListed(c,21363700) and c:IsSSetable() and c:IsType(TYPE_TRAP)
end
function c21363705.xthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363705.setfil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_DECK)
end 
function c21363705.xthop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToGrave() and Duel.SendtoGrave(c,REASON_EFFECT)~=0 then 
		local tc=Duel.SelectMatchingCard(tp,c21363705.setfil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil):GetFirst()  
		local g=Duel.GetMatchingGroup(c21363705.xthfilter,1-tp,LOCATION_DECK,0, nil)
		if Duel.SSet(tp,tc)~=0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21363705,2)) then 
			local sg=g:RandomSelect(tp,1) 
			if sg:GetCount()>0 and Duel.SendtoHand(sg,tp,REASON_EFFECT)~=0 then 
				Duel.ConfirmCards(1-tp,sg) 
			end 
		end 
	end 
end
function c21363705.filter(c)
	return c:IsFaceup() and c:IsCode(21363700) 
end
function c21363705.handcon(e)
	return Duel.IsExistingMatchingCard(c21363705.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c21363705.target(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end 
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
function c21363705.csetfil(c) 
	return c:IsFaceup() and c:IsCanTurnSet() and not c:IsCode(21363700) 
end 
function c21363705.activate(e,tp,eg,ep,ev,re,r,rp)   
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEUP_ATTACK)~=0 then
		local sg=Duel.GetMatchingGroup(c21363705.csetfil,tp,LOCATION_MZONE,LOCATION_MZONE,nil) 
		if sg:GetCount()>0 then 
			Duel.BreakEffect() 
			Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		end 
	end
end
function c21363705.thfilter(c)
	return aux.IsCodeListed(c,21363700) and not c:IsCode(21363701) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c21363705.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end   
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0) 
end
function c21363705.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21363705.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT) 
		Duel.ConfirmCards(1-tp,g) 
		if c:IsRelateToEffect(e) then 
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT) 
		end  
	end
end

--大盗 石川五右卫门
function c21363700.initial_effect(c) 
	aux.AddCodeList(c,21363700)
	--summon with no tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21363700,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c21363700.ntcon)
	c:RegisterEffect(e1)  
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21363700,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS) 
	e2:SetCountLimit(1,21363700)
	e2:SetTarget(c21363700.thtg)
	e2:SetOperation(c21363700.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)   
	--
	local e5=Effect.CreateEffect(c) 
	e5:SetDescription(aux.Stringid(21363700,2))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,11363700)
	e5:SetCost(c21363700.rmcost)
	e5:SetTarget(c21363700.rmtg)
	e5:SetOperation(c21363700.rmop)
	c:RegisterEffect(e5)
end
function c21363700.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c21363700.thfilter(c)
	return aux.IsCodeListed(c,21363700) and not c:IsCode(21363700) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c21363700.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363700.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c21363700.thop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21363700.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)  
	end
end
function c21363700.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) and e:GetHandler():IsCanChangePosition() end
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
function c21363700.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function c21363700.rmop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil) 
	if rg:GetCount()>0 then 
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) 
	end 
end 






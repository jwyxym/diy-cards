--祭法魔女 深冬学者
local m=21300106
local cm=_G["c"..m]
function c21300106.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,3,cm.lcheck) 
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,m)
	e3:SetCost(cm.cost)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(cm.tg)
	e3:SetOperation(cm.operation)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.thcon)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)
end
function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x676)
end
function cm.spfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemoveAsCost()
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.ckfilter(c)
	return c:IsSetCard(0x676) and c:IsAbleToHand()
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
	local g=Duel.GetMatchingGroup(cm.ckfilter,tp,LOCATION_DECK,0,nil)
	return g:GetClassCount(Card.GetCode)>=3  end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.ckfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:Select(1-tp,1,1,nil)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		local tc=tg:GetFirst()
		sg:RemoveCard(tc)
		Duel.ShuffleDeck(tp)
	end
end

function cm.spnfilter(c,e,tp)
	return c:IsSetCard(0x676)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(cm.spnfilter,1,nil,e,tp)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=eg:Filter(cm.spnfilter,nil,tp)
	local tc=g:Select(tp,1,1,nil)
	if #tc>0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end








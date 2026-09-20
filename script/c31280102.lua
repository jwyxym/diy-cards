--友魂少女·露娜
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--加入手卡    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
    e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.confilter(c)
	return not (c:IsRace(RACE_ZOMBIE) and c:IsFaceup())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and Duel.GetMZoneCount(tp,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,tp)
    	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.setfilter(c)
	return aux.IsCodeListed(c,id) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c,tp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) 
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then 
    	Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
        	Duel.SSet(tp,g)
        end
    end
end
function s.costfilter(c)
	return aux.IsCodeListed(c,id) and c:IsAbleToDeckOrExtraAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
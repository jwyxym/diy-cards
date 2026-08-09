--丹紫抵御者·安涅儿
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--种族视为机械族
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
    e0:SetCondition(s.racecon)
	e0:SetValue(RACE_MACHINE)
	c:RegisterEffect(e0)
	--卡组检索
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)    
	--送墓代替    
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	c:RegisterEffect(e3)
end
function s.racecon(e)
    if e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	return true
end
function s.costfilter(c,res)
	local b1=res and c:IsLocation(LOCATION_DECK) and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
    local b2=c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	return c:IsSetCard(0x9caa) and c:IsAbleToGraveAsCost() and (b1 or b2)
end
function s.excostfilter(c,tp)
	return c:IsFaceup() and c:IsHasEffect(id,tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local fg=Duel.GetMatchingGroup(s.excostfilter,tp,LOCATION_MZONE,0,nil,tp)
	local res=fg:GetCount()>0 and c:IsSetCard(0x9caa)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,c,res) end    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,1,c,res)
    if g:GetFirst():IsLocation(LOCATION_DECK) then
    	Duel.Hint(HINT_CARD,0,id)
    	local sg=fg
        if fg:GetCount()>1 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            sg=fg:Select(tp,1,1,nil)
        end
        Duel.HintSelection(sg)
        local tc=sg:GetFirst()
        local te=tc:IsHasEffect(id,tp)
        if te then
        	te:UseCountLimit(tp)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
        end
    end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thfilter(c)
	return aux.IsCodeListed(c,id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
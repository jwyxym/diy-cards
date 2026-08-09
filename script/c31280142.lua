--禁断之腕·尼古拉
local s,id,o=GetID()
function s.initial_effect(c)
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
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
    e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--送去墓地    
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
    s.machine_zombie_be_tograve_effect=e2
end
function s.racecon(e)
    if e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	return true
end
function s.thfilter(c)
	return c:IsSetCard(0x9caa) and c:IsAbleToHand() 
end
function s.costfilter(c,tp,res)
	local b1=res and c:IsLocation(LOCATION_DECK) and not c:IsCode(31280120) and c:IsType(TYPE_MONSTER)
    local b2=c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	return c:IsSetCard(0x9caa) and c:IsAbleToGraveAsCost() and (b1 or b2) 
    	and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c)
end
function s.excostfilter(c,tp)
	return c:IsFaceup() and c:IsHasEffect(31280120,tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local fg=Duel.GetMatchingGroup(s.excostfilter,tp,LOCATION_MZONE,0,nil,tp)
	local res=fg:GetCount()>0 and c:IsSetCard(0x9caa)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,c,tp,res) end    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,1,c,tp,res)
    if g:GetFirst():IsLocation(LOCATION_DECK) then
    	Duel.Hint(HINT_CARD,0,31280120)
    	local sg=fg
        if fg:GetCount()>1 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            sg=fg:Select(tp,1,1,nil)
        end
        Duel.HintSelection(sg)
        local tc=sg:GetFirst()
        local te=tc:IsHasEffect(31280120,tp)
        if te then
        	te:UseCountLimit(tp)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31280120,1))
        end
    end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
    	Duel.ConfirmCards(1-tp,tc)
        local type=tc:GetOriginalType()&0x7
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_TO_HAND)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.thlimit)
		e1:SetLabel(type)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
    end
    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)       
end
function s.thlimit(e,c,tp,re)
	return c:GetOriginalType()&e:GetLabel()~=0 and re and re:GetHandler():GetOriginalCode()==id
end
function s.splimit(e,c)
	return not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE)) and c:IsLocation(LOCATION_EXTRA)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.tgfilter(c)
	return c:IsSetCard(0x9caa) and c:IsType(TYPE_MONSTER) and not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
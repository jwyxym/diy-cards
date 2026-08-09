--不朽机骸 机甲傀儡
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
	--送去墓地    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
    e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--除外    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
    s.machine_zombie_be_tograve_effect=e2
end
function s.racecon(e)
    if e:GetHandler():IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	return true
end
function s.tgfilter(c)
	return c:IsAbleToGrave() and not c:IsLevel(5) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9caa)
end
function s.costfilter(c,tp,res)
	local b1=res and c:IsLocation(LOCATION_DECK) and not c:IsCode(31280120) and c:IsType(TYPE_MONSTER)
    local b2=c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	return c:IsSetCard(0x9caa) and c:IsAbleToGraveAsCost() and (b1 or b2) 
    	and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,c)
end
function s.excostfilter(c,tp)
	return c:IsFaceup() and c:IsHasEffect(31280120,tp)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
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
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
    end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
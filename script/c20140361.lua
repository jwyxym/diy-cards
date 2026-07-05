local s,id,o=GetID()
function s.initial_effect(c)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.checkop)
    c:RegisterEffect(e0)
    -- ① 召特召→检索闪星魔陷，速攻特召→炸1魔陷代替
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    local e1s=e1:Clone()
    e1s:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1s)
    -- ②
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.con2)
    e2:SetCost(s.cost)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    local e2g=e2:Clone()
    e2g:SetCode(EVENT_TO_GRAVE)
    c:RegisterEffect(e2g)
end
function s.counterfilter(c)
    return not c:IsLocation(LOCATION_EXTRA) or not c:IsLevelAbove(2)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if not re then return end
    if re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsType(TYPE_QUICKPLAY) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
    end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	local e_self=Effect.CreateEffect(e:GetHandler())
    e_self:SetType(EFFECT_TYPE_FIELD)
    e_self:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e_self:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e_self:SetTargetRange(1,0)
    e_self:SetTarget(s.sslimit)
    e_self:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e_self,tp)
end
-- ①
function s.filter1(c)
    return c:IsSetCard(0x2b1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.dfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local qp=e:GetHandler():GetFlagEffect(id)>0
    if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>0 then return false end
    if chk==0 then
        if qp then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
            or Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            end
        return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
    end
    if qp then
        e:SetLabel(1)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
    else
        e:SetLabel(0)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
    local b2=e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,5))) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
    elseif b2 then
        local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then Duel.HintSelection(g) 
        Duel.Destroy(g,REASON_EFFECT)
        end
    end
end
function s.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and c:IsLevelAbove(2)
end
-- ②（同前）
function s.con2(e,tp,eg,ep,ev,re,r,rp)
    if e:GetCode()==EVENT_TO_GRAVE then return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD) end
    return true
end
function s.filter2(c)
    return (c:IsCode(24094653) or c:IsCode(95286165)) and c:IsAbleToHand()
end
function s.setfilter2(c)
    return (c:IsCode(24094653) or c:IsCode(95286165)) and c:IsSSetable()
end
function s.anyfilter2(c)
    return (c:IsCode(24094653) or c:IsCode(95286165)) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>0 then return false end
    if chk==0 then return Duel.IsExistingMatchingCard(s.anyfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.anyfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    local b1=s.filter2(tc)
    local b2=s.setfilter2(tc) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    end
    if op==0 and b1 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    elseif b2 then
        Duel.SSet(tp,tc)
    end
end

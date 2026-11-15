local s,id,o=GetID()
local id_dream_inf = 58850000

function s.initial_effect(c)
    aux.AddCodeList(c, id_dream_inf)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.efcon)
    e2:SetTarget(s.eftg)
    e2:SetOperation(s.efop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_CONTROL_CHANGED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+2)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,id_dream_inf)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local targetp=tp
    local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    if ft1>0 and ft2>0 then
        if Duel.SelectOption(tp, aux.Stringid(id,3), aux.Stringid(id,4))==1 then
            targetp=1-tp
        end
    elseif ft2>0 then
        targetp=1-tp
    elseif ft1<=0 then
        return
    end
    Duel.SpecialSummon(c,0,tp,targetp,false,false,POS_FACEUP)
end

function s.efcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end

function s.tgfilter(c)
    return c:IsType(TYPE_MONSTER) and aux.IsCodeOrListed(c, id_dream_inf) and not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end

function s.handfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER) and aux.IsCodeOrListed(c, id_dream_inf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=c:IsPreviousControler(tp) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
    local b2=not c:IsPreviousControler(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
        
    if chk==0 then return b1 or b2 end
    
    if b1 then
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    else
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    end
end

function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPreviousControler(tp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
    else
        if c:IsLocation(LOCATION_GRAVE) then
            Duel.SendtoHand(c,nil,REASON_EFFECT)
        end
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
            if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
        end
    end
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local p = e:GetHandler():GetOwner()
    if chk==0 then return Duel.IsPlayerCanDraw(p,2) end
    Duel.SetTargetPlayer(p)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,2)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if Duel.Draw(p,d,REASON_EFFECT)~=0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)
        local g=Duel.SelectMatchingCard(p,Card.IsDiscardable,p,LOCATION_HAND,0,1,1,nil,REASON_EFFECT+REASON_DISCARD)
        if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD) end
    end
end
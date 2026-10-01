local s,id=GetID()

local ALMISS_LISTED = {
    65200270,
    65200280,
    65200300,
    65200290,
    65200310,
}

function s.thfilter(c)
    for _, code in ipairs(ALMISS_LISTED) do
        if c:IsCode(code) then return true end
    end
    return false
end

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(800)
    e3:SetCondition(s.atkcon)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,400)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,400,REASON_EFFECT)

    local has_almiss=Duel.IsExistingMatchingCard(function(c) return c:IsCode(65200270) end,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)

    if has_almiss and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Draw(tp,1,REASON_EFFECT)
        return
    end

    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()

    local b1=tc:IsAbleToHand()
    local b2=tc:IsAbleToGrave()
    if b1 and b2 then
        if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    elseif b1 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    elseif b2 then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

function s.spcon(e,tp)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:GetAttack()~=c:GetBaseAttack()
    end,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    local atk=c:GetAttack()
    local dg=Duel.GetMatchingGroup(function(tc) 
        return tc:IsFaceup() and tc:GetAttack()<=atk 
    end,tp,0,LOCATION_MZONE,nil)
    if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=dg:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.HintSelection(sg)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end

function s.atkcon(e)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsCode(65200270)
    end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
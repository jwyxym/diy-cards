--格斗天王 卢卡伯恩
local s,id=GetID()

local RIGHT         = LINK_MARKER_RIGHT
local BOTTOM        = LINK_MARKER_BOTTOM
local BOTTOM_RIGHT  = LINK_MARKER_BOTTOM_RIGHT
local BOTTOM_LEFT   = LINK_MARKER_BOTTOM_LEFT
local LEFT          = LINK_MARKER_LEFT

local MOVE1 = {RIGHT, BOTTOM, BOTTOM_RIGHT}                        -- →·↓·↘
local MOVE2 = {RIGHT, BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT}   -- →·↘·↓·↙·←

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.con1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

function s.filter1(c,c2)
    return c:IsFaceup() and not c:IsCode(c2:GetCode())
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,c) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,c,c)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,c,c)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.linkfilter(c)
    return c:IsType(TYPE_LINK) and c:GetLink()==1
end

function s.windfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND)
end

function s.earthfilter(c)
    return c:IsAttribute(ATTRIBUTE_EARTH)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local has_link = Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil)
        if not has_link then return false end
        local b1 = Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
            and (Duel.IsExistingMatchingCard(s.windfilter,tp,LOCATION_HAND,0,1,nil)
                or Duel.IsExistingMatchingCard(s.windfilter,tp,LOCATION_DECK,0,1,nil))
        local c=e:GetHandler()
        local col = c:GetColumnGroup()
        local g = col:Filter(Card.IsControler,nil,1-tp)
        local b2 = #g>0
            and (Duel.IsExistingMatchingCard(s.earthfilter,tp,LOCATION_HAND,0,1,nil)
                or Duel.IsExistingMatchingCard(s.earthfilter,tp,LOCATION_DECK,0,1,nil))
        return b1 or b2
    end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local b1 = Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
        and (Duel.IsExistingMatchingCard(s.windfilter,tp,LOCATION_HAND,0,1,nil)
            or Duel.IsExistingMatchingCard(s.windfilter,tp,LOCATION_DECK,0,1,nil))
    local col = c:GetColumnGroup()
    local g = col:Filter(Card.IsControler,nil,1-tp)
    local b2 = #g>0
        and (Duel.IsExistingMatchingCard(s.earthfilter,tp,LOCATION_HAND,0,1,nil)
            or Duel.IsExistingMatchingCard(s.earthfilter,tp,LOCATION_DECK,0,1,nil))
    
    local sel = aux.SelectFromOptions(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
    local seq, attfilter
    if sel==1 then seq=MOVE1; attfilter=s.windfilter
    else seq=MOVE2; attfilter=s.earthfilter end

    local match=true
    for i=1,#seq do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local sg=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
        if #sg==0 then match=false; break end
        local tc=sg:GetFirst()
        Duel.ConfirmCards(1-tp,tc)
        if tc:GetLinkMarker()~=seq[i] then match=false; break end
    end
    
    if not match then Duel.Damage(tp,100,REASON_EFFECT); return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local ag=Duel.SelectMatchingCard(tp,attfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    if #ag==0 then Duel.Damage(tp,100,REASON_EFFECT); return end
    local ac=ag:GetFirst()
    Duel.ConfirmCards(1-tp,ac)
    if ac:IsLocation(LOCATION_DECK) then
        Duel.ConfirmCards(tp,ac)
        Duel.ShuffleDeck(tp)
    else
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_PUBLIC)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        ac:RegisterEffect(e1)
    end
    
    if sel==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
        if #dg>0 then Duel.Destroy(dg,REASON_EFFECT) end
    else
        local col2=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
        if col2:GetCount()>0 then Duel.Destroy(col2,REASON_EFFECT) end
    end
end

return s
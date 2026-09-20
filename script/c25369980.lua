local s,id=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    -- 超量召唤手续：4星怪兽×2
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c,nil,4,2)

    -- ① 特殊召唤成功时，从卡组·墓地·除外状态特召圣夜骑士或光属性龙族7星
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 双方主要阶段，拔素材破坏对方场上1张表侧卡，暗属性怪兽则吸收为素材
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.descon)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- ① 过滤：圣夜骑士或光属性龙族7星
function s.spfilter(c,e,tp)
    return (c:IsSetCard(SET_HOLY_NIGHT) or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsLevel(7)))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

-- ② 条件：主要阶段
function s.descon(e,tp)
    return Duel.IsMainPhase()
end
-- ② Cost：取除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ② Target：以对方场上1张表侧卡为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ② Operation：破坏，暗属性且进了墓地则吸为素材
function s.desop(e,tp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local is_dark=tc:IsAttribute(ATTRIBUTE_DARK)
    if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
    if is_dark and tc:IsLocation(LOCATION_GRAVE) then
        Duel.Overlay(c,tc)
    end
end<
local s,id=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    -- 规则文本：自己场上有光属性龙族存在的场合，这张卡在盖放的回合也能发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
    e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e0:SetRange(LOCATION_SZONE)
    e0:SetCondition(s.actcon)
    c:RegisterEffect(e0)

    -- ① 从墓地回收1张本家卡，选发特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rettg)
    e1:SetOperation(s.retop)
    c:RegisterEffect(e1)

    -- ② 墓地发动，作为超量素材
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.ovtg)
    e2:SetOperation(s.ovop)
    c:RegisterEffect(e2)
end

-- 盖放回合可发动的条件：场上存在光属性龙族
function s.actcon(e)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) end, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

-- ① 过滤：圣夜骑士怪兽 或 光属性龙族7星
function s.recfilter(c)
    return c:IsSetCard(SET_HOLY_NIGHT) or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsLevel(7))
end
function s.retfilter(c)
    return s.recfilter(c) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
    return s.recfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① Target：只检查墓地是否有可回收的卡，不用管手牌和格子
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

-- ① Operation：回收后，选发特召
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    -- 先处理回收
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end

    -- 然后选发特召（如果场上有空位且手牌有卡）
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- ② 目标：以自己场上1只光属性超量怪兽为对象
function s.ovfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

-- ② 处理：墓地的这张卡作为超量素材
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Overlay(tc,c)
    end
end
local s,id,o=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    -- 规则：自己场上有光属性龙族存在的场合，这张卡在盖放的回合也能发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
    e0:SetCondition(s.setcon)
    c:RegisterEffect(e0)

    -- ① 回收墓地1只，特召手牌1只
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rettg)
    e1:SetOperation(s.retop)
    c:RegisterEffect(e1)

    -- ② 墓地发动：作为超量素材
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.ovtg)
    e2:SetOperation(s.ovop)
    c:RegisterEffect(e2)
end

function s.setcon(e,tp)
    return Duel.IsExistingMatchingCard(s.lightdragonfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.lightdragonfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
end

function s.recfilter(c)
    return (c:IsSetCard(SET_HOLY_NIGHT) or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsLevel(7)))
end
function s.retfilter(c)
    return s.recfilter(c) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
    return s.recfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local rg=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #rg>0 then
        Duel.SendtoHand(rg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,rg)
    end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.ovfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Overlay(tc,c)
    end
end
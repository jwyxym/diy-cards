-- 跃音萌行 狂律突进
-- ID: 26051982
-- 字段：跃音萌行 0x906 / 凛 0x907 / 布若 0x908 / 玛莉嘉 0x909
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

-- 苏生过滤：凛 / 布若 / 玛莉嘉
function s.spfilter(c,e,tp)
    return (c:IsSetCard(0x907) or c:IsSetCard(0x908) or c:IsSetCard(0x909))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

-- 链接怪兽过滤：额外卡组中的「跃音萌行」连接怪兽
function s.lkfilter(c)
    return c:IsSetCard(0x906) and c:IsType(TYPE_LINK)
        and c:IsLinkSummonable(nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- 那之后，可以进行1只「跃音萌行」连接怪兽的连接召唤
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    if not Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    local lc=g:GetFirst()
    if lc then
        Duel.LinkSummon(tp,lc,nil)  -- 引擎自动处理素材选择和送墓
    end
end
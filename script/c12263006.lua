--天水：九浊
function c12263006.initial_effect(c)
    --等级属性种族（老引擎兼容）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_LEVEL)
    e0:SetValue(9)
    c:RegisterEffect(e0)

    local e0a=Effect.CreateEffect(c)
    e0a:SetType(EFFECT_TYPE_SINGLE)
    e0a:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e0a:SetValue(ATTRIBUTE_WATER)
    c:RegisterEffect(e0a)

    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetCode(EFFECT_CHANGE_RACE)
    e0b:SetValue(RACE_CYBERSE)
    c:RegisterEffect(e0b)

    --仪式召唤：「“艾”之仪式」降临
    aux.AddRitualProcGreater(c,c12263006.ritfilter)
    c:EnableReviveLimit()

    --① 特殊召唤/破坏送墓 → 最多装备2只天水
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(12263006,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,12263006)
    e1:SetTarget(c12263006.eqtg)
    e1:SetOperation(c12263006.eqop)
    c:RegisterEffect(e1)

    local e1_2=e1:Clone()
    e1_2:SetCode(EVENT_DESTROYED)
    c:RegisterEffect(e1_2)

    --② 手卡·墓地 链接/仪式特召 → 装备1只
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(12263006,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,12263006*10+1)
    e2:SetCondition(c12263006.econ2)
    e2:SetTarget(c12263006.eqtg2)
    e2:SetOperation(c12263006.eqop2)
    c:RegisterEffect(e2)

    --③ 自己·对方回合发动：返回3只怪兽+连接召唤（最终零报错版）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(12263006,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,12263006*10+2)
    e3:SetTarget(c12263006.lktg)
    e3:SetOperation(c12263006.lkop)
    c:RegisterEffect(e3)

    --对方回合也能发动
    local e3_2=e3:Clone()
    e3_2:SetType(EFFECT_TYPE_QUICK_O)
    e3_2:SetCode(EVENT_FREE_CHAIN)
    e3_2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    c:RegisterEffect(e3_2)
end

--仪式素材：天水字段
function c12263006.ritfilter(c)
    return c:IsSetCard(0x5244)
end

--天水怪兽过滤
function c12263006.eqfilter(c)
    return c:IsSetCard(0x5244) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end

--① 目标
function c12263006.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(c12263006.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

--① 操作：装备1～2只（传统循环）
function c12263006.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12263006.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,2,nil)
    local ec=g:GetFirst()
    while ec do
        if Duel.Equip(tp,ec,tc) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetValue(function(e,c) return c==tc end)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            ec:RegisterEffect(e1)
        end
        ec=g:GetNext()
    end
end

--② 条件
function c12263006.econ2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_LINK+TYPE_RITUAL)
end

--② 目标
function c12263006.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(c12263006.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

--② 操作：装备1只
function c12263006.eqop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12263006.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
    local ec=g:GetFirst()
    if ec and Duel.Equip(tp,ec,tc) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetValue(function(e,c) return c==tc end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e1)
    end
end

--==============================
--③ 最终零报错版（彻底修复参数问题）
--==============================
--墓地怪兽过滤
function c12263006.tdfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

--连接怪兽过滤
function c12263006.linkfilter(c,e,tp)
    return c:IsType(TYPE_LINK) and c:IsLinkBelow(3)
        and c:IsAttackBelow(2300)
        and c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end

--素材检查：必须包含1只天水怪兽
function c12263006.matcheck(g)
    for tc in aux.Next(g) do
        if tc:IsSetCard(0x5244) then
            return true
        end
    end
    return false
end

function c12263006.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        --检查墓地是否有3只怪兽
        local g=Duel.GetMatchingGroup(c12263006.tdfilter,tp,LOCATION_GRAVE,0,nil)
        if g:GetCount()<3 then return false end
        --用for循环检查是否包含天水（彻底避免IsExists参数报错）
        if not c12263006.matcheck(g) then return false end
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(c12263006.linkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c12263006.lkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --1. 选择3只怪兽（必须包含天水）
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectMatchingCard(tp,c12263006.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    if #sg~=3 then return end
    if not c12263006.matcheck(sg) then
        Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(12263006,3))
        return
    end

    --2. 返回卡组
    if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end

    --3. 连接召唤
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,c12263006.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
    end
end

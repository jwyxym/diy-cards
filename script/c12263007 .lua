--天水：伏尔加
function c12263007.initial_effect(c)
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
    aux.AddRitualProcGreater(c,c12263007.ritfilter)
    c:EnableReviveLimit()

    --① 特殊召唤/破坏送墓 卡组破坏天水魔陷
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(12263007,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,12263007)
    e1:SetTarget(c12263007.destg)
    e1:SetOperation(c12263007.desop)
    c:RegisterEffect(e1)

    local e1_2=e1:Clone()
    e1_2:SetCode(EVENT_DESTROYED)
    c:RegisterEffect(e1_2)

    --② 手卡·墓地 链接/仪式特召 装备天水
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(12263007,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,12263007*10+1)
    e2:SetCondition(c12263007.econ2)
    e2:SetTarget(c12263007.eqtg2)
    e2:SetOperation(c12263007.eqop2)
    c:RegisterEffect(e2)

    --③ 双方主要阶段·二速自由时点
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(12263007,2))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,12263007*10+2)
    e3:SetTarget(c12263007.eqtg3)
    e3:SetOperation(c12263007.eqop3)
    c:RegisterEffect(e3)
end

--仪式素材
function c12263007.ritfilter(c)
    return c:IsSetCard(0x5244)
end

--① 破坏天水魔陷
function c12263007.desfilter(c)
    return c:IsSetCard(0x5244) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function c12263007.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c12263007.desfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end

function c12263007.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,c12263007.desfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

--② 条件
function c12263007.econ2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_LINK+TYPE_RITUAL)
end

--② 目标
function c12263007.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(c12263007.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

--② 操作：装备1只
function c12263007.eqop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12263007.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
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
--③ 效果：完全复刻珠泪小美人鱼格式
--==============================
--连接怪兽过滤
function c12263007.lkfilter(c,e,tp)
    return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
--素材过滤
function c12263007.matfilter(c,rc)
    return c:IsLocation(LOCATION_GRAVE) and rc:GetMaterial():IsContains(c)
end

function c12263007.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c12263007.lkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--③ 双方场上·墓地 最多2只装备（修复遍历方法）
function c12263007.eqtg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsCanBeEquippedTo,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
    end
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function c12263007.eqop3(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanBeEquippedTo),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,2,nil)
    -- 修复：用标准while循环替代错误的Iter()
    local ec=g:GetFirst()
    while ec do
        if Duel.Equip(tp,ec,tc,true) then
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
--天水怪兽过滤
function c12263007.eqfilter(c)
    return c:IsSetCard(0x5244) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
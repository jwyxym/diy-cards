local s,id,o=GetID()
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
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(c12263006.eqtg)
    e1:SetOperation(c12263006.eqop)
    c:RegisterEffect(e1)

    local e1_2=e1:Clone()
    e1_2:SetCode(EVENT_DESTROYED)
    c:RegisterEffect(e1_2)

    --② 手卡·墓地 链接/仪式特召 → 装备1只
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(c12263006.econ2)
    e2:SetTarget(c12263006.eqtg2)
    e2:SetOperation(c12263006.eqop2)
    c:RegisterEffect(e2)

    --③ 自己·对方回合发动：对象为自己场上1只链接·仪式怪兽或天水卡（怪兽/魔陷均可），破坏；之后可最多2张双方墓地回卡组
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,id+200)
    e3:SetTarget(c12263006.lktg)
    e3:SetOperation(c12263006.lkop)
    c:RegisterEffect(e3)
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

--③ Target
function c12263006.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local function tarfilter(c)
        return c:IsControler(tp)
        and (c:IsType(TYPE_LINK+TYPE_RITUAL) or c:IsSetCard(0x5244))
    end
    if chkc then return tarfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(tarfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,tarfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function c12263006.lkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
    --那之后，可以从自己·对方墓地最多2张返回卡组
    local btg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
    if #btg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=btg:Select(tp,0,2,nil)
        if #sg>0 then
            Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
        end
    end
end

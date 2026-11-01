local s,id=GetID()
local HOLY=0x474

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 同调召唤手续：调整 + 调整以外的光属性怪兽1只
    aux.AddSynchroProcedure(c, aux.FilterBoolFunction(Card.IsType,TYPE_TUNER), aux.NonTuner(aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT)), 1, 1)

    -- ① 同调召唤成功时：以场上·墓地1只暗属性怪兽为对象，回到手卡，再选场上1张卡回到手卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.con1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 场上的卡的效果发动时：送墓1张表侧魔陷，破坏那张卡，非光属性怪兽则自身回额外并特召圣辉
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.con2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

-- ① 条件：同调召唤
function s.con1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ① 过滤：场上或墓地的暗属性怪兽
function s.filter1(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.filter1(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,0,0) -- 至少处理2张回手
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    
    -- 对象怪兽回手
    if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        -- 再选场上1张卡回手
        local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if g:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
            end
        end
    end
end

-- ② 条件：场上的卡的效果发动
function s.con2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainDisablable(ev) and re:GetHandler():IsLocation(LOCATION_ONFIELD)
end

-- ② 目标：检查是否有1张表侧魔陷可送墓
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_SZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

-- ② 操作
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- 处理1：选自己场上1张表侧表示卡送去墓地
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_SZONE,0,1,1,nil)
    if #g==0 then return end
    if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

    -- 处理2：无效并破坏那张卡
    if Duel.NegateEffect(ev) then
        local rc=re:GetHandler()
        if rc:IsRelateToEffect(re) and rc:IsLocation(LOCATION_ONFIELD) then
            Duel.BreakEffect()
            if Duel.Destroy(rc,REASON_EFFECT)>0 then
                -- 处理3：破坏的是光属性以外的怪兽的场合
                if rc:IsType(TYPE_MONSTER) and (rc:GetAttribute() & ATTRIBUTE_LIGHT)==0 then
                    -- 自身回到额外卡组
                    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
                        Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
                    end
                    -- 从墓地特召1只圣辉怪兽
                    local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
                    if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                        local ssg=sg:Select(tp,1,1,nil)
                        if #ssg>0 then
                            Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
                        end
                    end
                end
            end
        end
    end
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(HOLY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
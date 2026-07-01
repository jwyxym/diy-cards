-- 源计划 营救行动
-- ID: 26051949
-- 字段: 0x904
local s,id=GetID()
function s.initial_effect(c)
    -- ① 破坏手卡·场上表侧「源计划」怪兽，从卡组检索或特召不同名怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.activate1)
    c:RegisterEffect(e1)

    -- ② 墓地盖放（自己场上表侧「源计划」怪兽被效果破坏时）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.settg2)
    e2:SetOperation(s.setop2)
    c:RegisterEffect(e2)
end

-- ① 条件（一回合一次）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
-- ① 目标选择
function s.desfilter(c)
    return c:IsSetCard(0x904) and c:IsFaceup() and c:IsDestructable()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- 手牌或场上表侧有可破坏的「源计划」怪兽
        return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
-- ① 操作
function s.spfilter(c,code)
    return c:IsSetCard(0x904) and not c:IsCode(code) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK))
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    -- 选择破坏自己场上或手牌的「源计划」怪兽
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    if #dg==0 then return end
    local dc=dg:GetFirst()
    local code=dc:GetCode()
    if Duel.Destroy(dc,REASON_EFFECT)==0 then return end
    -- 从卡组选择不同卡名的「源计划」怪兽，可选加入手卡或攻击表示特召
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,code)
    if #sg==0 then return end
    local tc=sg:GetFirst()
    local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    if op==0 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    else
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
        else
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        end
    end
end

-- ② 条件：自己场上表侧「源计划」怪兽被效果破坏
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter2,1,nil,tp)
end
function s.spfilter2(c,tp)
    return c:IsSetCard(0x904) and c:IsFaceup() and c:IsControler(tp) and bit.band(c:GetReason(),REASON_EFFECT)~=0
end
-- ② 目标：检查魔陷区空位
function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ② 操作：盖放并赋予离场除外
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
    -- 离场除外
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e1)
end
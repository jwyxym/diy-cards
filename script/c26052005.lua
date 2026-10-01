-- 致冥府的门扉 马库斯
-- ID: 26052005
-- 字段：逆时残响 0x910 / 升阶 0x911
-- 12星同调怪兽
local s,id=GetID()
function s.initial_effect(c)
    aux.AddSynchroProcedure(c, s.tunfilter, aux.NonTuner(nil), 1)
    c:EnableReviveLimit()

    -- 规则上当作「升阶」「逆时残响」卡使用
    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0b:SetCode(EFFECT_ADD_SETCODE)
    e0b:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0b:SetValue(0x911)
    c:RegisterEffect(e0b)
    local e0c=Effect.CreateEffect(c)
    e0c:SetType(EFFECT_TYPE_SINGLE)
    e0c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0c:SetCode(EFFECT_ADD_SETCODE)
    e0c:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0c:SetValue(0x910)
    c:RegisterEffect(e0c)

    -- ① 免疫
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    -- ② 等级上升其他本家等级之和
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_LEVEL)
    e2:SetValue(s.lvval)
    c:RegisterEffect(e2)

    -- ③ 双方回合，对方怪兽等级变同（1回合1次，二速）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetOperation(s.lvop3)
    c:RegisterEffect(e3)

    -- ④-20星以上：1回合1次，对方场上2张卡回手（一速起动效果）
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1000)
    e4:SetCondition(s.lv20con)
    e4:SetTarget(s.lv20tg)
    e4:SetOperation(s.lv20op)
    c:RegisterEffect(e4)

    -- ④-24星以上：1回合1次不会被战斗破坏
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e5:SetCondition(s.lv24con)
    e5:SetValue(1)
    c:RegisterEffect(e5)

    -- ④-32星以上：对方回合1次，对方发动效果时，对方场上卡全部回手（二速）
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_TOHAND)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_CHAINING)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1,id+2000)
    e6:SetCondition(s.lv32con)
    e6:SetTarget(s.lv32tg)
    e6:SetOperation(s.lv32op)
    c:RegisterEffect(e6)

    -- ④-40星以上：自己魔陷不会被对方效果破坏/除外
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetTargetRange(LOCATION_SZONE,0)
    e7:SetCondition(s.lv40con)
    e7:SetValue(1)
    c:RegisterEffect(e7)
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetCode(EFFECT_CANNOT_REMOVE)
    e8:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e8:SetRange(LOCATION_MZONE)
    e8:SetTargetRange(LOCATION_SZONE,0)
    e8:SetCondition(s.lv40con)
    c:RegisterEffect(e8)
end

-- 同调素材：逆时残响调整
function s.tunfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_TUNER)
end

-- ① 免疫
function s.immval(e,te)
    local c=e:GetHandler()
    if te:GetOwnerPlayer()==c:GetControler() then return false end
    if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true end
    local rc=te:GetHandler()
    if rc and te:IsActiveType(TYPE_MONSTER) then
        local rlv=rc:GetLevel()
        local rrk=rc:GetRank()
        if rlv>0 then return rlv < c:GetLevel() end
        if rrk>0 then return rrk < c:GetLevel() end
    end
    return false
end

-- ② 过滤：自己场上表侧、本家、非自身
function s.otherh_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x910) and not c:IsCode(26052005)
end
-- ② 数值：其他本家等级之和
function s.lvval(e,c)
    local tp=c:GetControler()
    return Duel.GetMatchingGroup(s.otherh_filter,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetLevel)
end

-- ③ 对方怪兽等级变同
function s.lvop3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local lv=c:GetLevel()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end

-- ④-20星以上（一速起动效果）
function s.lv20con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLevelAbove(20)
end
function s.lv20tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function s.lv20op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if g then
        local sg=g:Filter(Card.IsRelateToEffect,nil,e)
        if #sg>0 then Duel.SendtoHand(sg,nil,REASON_EFFECT) end
    end
end

-- ④-24星以上
function s.lv24con(e)
    return e:GetHandler():IsLevelAbove(24)
end

-- ④-32星以上
function s.lv32con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp and rp==1-tp
        and e:GetHandler():IsLevelAbove(32)
end
function s.lv32tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.lv32op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end
end

-- ④-40星以上
function s.lv40con(e)
    return e:GetHandler():IsLevelAbove(40)
end
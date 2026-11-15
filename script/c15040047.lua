-- 指尖回应的旋律 mortis
-- ID: 15040047
-- 「赞颂音乐的人偶」(15040037) 卡名记述
-- 「丰川祥子」字段：0xb10
local s,id=GetID()
function s.initial_effect(c)
aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」
    c:EnableReviveLimit()

    -- 手动超量召唤：记述「赞颂音乐的人偶」的6星怪兽2只以上
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetTarget(s.xyztg)
    e0:SetOperation(s.xyzop)
    c:RegisterEffect(e0)

    -- ① 双方回合，取除任意数量超量素材，以那个数量的表侧卡为对象无效其效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.discon)
    e1:SetTarget(s.distg)
    e1:SetOperation(s.disop)
    c:RegisterEffect(e1)

    -- ② 永续效果：有其他「赞颂音乐的人偶」记述超量怪兽2只以上时，战破抗性 + 嘲讽
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetCondition(s.cond2)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_ONLY_BE_ATTACKED)
    e3:SetCondition(s.cond2)
    c:RegisterEffect(e3)

    -- ③ 永续效果：自己场上没有「丰川祥子」怪兽时，不能攻击且不能发动效果
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_ATTACK)
    e4:SetCondition(s.cond3)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_CANNOT_ACTIVATE)
    e5:SetCondition(s.cond3)
    e5:SetValue(1)
    c:RegisterEffect(e5)
end

-- 超量召唤条件检查
function s.xyzfilter(c)
    return c:IsLevel(6) and aux.IsCodeListed(c,15040037)
end
function s.xyzcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,2,nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
    if g:GetCount()<2 then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg=g:Select(tp,2,g:GetCount(),nil)
    if sg:GetCount()<2 then return false end
    sg:KeepAlive()
    e:SetLabelObject(sg)
    return true
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if sg then
        Duel.Overlay(c,sg)
    end
end

-- ① 条件：必须有超量素材且场上有表侧表示卡
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetOverlayCount()>0
        and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

-- ① 目标：选择最多等于素材数量的表侧卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=e:GetHandler():GetOverlayCount()
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end

-- ① 操作：取除对应数量素材，无效卡的效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    local ct=g:GetCount()
    if ct>0 then
        c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
        local tc=g:GetFirst()
        while tc do
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
            tc=g:GetNext()
        end
    end
end

-- ② 条件：自己场上有其他「赞颂音乐的人偶」记述超量怪兽2只以上
function s.chkfilter(c,ec)
    return c~=ec and c:IsFaceup() and c:IsType(TYPE_XYZ) and aux.IsCodeListed(c,15040037)
end
function s.cond2(e)
    local c=e:GetHandler()
    return Duel.IsExistingMatchingCard(s.chkfilter,c:GetControler(),LOCATION_MZONE,0,2,c,c)
end

-- ③ 条件：自己场上没有「丰川祥子」怪兽
function s.cond3(e)
    local tp=e:GetHandlerPlayer()
    return not Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,0xb10),tp,LOCATION_MZONE,0,1,nil)
end
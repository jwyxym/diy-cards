-- 君临乐园的女神 Oblivionis
-- ID: 15040050
-- 「赞颂音乐的人偶」(15040037) 卡名记述
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

    -- 对这张卡1回合只能有1次特殊召唤
    c:SetSPSummonOnce(id)

    -- ① 特殊召唤成功时，从卡组·墓地取1张记述「赞颂音乐的人偶」的魔法·陷阱卡加入手卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 1回合最多3次，场上超量素材被取除时，场上1张卡回到手卡
    -- 改为监听多个离场事件，并检查离开前位置为 LOCATION_OVERLAY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(3,id+1000)
    e2:SetCondition(s.retcon)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e2b)
    local e2c=e2:Clone()
    e2c:SetCode(EVENT_TO_HAND)
    c:RegisterEffect(e2c)
    local e2d=e2:Clone()
    e2d:SetCode(EVENT_TO_DECK)
    c:RegisterEffect(e2d)

    -- ③ 对方回合，以自己墓地最多4只记述怪兽为对象，作为这张卡的超量素材
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
    e3:SetCountLimit(2,id+2000)
    e3:SetCondition(s.ovcon)
    e3:SetTarget(s.ovtg)
    e3:SetOperation(s.ovop)
    c:RegisterEffect(e3)
end

-- 超量素材过滤：记述「赞颂音乐的人偶」的6星怪兽
function s.xyzfilter(c)
    return c:IsLevel(6) and aux.IsCodeListed(c,15040037)
end

-- 超量召唤条件
function s.xyzcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,2,nil)
end

-- 超量召唤目标
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

-- 超量召唤操作
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if sg then
        Duel.Overlay(c,sg)
    end
end

-- ① 检索对象：记述「赞颂音乐的人偶」的魔法·陷阱卡
function s.thfilter(c)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 条件：事件中的卡有原本位于超量素材区的
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_OVERLAY) end,1,nil)
end
-- ② 目标：场上1张卡
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- ② 操作：场上1张卡回到手卡
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end

-- ③ 条件：对方回合
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
-- ③ 对象：自己墓地最多4只记述「赞颂音乐的人偶」的怪兽
function s.ovfilter(c)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_MONSTER)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ovfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_GRAVE,0,1,4,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ③ 操作：将对象怪兽作为超量素材，然后可选取除1个素材
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    Duel.Overlay(c,g)
    if c:IsRelateToEffect(e) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
    end
end
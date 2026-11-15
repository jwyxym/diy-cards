-- 托付人生的邀约
-- ID: 15040044
-- 场地魔法
-- 「丰川祥子」字段：0xb10
-- 「赞颂音乐的人偶」(15040037) 卡名记述
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」

    -- 卡的发动（包含①处理，卡名1回合只能发动1张）
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e0:SetTarget(s.thtg)
    e0:SetOperation(s.thop)
    c:RegisterEffect(e0)

    -- ② 自己场上的「丰川祥子」怪兽1回合各有1次不会被战斗·效果破坏
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb10))
    e1:SetCountLimit(1)
    e1:SetValue(s.indval)
    c:RegisterEffect(e1)

    -- ③ 这张卡在墓地时，以自己墓地·除外1只记述「赞颂音乐的人偶」的怪兽为对象，回到卡组，这张卡加入手卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.rettg)  -- 已修复此处的语法错误（移除了多余的空格）
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end

-- ① 检索对象：「丰川祥子」怪兽
function s.thfilter(c)
    return c:IsSetCard(0xb10) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 保护判定：受到战斗或效果破坏时适用
function s.indval(e,re,r,rp)
    return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end

-- ③ 对象：自己墓地·除外1只记述「赞颂音乐的人偶」的怪兽
function s.retfilter(c)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.retfilter(chkc) end
    if chk==0 then return c:IsAbleToHand()
        and Duel.IsExistingTarget(s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ③ 操作：对象怪兽回到卡组，然后这张卡加入手卡
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
            if c:IsRelateToEffect(e) then
                Duel.SendtoHand(c,nil,REASON_EFFECT)
            end
        end
    end
end
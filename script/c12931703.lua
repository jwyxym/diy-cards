-- 堕天使 弥赛亚
-- ID: 12931703
-- 字段：堕天使 0xef / 禁忌的 0x11d
-- link-3
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c, s.lmfilter, 3, 3)

    -- ① 连接召唤时，以墓地/除外1只天使族为对象回手卡，天使族自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 主阶段，选墓地1张堕天使或禁忌的速攻魔法回手卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)

    -- ③ 结束阶段，抽场上堕天使数量-3张
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.drcon)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end

function s.lmfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end

-- ①
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.tg1filter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tg1filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tg1filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.tg1filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
    -- 天使族自肃到下回合结束
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
    return not c:IsRace(RACE_FAIRY)
end

-- ②
function s.tg2filter(c)
    return c:IsAbleToHand() and (c:IsSetCard(0xef)
        or (c:IsSetCard(0x11d) and c:IsType(TYPE_QUICKPLAY)))
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tg2filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.tg2filter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ③
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp or Duel.GetTurnPlayer()~=tp
end
function s.count_filter(c)
    return c:IsFaceup() and c:IsSetCard(0xef)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(s.count_filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if chk==0 then return ct>3 and Duel.IsPlayerCanDraw(tp,ct-3) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(ct-3)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct-3)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(s.count_filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if ct>3 then
        Duel.Draw(tp,ct-3,REASON_EFFECT)
    end
end
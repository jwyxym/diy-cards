-- 蚀瞳之堕天使 阿斯塔莉亚
-- ID: 12931704
-- 字段：堕天使 0xef
-- 融合11星
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 融合素材：堕天使怪兽 + 天使族怪兽2只以上
    aux.AddFusionProcFun2(c, s.mfilter1, s.mfilter2, true, true)

    -- 替代召唤：丢弃1张天使族手卡，选除外状态3只天使族回墓地
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spscon)
    e0:SetTarget(s.sprtg)
    e0:SetOperation(s.spop)
    e0:SetValue(SUMMON_VALUE_SELF)
    c:RegisterEffect(e0)

    -- ① 特召时，从卡组/除外最多2张堕天使卡加入手卡，天使族自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 其他堕天使卡1回合1次不会被对方效果破坏
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(s.indtg)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- ③ 【修正】自己把「堕天使」卡的效果发动时，取对象除外对方场上1张卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.rmcon)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end

function s.mfilter1(c)
    return c:IsSetCard(0xef)
end
function s.mfilter2(c)
    return c:IsRace(RACE_FAIRY)
end

-- 丢弃过滤：天使族
function s.discardfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsDiscardable()
end
-- 除外区天使族回墓地
function s.spfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAbleToRemove() and c:IsAbleToGrave()
end

function s.spscon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,3,nil)
end

function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local dg=Duel.SelectMatchingCard(tp,s.discardfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #dg==0 then return false end
    dg:KeepAlive()
    e:SetLabelObject(dg)
    return true
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local dg=e:GetLabelObject()
    if not dg then return end
    Duel.SendtoGrave(dg,REASON_COST+REASON_DISCARD)
    dg:DeleteGroup()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,3,3,nil)
    if #rg<3 then return end
    Duel.SendtoGrave(rg,REASON_EFFECT)
    -- 引擎自动完成召唤
end

-- ①
function s.thfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,2,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.splimit(e,c)
    return not c:IsRace(RACE_FAIRY)
end

-- ②
function s.indtg(e,c)
    return c~=e:GetHandler() and c:IsSetCard(0xef)
end

-- ③ 【修正】条件：自己发动「堕天使」卡的效果
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    -- 必须是自己发动的效果
    if rp~=tp then return false end
    -- 防止空指针
    if not re then return false end
    local rc=re:GetHandler()
    if not rc then return false end
    -- 发动的卡必须属于「堕天使」字段
    return rc:IsSetCard(0xef)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
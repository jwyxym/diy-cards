-- 気鬱、白濁す
-- ID: 72800016
-- 永续魔法
-- 「TOGENASHI TOGEARI」字段：0xb15
-- 「Iseri Nina」：72800000
local s,id=GetID()
function s.initial_effect(c)
    -- 卡的发动（包含①处理）
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)  -- 卡名1回合只能发动1张
    e0:SetTarget(s.thtg)
    e0:SetOperation(s.thop)
    c:RegisterEffect(e0)

    -- ② 额外通常召唤1只「Iseri Nina」
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))   -- 为额外召唤提示补充描述文本
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e1:SetTarget(s.sumfilter)
    c:RegisterEffect(e1)
end

-- ① 检索：炎属性天使族怪兽
function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：本回合自己不是「TOGENASHI TOGEARI」怪兽不能从额外卡组特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- 自肃：额外卡组只能特殊召唤「TOGENASHI TOGEARI」怪兽
function s.splimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then
        return not c:IsSetCard(0xb15)
    end
    return false
end

-- ② 额外通常召唤对象：「Iseri Nina」(72800000)
function s.sumfilter(e,c)
    return c:IsCode(72800000)
end
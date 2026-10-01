-- 逆时残响 环状水星
-- ID: 26052008
-- 字段：逆时残响 0x910 / 升阶 0x911
local s,id=GetID()
function s.initial_effect(c)
    -- 规则上当作「升阶」卡
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x911)
    c:RegisterEffect(e0)

    -- ① 特殊召唤时检索本家魔陷
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

    -- ② 宣言1~6，等级变为宣言值
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- ③ 作为同调素材送去墓地的场合，检索4星以下本家怪兽
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.tg3con)
    e3:SetTarget(s.tg3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end

-- ① 检索
function s.thfilter(c)
    return c:IsSetCard(0x910) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 宣言1~6
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
    local lv=Duel.AnnounceLevel(tp,1,6)
    e:SetLabel(lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lv=e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() and lv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- ③ 【修正】条件：必须作为同调素材送墓
function s.tg3con(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- 必须是从场上送去墓地
    if not c:IsPreviousLocation(LOCATION_MZONE) then return false end
    -- 必须是作为同调素材（REASON_SYNCHRO），而不是链接素材（REASON_LINK）
    return c:IsReason(REASON_SYNCHRO)
end

-- ③ 检索过滤：4星以下本家怪兽
function s.tg3filter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tg3filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ③ 操作：检索 + 自肃 + 卡片效果禁发
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.tg3filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
            Duel.ConfirmCards(1-tp,g)
            -- 禁发：加入手卡的卡以及同名卡的效果
            local code=tc:GetCode()
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_ACTIVATE)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetValue(s.aclimit)
            e1:SetLabel(code)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
    -- 自肃：本回合只能特召魔法师族同调
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.splimit)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
end
function s.aclimit(e,re,tp)
    return re:GetHandler():IsCode(e:GetLabel())
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_SYNCHRO))
end
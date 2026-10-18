-- 地下酒馆「暗夜织者」
-- ID: 26052018
-- 字段：暗夜织者 0x912
-- 场地魔法
local s,id=GetID()
function s.initial_effect(c)
    -- ① 发动时检索本家卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 对方不能攻击宣言
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,1)
    c:RegisterEffect(e2)

    -- ③ 场上有昆虫族仪式怪兽时，不受对方效果影响
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetCondition(s.immcon)
    e3:SetValue(s.immval)
    c:RegisterEffect(e3)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.thfilter(c)
    return c:IsSetCard(0x912) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.immcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ritfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_RITUAL)
end
function s.immval(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
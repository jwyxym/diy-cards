-- 想要成为人类之歌 永续魔法
-- ID: 26062909
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述

    -- 卡的发动（此卡名的卡1回合仅可发动1张）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id)
    c:RegisterEffect(e0)

    -- ① 1回合1次，以自己场上1只怪兽为对象，检索不同等级的记述「春日影」怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id+1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)
end

-- ① 目标：自己场上1只表侧怪兽
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end

-- ① 检索：记述「春日影」的怪兽，且等级与目标不同（必须为怪兽）
function s.thfilter(c,lv)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER)
        and not c:IsLevel(lv) and c:IsAbleToHand()
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    local lv=tc:GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,lv)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
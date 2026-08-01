-- 春日影 场地魔法
-- ID: 26062911
-- 记述「春日影」
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 自身也记述「春日影」

    -- 卡的发动（1回合仅1张）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id)
    c:RegisterEffect(e0)

    -- ① 自己场上怪兽守备力上升
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_DEFENSE)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetValue(s.defval)
    c:RegisterEffect(e1)

    -- ② 检索1只记述「春日影」卡名的怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- ③ 代替破坏（保护记述「春日影」的怪兽，除外墓地1只怪兽和这张卡自身）
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTarget(s.reptg)
    e3:SetValue(s.repval)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end

-- ① 守备力上升值：自己场上记述「春日影」的怪兽数量×100
function s.countfilter(c)
    return c:IsFaceup() and aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER)
end
function s.defval(e,c)
    return Duel.GetMatchingGroupCount(s.countfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*100
end

-- ② 检索对象：记述「春日影」的怪兽
function s.thfilter(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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

-- ③ 代替破坏：适用对象是自己场上记述「春日影」的怪兽
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsOnField() and c:IsFaceup()
        and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
        and aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER)
end
-- 墓地除外的怪兽过滤
function s.rmfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ③ 询问是否代替
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return eg:IsExists(s.repfilter,1,nil,tp)
            and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
            and c:IsAbleToRemove()
    end
    return Duel.SelectEffectYesNo(tp,c,96)
end
-- ③ 确认保护价值
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
-- ③ 执行代替（修正：确保除外墓地怪兽和自身）
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
    -- 直接除外场地，不再检查 IsRelateToEffect
    if c:IsAbleToRemove() then
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
    end
    Duel.Hint(HINT_CARD,0,id)
end
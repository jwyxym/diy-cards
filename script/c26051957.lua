-- 暗镜堕翼 魅塔骑士
-- ID: 26051957
-- 字段: 规则上当作「新星同盟」(0x902)
local s,id=GetID()
function s.initial_effect(c)
    -- 超量召唤（7星怪兽×2）
    aux.AddXyzProcedure(c,nil,7,2)
    c:EnableReviveLimit()

    -- 规则上当作「新星同盟」卡
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x902)
    c:RegisterEffect(e0)

    -- ① 特召成功时，选墓地1只怪兽作为超量素材（参考ライゼオル）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.mttg)
    e1:SetOperation(s.mtop)
    c:RegisterEffect(e1)

    -- ② 有特定素材时，对方发动效果时二速炸卡（参考ライゼオル）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.descon)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- ① 素材目标（参考ライゼオル的mtfilter）
function s.mtfilter(c,e)
    return c:IsType(TYPE_MONSTER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
        and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
    if g:GetCount()>0 then
        Duel.Overlay(c,g)
    end
end

-- ② 条件：对方发动效果，且此卡持有特定素材
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    local c=e:GetHandler()
    return c:GetOverlayGroup():IsExists(s.matfilter,1,nil)
end
function s.matfilter(c)
    return c:IsCode(26051905) or c:IsCode(26051956)
end
-- ② cost：取除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ② 目标：场上1张卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
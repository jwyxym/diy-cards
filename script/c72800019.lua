-- ⭐️Kawaragi Momoka⭐️
-- ID: 72800019
-- 水属性 / 幻想魔族 / 超量 / ATK 2500 / DEF 2000
-- 7星怪兽×2
-- 「Kawaragi Momoka」：72800007
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 超量召唤：7星怪兽×2
    aux.AddXyzProcedure(c, nil, 7, 2)

    -- ② 1回合1次，取除1个超量素材，以场上1张魔法·陷阱卡为对象破坏
    -- ① 没有「Kawaragi Momoka」作为超量素材的这张卡不能把效果发动（在条件中检查）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.descon)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end

-- ① 条件：超量素材中必须有「Kawaragi Momoka」(72800007)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsType(TYPE_XYZ) then return false end
    local mg=c:GetOverlayGroup()
    if not mg then return false end
    return mg:IsExists(Card.IsCode,1,nil,72800007)
end

-- ② cost：取除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ② 目标：场上1张魔法·陷阱卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ② 操作：破坏选择的魔法·陷阱卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
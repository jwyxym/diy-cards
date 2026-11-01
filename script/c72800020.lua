-- ⭐️Awa Subaru⭐️
-- ID: 72800020
-- 风属性 / 幻想魔族 / 超量 / ATK 2800 / DEF 2200
-- 6星怪兽×2
-- 「Awa Subaru」：72800009
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 超量召唤：6星怪兽×2
    aux.AddXyzProcedure(c, nil, 6, 2)

    -- ② 1回合1次，取除1个超量素材，以这张卡以外的场上1只表侧表示怪兽为对象，变成里侧守备表示
    -- ① 没有「Awa Subaru」作为超量素材的这张卡不能把效果发动（在条件中检查）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.poscon)
    e1:SetCost(s.poscost)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
    c:RegisterEffect(e1)
end

-- ① 条件：超量素材中必须有「Awa Subaru」(72800009)
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsType(TYPE_XYZ) then return false end
    local mg=c:GetOverlayGroup()
    if not mg then return false end
    return mg:IsExists(Card.IsCode,1,nil,72800009)
end

-- ② cost：取除1个超量素材
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ② 目标：这张卡以外的场上1只表侧表示怪兽，且可以变成里侧守备
function s.posfilter(c,e)
    return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and s.posfilter(chkc,e) end
    if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,e)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

-- ② 操作：将目标怪兽变为里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end
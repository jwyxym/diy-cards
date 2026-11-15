-- 法尔萨·阿莱斯哈特
-- ID: 12950005
-- 字段：俱舍怒威族 0x189
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c,s.mfilter,8,3,s.ovfilter,aux.Stringid(id,0),3)
    
    -- ① 卡名视作「维萨斯」
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(56099748)
    c:RegisterEffect(e1)

    -- ② 【修复】改为必发效果（TRIGGER_F），去掉多余的 eg 检查
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F) -- 必发
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2,id,EFFECT_COUNT_CODE_CHAIN)
    e2:SetTarget(s.mattg)
    e2:SetOperation(s.matop)
    c:RegisterEffect(e2)

    -- ③ 不受对方攻击力低于2100的怪兽效果影响
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetValue(s.immval)
    c:RegisterEffect(e3)

    -- ④ 对方把场上的卡的效果发动时，拔3素材无效，之后选场上1张卡里侧除外
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1000)
    e4:SetCondition(s.negcon)
    e4:SetCost(s.negcost)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
end

function s.mfilter(c) return c:IsSetCard(0x189) and c:IsLevel(8) end
function s.ovfilter(c,tp,xyzc)
    return c:IsFaceup() and c:IsCode(48626373) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,31149212)
end

-- ②
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    -- 必发效果不需要检查对象，直接允许入连锁
    if chk==0 then return true end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsCanOverlay() then return end
    -- 如果没有卡可以被吸作素材，则处理结束
    if not Duel.IsExistingMatchingCard(Card.IsAbleToOverlay,tp,LOCATION_REMOVED,0,1,nil) then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToOverlay,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then Duel.Overlay(c,g) end
end

-- ③
function s.immval(e,te)
    if te:GetOwnerPlayer()==e:GetHandlerPlayer() then return false end
    if not te:IsActiveType(TYPE_MONSTER) then return false end
    local rc=te:GetHandler()
    return rc:IsFaceup() and rc:GetAttack()<2100
end

-- ④
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not Duel.IsChainNegatable(ev) then return false end
    if not re:IsActiveType(TYPE_MONSTER) and not re:IsActiveType(TYPE_SPELL) and not re:IsActiveType(TYPE_TRAP) then
        return false
    end
    local rc=re:GetHandler()
    return rc:IsOnField() or (re:GetActivateLocation() & LOCATION_ONFIELD) ~= 0
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #g>0 then 
                Duel.HintSelection(g)
                Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) 
            end
        end
    end
end
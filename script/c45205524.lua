--山铜结界-托利托斯
--卡密ID: 45205524

local s,id=GetID()

function s.initial_effect(c)
    --③效果：卡名当作「山铜结界」使用
    aux.EnableChangeCode(c,48179391,LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE)
    
    --永续魔法发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --①效果：对方发动魔陷时，弹窗选择是否无效（不亮时点，1回合1次）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.negcon)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    
    --②效果：自己场上的卡不会被战斗破坏，不会被对方的效果破坏
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(aux.TRUE)
    e2:SetValue(1)
    e2:SetCondition(s.indcon)
    c:RegisterEffect(e2)
    
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_ONFIELD,0)
    e3:SetTarget(aux.TRUE)
    e3:SetValue(s.indval)
    e3:SetCondition(s.indcon)
    c:RegisterEffect(e3)
end

--①效果条件：场地区有表侧表示的「山铜结界」，且对方发动魔法·陷阱卡，且1回合1次
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local fzc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
    if not fzc or not fzc:IsFaceup() or not (fzc:IsCode(48179391) or aux.IsCodeOrListed(fzc,48179391)) then
        return false
    end
    return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
        and e:GetHandler():GetFlagEffect(id)<=0
        and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
end

--①效果处理：弹窗询问是否无效
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    -- 弹窗询问
    if not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then return end
    
    -- 选择Cost怪兽送去墓地
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    Duel.SendtoGrave(sc,REASON_EFFECT)
    
    -- ★★★ 效果无效（不是发动无效） ★★★
    if Duel.NegateEffect(ev) then
        -- 注册标记，1回合1次
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end

--①效果Cost筛选
function s.costfilter(c)
    return c:IsAbleToGrave() and (c:IsCode(48179391) or aux.IsCodeOrListed(c,48179391))
        and c:IsType(TYPE_MONSTER)
end

--②效果条件：自己场地区有表侧表示的「山铜结界」
function s.indcon(e)
    local fzc=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_FZONE,0)
    return fzc and fzc:IsFaceup() and (fzc:IsCode(48179391) or aux.IsCodeOrListed(fzc,48179391))
end

--②效果值：只有对方的效果破坏才免疫
function s.indval(e,re)
    if not re then return false end
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
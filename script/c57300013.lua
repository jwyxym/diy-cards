--"寂静"吉尔达利娅
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,57300009)
    -- 修改召唤条件：包含兽战士族怪兽的怪兽2只以上
    aux.AddLinkProcedure(c, nil, 2, 99, function(g) return g:IsExists(Card.IsRace,1,nil,RACE_BEASTWARRIOR) end)
    c:EnableReviveLimit()
    
    -- e1：发动时取对象，效果处理时丢弃，然后破坏
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)  
    e1:SetCondition(s.descon1)
    e1:SetTarget(s.destg1)
    e1:SetOperation(s.desop1)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+o)
    e2:SetTarget(s.drtg2)
    e2:SetOperation(s.drop2)
    c:RegisterEffect(e2)
end

function s.gilfilter(c)
    return aux.IsCodeListed(c,57300009)
end

function s.descon1(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

-- 原 descost1 保留但未使用
function s.descost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gilfilter,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gilfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gilfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    if #g==0 then return end
    Duel.SendtoGrave(g,REASON_EFFECT)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

function s.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    
    if not Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) then return end
    if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,2,2,nil)
    if #dg<2 then return end
    Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
    
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetCountLimit(1)
    e1:SetCondition(s.tkcon)
    e1:SetOperation(s.tkop)
    e1:SetReset(RESET_PHASE+PHASE_STANDBY,1)
    Duel.RegisterEffect(e1,tp)
end

function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<2 then return end
    local token1=Duel.CreateToken(tp,57300025)
    local token2=Duel.CreateToken(tp,57300025)
    if not token1 or not token2 then return end
    Duel.SpecialSummon(token1,0,tp,tp,false,false,POS_FACEUP)
    Duel.SpecialSummon(token2,0,tp,tp,false,false,POS_FACEUP)
    e:Reset()
end
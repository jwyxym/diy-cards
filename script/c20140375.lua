local s,id,o=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcCodeFunRep(c,20140361,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),1,127,true,true)
    -- ① 自己墓地的卡不受对方发动的效果影响
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_GRAVE,0)
    e1:SetTarget(aux.TRUE)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
    -- ② 特召→检索（3体以上用2张）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    -- ③ 魔陷发动→回收融合→赋予墓地融合能力
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+o)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.tg3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end
function s.filter2(c)
    return c:IsSetCard(0x2b1) and c:IsAbleToHand()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local ct=1
    local mat3=e:GetHandler():GetMaterialCount()>=3 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
    if mat3 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,2,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then ct=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,ct,ct,nil)
    if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.filter3(c)
    return (c:IsSetCard(0x46) and c:IsType(TYPE_SPELL)) or c:IsSetCard(0x2b1) and c:IsAbleToHand()
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
     if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter3(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter3,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    Duel.SelectTarget(tp,s.filter3,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetTargetRange(LOCATION_GRAVE,0)
	e1:SetCountLimit(1)
	e1:SetTarget(s.mttg)
	e1:SetOperation(function() return FusionSpell.FUSION_OPERATION_BANISH end)
	e1:SetValue(function(extra_material_effect,c) return c and c:IsControler(extra_material_effect:GetHandlerPlayer()) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
    end
end
function s.immval(e,re)
    return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
function s.mttg(e,c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
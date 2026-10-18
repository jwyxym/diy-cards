--月血姬 吸血鬼
function c11771410.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),7,2,nil,nil,99)
    --lv change
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(c11771410.lvtg)
	e0:SetValue(c11771410.lvval)
	c:RegisterEffect(e0)
    -- 超量战吼
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(11771410,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,11771410)
    e1:SetTarget(c11771410.tg1)
    e1:SetOperation(c11771410.op1)
    c:RegisterEffect(e1)
    -- 获得控制权
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(11771410,1))
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetCountLimit(1,11771411)
    e2:SetCost(c11771410.cost2)
    e2:SetTarget(c11771410.tg2)
    e2:SetOperation(c11771410.op2)
    c:RegisterEffect(e2)
    -- 获得素材
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(11771410,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(aux.bdocon)
    e3:SetTarget(c11771410.tg3)
    e3:SetOperation(c11771410.op3)
    c:RegisterEffect(e3)
end
--lv change
function c11771410.lvtg(e,c)
	return c:IsLevelAbove(1) and c:GetOwner()~=e:GetHandlerPlayer() and c:IsRace(RACE_ZOMBIE)
end
function c11771410.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 7
	else return lv end
end
-- 1
function c11771410.filter1(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function c11771410.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c11771410.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c11771410.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c11771410.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
-- 2
function c11771410.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c11771410.filter2(c)
    return c:IsControlerCanBeChanged() and c:IsFaceup()
end
function c11771410.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11771410.filter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c11771410.filter2,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,c11771410.filter2,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c11771410.op2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
        Duel.GetControl(tc,tp)
    end
end
-- 3
function c11771410.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,LOCATION_GRAVE)
end
function c11771410.op3(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_GRAVE,1,1,nil)
    if g:GetCount()>0 then
        Duel.Overlay(e:GetHandler(),g)
    end
end

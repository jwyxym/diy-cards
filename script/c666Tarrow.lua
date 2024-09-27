--库「幻星集」
XiaoyeTarrow={}
Duel.LoadScript("c666PublicFunctionLibrary.lua")
xiaoye=XiaoyeTarrow
--PScale
function XiaoyeTarrow.PendulumScale(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LSCALE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCondition(XiaoyeTarrow.PendulumScaleConditionLeft)
    e1:SetValue(-3)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_RSCALE)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_LSCALE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_PZONE)
    e3:SetCondition(XiaoyeTarrow.PendulumScaleConditionRight)
    e3:SetValue(4)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_RSCALE)
    c:RegisterEffect(e4)
end
function XiaoyeTarrow.PendulumScaleConditionLeft(e)
    return e:GetHandler()==Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,0)
end
function XiaoyeTarrow.PendulumScaleConditionRight(e)
    return e:GetHandler()==Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,1)
end
--PEffectCost
function XiaoyeTarrow.PendulumEffectCost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if not e:GetHandler():IsDisabled() and e:GetHandler():GetControler()==e:GetHandler():GetOwner() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(XiaoyeTarrow.PendulumEffectCostLimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp) end
end
function XiaoyeTarrow.PendulumEffectCostLimit(e,c)
    return not c:IsSetCard(0x666)
end
--Move To P When Destory
function XiaoyeTarrow.PWhenDestory(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(XiaoyeTarrow.PWhenDestoryCondition)
    e1:SetTarget(XiaoyeTarrow.PWhenDestoryTarget)
    e1:SetOperation(XiaoyeTarrow.PWhenDestoryOperation)
    c:RegisterEffect(e1)
end
function XiaoyeTarrow.PWhenDestoryCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function XiaoyeTarrow.PWhenDestoryTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function XiaoyeTarrow.PWhenDestoryOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--Tarrow Cannot Be Material
function XiaoyeTarrow.CannotBeMaterial(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e1:SetValue(XiaoyeTarrow.CannotBeMaterialLimit)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(e4)
end
--Tarrow Cannot Be Material (Link)
function XiaoyeTarrow.CannotBeMaterialLink(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e1:SetValue(XiaoyeTarrow.CannotBeMaterialLimit)
    c:RegisterEffect(e1)
end
function XiaoyeTarrow.CannotBeMaterialLimit(e,c)
    if not c then return false end
    return not c:IsSetCard(0x666)
end
--Tuner
function XiaoyeTarrow.CardTargetBeTuner(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(XiaoyeTarrow.CardTargetBeTunerTarget)
    e1:SetOperation(XiaoyeTarrow.CardTargetBeTunerOperation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end
function XiaoyeTarrow.CardTargetBeTunerFilter(c)
    return c:IsFaceup() and c:IsSetCard(0x666) and c:IsLevelAbove(0) and not c:IsType(TYPE_TUNER)
end
function XiaoyeTarrow.CardTargetBeTunerTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and XiaoyeTarrow.CardTargetBeTunerFilter(chkc) end
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,XiaoyeTarrow.CardTargetBeTunerFilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function XiaoyeTarrow.CardTargetBeTunerOperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_TYPE)
        e1:SetValue(TYPE_TUNER)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
--Splimit
function XiaoyeTarrow.SpecialSummonWithoutPendulum(c)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(XiaoyeTarrow.SpecialSummonWithoutPendulumValue)
    c:RegisterEffect(e1)
end
function XiaoyeTarrow.SpecialSummonWithoutPendulumValue(e,se,sp,st)
    return st&SUMMON_TYPE_PENDULUM~=SUMMON_TYPE_PENDULUM
end
--LinkSummon
function XiaoyeTarrow.LinkSummon(c)
    aux.AddLinkProcedure(c,nil,2,2,XiaoyeTarrow.LinkSummonMateria)
    c:EnableReviveLimit()
end
function XiaoyeTarrow.LinkSummonMateria(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x666)
end
--LinkSearch
function XiaoyeTarrow.LinkSearch(c,Filter,m)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,m+11)
    e1:SetTarget(XiaoyeTarrow.LinkSearchTarget(Filter))
    e1:SetOperation(XiaoyeTarrow.LinkSearchOperation(Filter))
    c:RegisterEffect(e1)
end
function XiaoyeTarrow.LinkSearchTarget(f)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
	            if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_DECK,0,1,nil) end
	            Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
            end
end
function XiaoyeTarrow.LinkSearchOperation(f)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
                if g:GetCount()>0 then
                    Duel.SendtoHand(g,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,g)
                end
            end
end
--LinkToExtra
function XiaoyeTarrow.LinkToExtra(c,m)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOEXTRA)
    e1:SetCountLimit(1,m+12)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetTarget(XiaoyeTarrow.LinkToExtraTarget)
    e1:SetOperation(XiaoyeTarrow.LinkToExtraOperation)
    c:RegisterEffect(e1)
end
function XiaoyeTarrow.LinkToExtraTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function XiaoyeTarrow.LinkToExtraOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
--SpellAddCounter
function XiaoyeTarrow.AddTarrowCounter(c)
    c:EnableCounterPermit(0x666)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(XiaoyeTarrow.AddTarrowCounterCondition)
	e1:SetOperation(XiaoyeTarrow.AddTarrowCounterOperation)
	c:RegisterEffect(e1)
end
function XiaoyeTarrow.AddTarrowCounterCondition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re and rc:IsSetCard(0x666) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:GetOriginalType()&TYPE_MONSTER+TYPE_FIELD~=0
end
function XiaoyeTarrow.AddTarrowCounterOperation(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x666,1)
end
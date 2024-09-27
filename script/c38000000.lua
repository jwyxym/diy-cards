--惑星天启的集结
local this,id,ofs=GetID()
function this.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(this.spcost)
    e1:SetTarget(this.sptg)
    e1:SetOperation(this.spop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(2)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
    e2:SetTarget(this.lvtg)
    e2:SetOperation(this.lvop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(this.immcon)
    e3:SetTarget(this.immtg)
    e3:SetValue(this.immval)
    c:RegisterEffect(e3)
end
function this.spfilter(c,e,tp)
    return c:IsSetCard(0x380) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
	if chk==0 then return Duel.CheckLPCost(1-tp,1500) end
		Duel.PayLPCost(1-tp,1500)
		Duel.RegisterFlagEffect(tp,38000071,RESET_PHASE+PHASE_END,0,1)
	else
		if chk==0 then return Duel.CheckLPCost(tp,1500) end
		Duel.PayLPCost(tp,1500)
	end
end
function this.sptg(e,tp,eg,pe,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil,e,tp)
    and Duel.GetMZoneCount(tp)>=2 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(this.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil,e,tp)
    if tg then
        for tc in aux.Next(tg) do
            if Duel.SpecialSummonStep(tc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetValue(RESET_TURN_SET)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e2)
            end
        end
        Duel.SpecialSummonComplete()
    end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(this.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function this.splimit(e,c)
    return not c:IsSetCard(0x380)
end
function this.lvfilter(c)
    return c:IsSetCard(0x380) and c:IsFaceup() and c:GetLevel()>2
end
function this.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and this.lvfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(this.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,this.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function this.lvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(-2)
		tc:RegisterEffect(e1)
    end
end
function this.immfilter(c)
    return c:IsSetCard(0x2380) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function this.immcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetMatchingGroupCount(this.immfilter,tp,LOCATION_MZONE,0,nil)>=4
end
function this.immtg(e,c)
    return this.immfilter(c)
end
function this.immval(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end

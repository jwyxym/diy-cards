--点兔 保登心爱
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700036)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2,cm.lcheck)
	c:EnableReviveLimit()
    --splimit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cm.thcon)
	e1:SetOperation(cm.regop)
	c:RegisterEffect(e1)
    --cannot link material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetValue(cm.lmlimit)
	c:RegisterEffect(e3)
    --recover
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(cm.thtg)
	e4:SetOperation(cm.thop)
	c:RegisterEffect(e4)
    --remove
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,m)
	e5:SetTarget(cm.sptg)
	e5:SetOperation(cm.spop)
	c:RegisterEffect(e5)
    --race
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetCondition(cm.crcon)
	e2:SetValue(RACE_PLANT)
	c:RegisterEffect(e2)
end

function cm.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_FIRE)
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,200)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,200,REASON_EFFECT)
end

function cm.refilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemove()
end

function cm.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Group.CreateGroup()
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,m) then
        if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and cm.refilter(chkc) end
        if chk==0 then return Duel.IsExistingTarget(cm.refilter,tp,0,LOCATION_GRAVE,1,nil) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        g=Duel.SelectTarget(tp,cm.refilter,tp,0,LOCATION_GRAVE,1,1,nil)
    else
        local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
        if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and cm.spfilter(chkc,e,tp,zone) end
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(cm.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        g=Duel.SelectTarget(tp,cm.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,200)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	if (not tc:IsRelateToEffect(e)) then return false end
    local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,m) then
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetOperation(cm.retop)
			Duel.RegisterEffect(e1,tp)
			Duel.BreakEffect()
			Duel.Recover(tp,200,REASON_EFFECT)
		end
    elseif tc:IsRace(RACE_PLANT) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,bit.band(c:GetLinkedZone(tp),0x1f))
    end
end

function cm.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetLabelObject(),REASON_RETURN+REASON_TEMPORARY)
end

function cm.concfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_LINK) and c:IsFaceup()
end

function cm.crcon(e)
	return e:GetHandler():IsPlayerCanSpecialSummon(tp) and Duel.IsExistingMatchingCard(cm.concfilter,e:GetHandlerPlayer(),0x04,0,1,nil) and not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY) and not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY)
end
--请问您今天要来点兔子吗? 桐间纱路
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700036)
    --link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --spsummonsuccess
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.indtg)
	e2:SetValue(cm.imval)
	c:RegisterEffect(e2)
    --indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(cm.indtg)
	e3:SetValue(700)
	c:RegisterEffect(e3)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_LIGHT)
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
	return c:IsCode(m)
end

function cm.tgtfilter(c)
    return aux.IsCodeListed(c,10700036) and c:IsFaceup() and c:IsType(TYPE_LINK)
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(cm.tgtfilter,tp,0x04,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=7 end
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local WIN_REASON_ORDER_A_RABBIT=0x426
	Duel.Win(tp,WIN_REASON_ORDER_A_RABBIT)
end

function cm.imval(e,te)
	return te:GetActivateLocation()==LOCATION_HAND
end

function cm.indtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
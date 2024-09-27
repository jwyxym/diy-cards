--春巫 蓝莓
local cm,m=GetID()

function cm.initial_effect(c)
	c:EnableCounterPermit(0x1)
	--link summon
	aux.AddLinkProcedure(c,cm.lfcheck,1,1)
	c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e1=e0:Clone()
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(cm.regop2)
	c:RegisterEffect(e1)
    --effect gain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCode(EFFECT_ADD_ATTRIBUTE)
	e4:SetTarget(cm.eftg)
	e4:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e4)
end

function cm.lfcheck(c)
	return c:IsLevelBelow(3) and c:IsLinkRace(RACE_SPELLCASTER)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local g,c=Duel.GetMatchingGroup(Card.IsSummonLocation,tp,0x04,0x04,nil,LOCATION_EXTRA),e:GetHandler()
    if #g>0 and c:IsCanAddCounter(0x1,#g) then
        c:AddCounter(0x1,#g)
    end
end

function cm.regop2(e,tp,eg,ep,ev,re,r,rp)
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

function cm.eftg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end
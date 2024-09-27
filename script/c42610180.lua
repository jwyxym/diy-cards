--恶之传教士 花园百合铃
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m)
	e2:SetTarget(cm.eqtg)
	e2:SetOperation(cm.eqop)
	c:RegisterEffect(e2)
	--attackup
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(cm.atkval)
    c:RegisterEffect(e1)
    --
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetCondition(cm.immcon1)
	e3:SetValue(1)
	c:RegisterEffect(e3)
    --negate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
    e4:SetCondition(cm.immcon1)
	e4:SetTarget(cm.distg)
	c:RegisterEffect(e4)
    --immune
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(cm.immcon2)
	e5:SetValue(cm.efilter)
	c:RegisterEffect(e5)
    --actlimit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,1)
    e6:SetCondition(cm.immcon4)
	e6:SetValue(1)
	c:RegisterEffect(e6)
    --immune
    local e7=e5:Clone()
    e7:SetCondition(cm.immcon5)
	e7:SetValue(cm.efilter2)
    c:RegisterEffect(e7)
    --
    local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_PIERCE)
    e8:SetCondition(cm.immcon3)
	c:RegisterEffect(e8)
end

function cm.lcheck(g,lc)
	return aux.dncheck(g)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
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

function cm.tgefilter(c,tp)
    return not c:IsForbidden() and c:CheckUniqueOnField(tp) and not c:IsType(TYPE_FIELD)
end

function cm.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgefilter,tp,0x02,0,1,nil,tp) and Duel.GetLocationCount(tp,0x08)>0 end
end

function cm.opfilterc(c)
    for i = 0, 2, 1 do
        if c:IsType(1<<i) then
            return 1<<i
        end
    end
end

function cm.opefilter(g)
    return g:GetClassCount(cm.opfilterc)==#g
end

function cm.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c,ct=e:GetHandler(),Duel.GetLocationCount(tp,0x08)
    if c:IsRelateToChain() and c:IsLocation(0x04) and ct>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g=Duel.GetMatchingGroup(cm.tgefilter,tp,0x02,0,nil,tp):SelectSubGroup(tp,cm.opefilter,false,1,math.min(ct,3))
        if #g>0 then
            for tc in aux.Next(g) do
                Duel.MoveToField(tc,tp,tp,0x08,POS_FACEUP,false)
                Duel.Equip(tp,tc,c,false,true)
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetLabelObject(c)
                e1:SetCode(EFFECT_EQUIP_LIMIT)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                e1:SetValue(cm.eqlimit)
                tc:RegisterEffect(e1)
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_DISABLE)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e3)
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetValue(RESET_TURN_SET)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e2)
            end
            Duel.EquipComplete()
        end
    end
end

function cm.eqlimit(e,c)
	return e:GetLabelObject()==c
end

function cm.atkval(e,c)
    local g,val=e:GetHandler():GetEquipGroup(),0
    for tc in aux.Next(g) do
        if tc:GetOriginalType()&0x1~=0 then
            if tc:GetLink()>0 then
                val=val+tc:GetLink()*500
            elseif tc:GetLevel()>0 then
                val=val+tc:GetLevel()*100
            end
        else
            val=val+500
        end
    end
    return val
end

function cm.conifilter(c,type)
    return c:GetOriginalType()&type~=0
end

function cm.immcon1(e)
	return e:GetHandler():GetEquipGroup():IsExists(cm.conifilter,1,nil,0x1)
end

function cm.immcon2(e)
	return e:GetHandler():GetEquipGroup():IsExists(cm.conifilter,1,nil,0x2)
end

function cm.immcon3(e)
	return e:GetHandler():GetEquipGroup():IsExists(cm.conifilter,1,nil,0x4)
end

function cm.immcon4(e)
	return Duel.GetAttacker()==e:GetHandler() and cm.immcon2(e)
end

function cm.immcon5(e)
	return Duel.GetCurrentPhase()~=PHASE_MAIN1 and Duel.GetCurrentPhase()~=PHASE_MAIN2 and cm.immcon3(e)
end

function cm.distg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end

function cm.efilter(e,te)
    local tc=te:GetHandler()
	return not tc:IsCode(m) and te:IsActiveType(0x1) and tc:IsRace(0xc)
end

function cm.efilter2(e,te)
	return e:GetHandlerPlayer()~=te:GetOwnerPlayer()
end
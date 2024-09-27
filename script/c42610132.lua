--幼女战记 谭雅·冯·提古雷查夫
local cm,m=GetID()

function cm.initial_effect(c)
    aux.AddCodeList(c,10700108)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --spsummonsuccess
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(cm.descon)
	e2:SetTarget(cm.destg)
	e2:SetOperation(cm.desop)
	c:RegisterEffect(e2)
end

function cm.lckfilter(c)
    return c:IsLinkRace(RACE_FIEND) or c:IsLinkAttribute(ATTRIBUTE_DARK)
end

function cm.lcheck(g,lc)
	return g:IsExists(cm.lckfilter,1,nil)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
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

function cm.tgtfilter(c)
    return (aux.NegateMonsterFilter(c) or c:GetAttack()>0) and c:IsFaceup()
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetLinkedGroup()
	if chk==0 then return #g>0 and g:IsExists(cm.tgtfilter,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,nil,nil)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lg=c:GetLinkedGroup()
    if not (#lg>0 and lg:IsExists(cm.tgtfilter,1,nil)) then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=lg:FilterSelect(tp,cm.tgtfilter,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        local tc=g:GetFirst()
        if tc:GetAttack()>0 and (not (aux.NegateMonsterFilter(tc)) or Duel.SelectOption(tp,aux.Stringid(m,0),aux.Stringid(m,1))==0) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(tc:GetAttack())
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_ATTACK_FINAL)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            e2:SetValue(0)
            tc:RegisterEffect(e2)
        else
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            if tc:IsType(TYPE_TRAPMONSTER) then
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e3)
            end
        end
    end
end

function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetReasonPlayer()==1-tp
end

function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0x0c,0x0c,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,0x0c)
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0x0c,0x0c,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
        local tc=g:GetFirst()
        if tc:IsCanBeDisabledByEffect(e) then
            local c=e:GetHandler()
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
            if tc:IsType(TYPE_TRAPMONSTER) then
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e3)
            end
        end
	end
end
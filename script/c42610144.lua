--绯弹的亚里亚 峰·理子·罗宾
local cm,m=GetID()
if not require and loadfile then
    function require(str)
        require_list=require_list or {}
        if not require_list[str] then
            require_list[str]=true
            dofile(str..".lua")
        end
        return true
    end
end
if not pcall(function() require("expansions/script/c42699999") end) then require("script/c42699999") end

function cm.initial_effect(c)
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
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --negate
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,m)
	e2:SetTarget(cm.destg)
	e2:SetOperation(cm.desop)
	c:RegisterEffect(e2)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_WARRIOR) or g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_LIGHT)
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

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetLinkedHalfLineGroup()
	if chk==0 then return #g>0 end
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if (not c:IsLocation(0x0c)) and c:IsFaceup() then return false end
    local rlg=c:GetLinkedHalfLineGroup()
    if c:IsRelateToEffect(e) and #rlg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=rlg:Select(tp,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            local tct=1
            if Duel.GetCurrentPhase()<=PHASE_STANDBY then tct=2 end
            local tc=g:GetFirst()
            tc:RegisterFlagEffect(m,RESET_PHASE+PHASE_STANDBY+RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,tct,0,aux.Stringid(m,0))
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
            e1:SetCountLimit(1)
            e1:SetLabel(Duel.GetTurnCount())
            e1:SetLabelObject(tc)
            e1:SetCondition(cm.spcon)
            e1:SetOperation(cm.spop)
            e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_EVENT+RESETS_STANDARD,tct)
            Duel.RegisterEffect(e1,tp)
        end
    end
end

function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetLabel()+1 and e:GetLabelObject():GetFlagEffect(m)~=0
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.SendtoHand(e:GetLabelObject(),e:GetHandlerPlayer(),REASON_EFFECT)
end

function cm.tgdfilter(c)
    return c:IsType(TYPE_LINK) and c:GetLinkedHalfLineGroup()>0
end

function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(0x04) and cm.tgdfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cm.tgdfilter,tp,0x04,0x04,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.tgdfilter,tp,0x04,0x04,1,1,nil)
    local lg=g:GetFirst():GetLinkedHalfLineGroup()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,lg,1,nil,nil)
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        local lg=tc:GetLinkedHalfLineGroup()
        if lg then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	        local g=lg:Select(tp,1,1,nil)
            if #g>0 then
                Duel.HintSelection(g)
                Duel.Destroy(g,REASON_EFFECT)
            end
        end
    end
end
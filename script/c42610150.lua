--爱杀宝贝 吴织亚切
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
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --negate attack
	local e4=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
    e4:SetTarget(cm.negtg)
	e4:SetOperation(cm.negop)
	c:RegisterEffect(e4)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND) or g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_DARK)
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

function cm.tgtfilter(g,e)
    local lg=g:GetGroupLineGroup()
    return #lg>0 and g:FilterCount(Card.IsCanBeEffectTarget,nil,e)==2
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local g=Duel.GetFieldGroup(tp,0x0c,0x0c)
	if chk==0 then return #g>=2 and g:CheckSubGroup(cm.tgtfilter,2,2,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local rg=g:SelectSubGroup(tp,cm.tgtfilter,false,2,2,e)
    Duel.SetTargetCard(rg)
    local rlg=rg:GetGroupLineGroup()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,rlg,#rlg,nil,nil)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #tg~=2 then return false end
    local rg=tg:GetGroupLineGroup()
    if #rg>0 then
        Duel.Destroy(rg,REASON_EFFECT)
    end
end

function cm.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,e:GetHandler(),1,nil,nil)
end

function cm.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetLabelObject(c)
        e1:SetCountLimit(1)
        e1:SetOperation(cm.retop)
        Duel.RegisterEffect(e1,tp)
    end
end

function cm.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject(),POS_FACEUP)
end
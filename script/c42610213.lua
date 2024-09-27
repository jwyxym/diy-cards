--辉夜大小姐想让我告白 四条真妃
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,0xc),2,2)
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
    e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(cm.regcon)
    e2:SetCost(cm.thcost)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    --
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(0x04)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.spcon)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
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

function cm.costthcfilter(c)
    return c:IsAbleToHand() and c:IsRace(0xc)
end

function cm.costthgfilter(g,crace)
    if crace&0xc==0xc then
        return g:GetClassCount(Card.GetRace)==2
    elseif crace&0x4~=0 then
        return #g==1 and g:GetFirst():IsRace(0x8)
    elseif crace&0x8~=0 then
        return #g==1 and g:GetFirst():IsRace(0x4)
    end
end

function cm.costdfilter(c)
    return c:IsRace(0xc) and c:IsAbleToRemoveAsCost() and Duel.GetMatchingGroup(cm.costthcfilter,0,0x10,0x10,nil):CheckSubGroup(cm.costthgfilter,1,2,c:GetOriginalRace())
end

function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costdfilter,tp,0x01,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,cm.costdfilter,tp,0x01,0,1,1,nil):GetFirst()
    if tc then
        Duel.Remove(tc,POS_FACEUP,REASON_COST)
        e:SetLabel(tc:GetOriginalRace())
    end
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,0x10)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.GetMatchingGroup(cm.costthcfilter,0,0x10,0x10,nil):SelectSubGroup(tp,cm.costthgfilter,false,1,2,c:GetOriginalRace())
    if #g>0 then
        Duel.SendtoHand(g,tp,REASON_EFFECT)
        if g:IsExists(Card.IsLocation,1,nil,0x02) then
            Duel.ConfirmCards(1-tp,g:Filter(Card.IsLocation,nil,0x02))
        end
    end
end

function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end

function cm.tgsfilter(c,e,tp)
    return c:IsLink(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(0x10) and chkc:IsControler(tp) and cm.tgsfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,0x02,0,1,nil) and c:IsAbleToGrave() and Duel.IsExistingTarget(cm.tgsfilter,tp,0x10,0,1,nil,e,tp) and Duel.GetMZoneCount(tp,c)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,cm.tgsfilter,tp,0x10,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,nil,nil)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil) then
        local c=e:GetHandler()
        if c:IsRelateToChain() and Duel.SendtoGrave(c,REASON_EFFECT) and c:IsLocation(0x10) then
            local tc=Duel.GetFirstTarget()
            if tc:IsRelateToChain() then
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end
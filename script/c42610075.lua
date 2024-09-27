--業·古手梨花
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
	c:EnableReviveLimit()
    --imm
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_REMOVE)
    c:RegisterEffect(e3)
    --refresh
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,m)
    e4:SetCondition(cm.thcon)
	e4:SetTarget(cm.thtg)
	e4:SetOperation(cm.thop)
	c:RegisterEffect(e4)
    --todeck
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,m+1)
	e5:SetTarget(cm.tdtg)
	e5:SetOperation(cm.tdop)
	c:RegisterEffect(e5)
end

function cm.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_DARK)
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cm.tgthfilter(c)
    return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsFaceup()
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(cm.tgthfilter,tp,0x01,0x01,nil)
    if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,nil,LOCATION_REMOVED)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.tgthfilter,tp,0x01,0x01,nil)
    if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) then
        local og=Duel.GetOperatedGroup()
        Duel.BreakEffect()
        Duel.SendtoDeck(og,nil,2,REASON_EFFECT)
    end
end

function cm.tgtfilter(c,tp)
    return c:IsAbleToHand() and ((c:IsControler(1-tp) and c:IsFacedown()) or not c:IsExtraDeckMonster())
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(cm.tgtfilter,tp,0x20,0x20,nil,tp)
	if chk==0 then return #g>0 and (Duel.IsPlayerCanRemove(tp) or g:FilterCount(Card.IsFaceup,nil)==0) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,3,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,3,nil,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,nil,LOCATION_HAND)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(cm.tgtfilter,tp,0x20,0x20,nil,tp)
    if #g>0 then
        local n=Duel.GetRandomNumber(1,math.min(#g,5))
        local rg=g:RandomSelect(tp,n)
        if #rg>0 and Duel.SendtoHand(rg,tp,REASON_EFFECT) then
            local og=Duel.GetOperatedGroup()
            if og:IsExists(Card.IsLocation,1,nil,0x02) then
                og=og:Filter(Card.IsLocation,nil,0x02)
                Duel.ConfirmCards(1-tp,og)
                Duel.BreakEffect()
                local upg,dng=Group.CreateGroup(),Group.CreateGroup()
                for tc in aux.Next(og) do
                    local tpos=tc:GetPreviousPosition()
                    if tpos==POS_FACEUP then
                        upg:AddCard(tc)
                    elseif tpos==POS_FACEDOWN then
                        dng:AddCard(tc)
                    end
                end
                if #upg>0 then
                    Duel.Remove(upg,POS_FACEDOWN,REASON_EFFECT)
                end
                if #dng>0 then
                    Duel.SendtoDeck(dng,nil,2,REASON_EFFECT)
                end
            end
        end
    end
end
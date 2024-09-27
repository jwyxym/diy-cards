--箤·北条沙都子
local cm,m=GetID()

function cm.initial_effect(c)
    Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
	c:EnableReviveLimit()
    --cpos
    local e4=Effect.CreateEffect(c)
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
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,m+1)
	e5:SetTarget(cm.tdtg)
	e5:SetOperation(cm.tdop)
	c:RegisterEffect(e5)
    --atk
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_LIGHT)
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroupCount(Card.IsPosition,tp,0x01,0x01,nil,POS_FACEDOWN)>0 end
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0x01,0x01,nil,POS_FACEDOWN)
    if #g<=0 then return false end
    if #g>10 then g=g:RandomSelect(tp,10) end
    local tc=g:GetFirst()
    while tc do
        tc:ReverseInDeck()
        tc=g:GetNext()
    end
    Duel.ConfirmCards(tp,g)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleDeck(tp)
    Duel.ShuffleDeck(1-tp)
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMatchingGroupCount(Card.IsAbleToHand,tp,0x01,0x01,nil)>0 and Duel.IsPlayerCanRemove(tp) and Duel.GetMatchingGroupCount(Card.IsPosition,tp,0x01,0x01,nil,POS_FACEDOWN)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,0x01)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0x01,0x01,nil)
    if #g<=0 then return false end
    g=g:RandomSelect(tp,1)
    local tc=g:GetFirst()
    local cpos=0
    if tc:IsFaceup() then cpos=POS_FACEUP else cpos=POS_FACEDOWN end
    Duel.DisableShuffleCheck()
    if Duel.SendtoHand(tc,tp,REASON_EFFECT) then
        Duel.ConfirmCards(1-tp,tc)
        Duel.BreakEffect()
        local dg=Duel.GetMatchingGroup(Card.IsPosition,tp,0x01,0x01,nil,POS_FACEDOWN)
        if cpos==POS_FACEUP then
            if #dg>0 then dg=dg:RandomSelect(tp,math.min(#dg,10)) end
        elseif cpos==POS_FACEDOWN then
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
            if #dg>0 then dg=dg:RandomSelect(tp,math.min(#dg,2)) end
        end
        if #dg>0 then
            local dc=dg:GetFirst()
            while dc do
                dc:ReverseInDeck()
                dc=dg:GetNext()
            end
            Duel.ConfirmCards(tp,dg)
            Duel.ConfirmCards(1-tp,dg)
            Duel.ShuffleDeck(tp)
            Duel.ShuffleDeck(1-tp)
        end
    end
end

function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFaceup,e:GetHandlerPlayer(),0x41,0,nil)*100
end